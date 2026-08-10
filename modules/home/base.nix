{ pkgs, ... }: {
  imports = [ ./cli-tools.nix ];

  home.packages = with pkgs; [ wl-clipboard ];
}
