{ inputs, pkgs, config, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  networking.hostName = "vps";

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # EFI boot — efiInstallAsRemovable avoids needing to write EFI vars,
  # which is safer on most VPS providers.
  boot.loader.grub = {
    enable = true;
    device = "nodev";
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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID1w4OTAaFlD4l9GSZUbYUdSVFSW0CYd3o5r00Ra3UBT nathan@bodie.dev"
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Key-based SSH only; no password auth, no root login.
  # Port 22 is NOT opened on the public interface — SSH is only reachable
  # over Tailscale (trustedInterfaces covers tailscale0).
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.tailscale.enable = true;

  # Only the Tailscale WireGuard port is open on the public interface.
  # Everything else (SSH, mosh) is reachable only over tailscale0.
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
  swapDevices = [{ device = "/var/swapfile"; size = 2048; }];

  system.stateVersion = "25.11";
}
