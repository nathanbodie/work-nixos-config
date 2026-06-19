{ pkgs, inputs, ... }: {
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  programs.gamemode.enable = true;

  environment.etc."share/applications/steam.desktop" = {
    text = ''
      [Desktop Entry]
      Name=Steam
      Comment=Application for managing and playing games on Steam
      Exec=steam %U
      Icon=steam
      Terminal=false
      Type=Application
      Categories=Network;FileTransfer;Game;
      MimeType=x-scheme-handler/steam;x-scheme-handler/steamlink;
      PrefersNonDefaultGPU=false
      X-KDE-RunOnDiscreteGpu=false

      [Desktop Action Store]
      Name=Steam Store
      Exec=steam steam://store

      [Desktop Action Community]
      Name=Steam Community
      Exec=steam steam://url/SteamIDControlPage
    '';
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;

  environment.systemPackages = with pkgs; [
    equibop
    heroic
    mangohud
    goverlay
    gamescope
    joystickwake
    lact
  ];
}
