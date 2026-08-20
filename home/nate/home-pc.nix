{ pkgs, ... }: {
  imports = [
    ../../modules/home/base.nix
    ../../modules/home/desktop.nix
    ../../modules/home/media.nix
    ../../modules/home/sync.nix
  ];

  home.username = "nate";
  home.homeDirectory = "/home/nate";
  home.stateVersion = "25.11";

  home.enableNixpkgsReleaseCheck = false;

  home.packages = with pkgs; [
    opencode
    code-cursor  # Cursor desktop app (https://cursor.com)
    zk           # zettelkasten note CLI (https://github.com/zk-org/zk)
  ];
}
