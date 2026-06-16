{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/boot.nix
    ../../modules/nixos/core.nix
    ../../modules/nixos/desktop.nix
  ];

  networking.hostName = "TSEP45550075";

  system.stateVersion = "25.11";
}
