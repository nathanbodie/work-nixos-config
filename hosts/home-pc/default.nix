{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/boot.nix
    ../../modules/nixos/core.nix
    ../../modules/nixos/desktop.nix
  ];

  networking.hostName = "home-pc";

  system.stateVersion = "25.11";
}
