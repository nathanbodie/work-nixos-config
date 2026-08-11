{ inputs, pkgs, config, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  networking.hostName = "vps";

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Installs GRUB for both firmware paths, since Hetzner Cloud instances vary in
  # whether they boot BIOS or UEFI: x86_64-efi because efiSupport is set, and
  # i386-pc because the EF02 partition in disko.nix makes disko populate
  # `boot.loader.grub.devices` with /dev/sda on our behalf — do not set it here
  # too, that produces a duplicate entry.
  # efiInstallAsRemovable avoids needing to write EFI vars, which is safer on
  # most VPS providers.
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  boot.loader.efi.canTouchEfiVariables = false;

  programs.zsh.enable = true;
  programs.mosh.enable = true;

  users.users.nate = {
    isNormalUser = true;
    description = "nate";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    # Keep user systemd instance alive without an active login so the
    # tmux-work service (defined in home/nate/vps.nix) survives reboots.
    linger = true;
    # Every machine that needs to reach this box must be listed here. There is
    # no password on this account and root login is disabled, so the Hetzner
    # console is not a fallback — an unlisted key means no way in at all.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID1w4OTAaFlD4l9GSZUbYUdSVFSW0CYd3o5r00Ra3UBT nathan@bodie.dev"
      # work macbook — the machine that drives dev-vps/deploy.sh
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK1ZEAriERFWXRSCHmk3fdI9O28GQ5pkPvcX/dTzx8kC nathan@book"
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Key-based SSH only; no password auth, no root login.
  #
  # openFirewall defaults to TRUE in the openssh module — enabling the service
  # opens TCP 22 on every interface by itself, regardless of what the firewall
  # block below says. Explicitly false: SSH is reachable only over tailscale0,
  # which trustedInterfaces covers.
  #
  # This is a one-way door. There is no password on the nate account and root
  # login is disabled, so the Hetzner console cannot log in — if tailscaled ever
  # fails to come up, the only way back in is rescue mode plus a reinstall
  # (dev-vps/deploy.sh, ~10 minutes). Set this back to true before touching
  # anything that could break Tailscale enrollment.
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # authKeyFile makes the module generate its own tailscaled-autoconnect unit,
  # which polls until the backend leaves NoState and then runs `tailscale up`
  # only when it reports NeedsLogin/NeedsMachineAuth. That is the correct guard.
  # A hand-rolled unit keyed on ConditionPathExists=!/var/lib/tailscale/
  # tailscaled.state does NOT work: tailscaled writes that state file the moment
  # it starts, logged in or not, so the auth step gets skipped on the very first
  # boot and the machine silently never joins the tailnet.
  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale-authkey.path;
    # --accept-dns defaults to on, which repoints /etc/resolv.conf at
    # 100.100.100.100 alone. This tailnet has no global nameserver configured,
    # so public DNS stops resolving entirely: raw IPs still work (SSH stays up)
    # but every flake fetch fails with "Could not resolve host: github.com",
    # which means the box cannot rebuild itself. Keep Hetzner's resolvers.
    # Note this only takes effect at `tailscale up` on a fresh enrollment; on an
    # already-enrolled machine run `sudo tailscale set --accept-dns=false`.
    extraUpFlags = [ "--accept-dns=false" ];
  };

  # Only the Tailscale WireGuard port is open on the public interface.
  # Everything else (SSH, mosh) is reachable only over tailscale0.
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    # Required for Tailscale routing/MASQUERADE rules to work correctly.
    checkReversePath = "loose";
  };

  # Decrypted to /run/agenix/tailscale-authkey (tmpfs, root-only) during
  # activation, which happens before multi-user.target, so tailscaled-autoconnect
  # finds it.
  age.secrets.tailscale-authkey.file = ../../secrets/tailscale-authkey.age;

  # nate has no password — the account exists only for key-based SSH — so the
  # default wheelNeedsPassword makes sudo unusable, and with it nixos-rebuild.
  # Key-only login plus PasswordAuthentication = false means whoever can log in
  # can already act as root on this box; requiring a password nobody has just
  # bricks administration.
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    git
    gh
    neovim
    wget
    mosh
    tmux
    htop
    btop
    ripgrep
    fd
    jq
    # Claude Code requires a recent Node; the claude-code package in nixpkgs
    # bundles its own, but nodejs is handy for npm-installed tools too.
    nodejs_22
  ];

  # Swap file instead of partition so disk can be resized without repartitioning.
  # Sized generously: several concurrent Claude Code instances spiking at once
  # should page out rather than trip the OOM killer and take down an unrelated
  # session.
  swapDevices = [{ device = "/var/swapfile"; size = 16384; }];

  system.stateVersion = "25.11";
}
