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
  # block below says. Left on deliberately as an escape hatch while Tailscale
  # enrollment is still unproven: with no account password and root login
  # disabled, the Hetzner console cannot log in, so if tailscaled fails to come
  # up and this is false, the machine is unrecoverable and has to be reinstalled.
  # Flip to false once the box is reliably on the tailnet.
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.tailscale.enable = true;

  # Opens the Tailscale WireGuard port. Note that TCP 22 is ALSO open publicly
  # via services.openssh.openFirewall above — mosh and everything else is
  # tailscale0-only.
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    # Required for Tailscale routing/MASQUERADE rules to work correctly.
    checkReversePath = "loose";
  };

  age.secrets.tailscale-authkey.file = ../../secrets/tailscale-authkey.age;

  # Enrolls the machine in Tailscale on first boot using the agenix secret.
  # ConditionPathExists skips the service on subsequent reboots — tailscaled
  # reconnects automatically using its saved state file.
  systemd.services.tailscale-auth = {
    description = "Tailscale one-shot auth";
    wantedBy = [ "multi-user.target" ];
    after = [ "tailscaled.service" "network-online.target" "agenix.service" ];
    wants = [ "network-online.target" "agenix.service" ];
    unitConfig.ConditionPathExists = "!/var/lib/tailscale/tailscaled.state";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.tailscale}/bin/tailscale up \
        --authkey="$(cat ${config.age.secrets.tailscale-authkey.path})"
    '';
  };

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
