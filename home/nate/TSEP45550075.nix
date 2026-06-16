{ ... }: {
  imports = [
    ../../modules/home/base.nix
    ../../modules/home/desktop.nix
    ../../modules/home/media.nix
  ];

  home.username = "nate";
  home.homeDirectory = "/home/nate";
  home.stateVersion = "25.11";

  # HM master + nixos-unstable versions differ; suppress false alarm
  home.enableNixpkgsReleaseCheck = false;
}
