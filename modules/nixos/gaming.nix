{ pkgs, inputs, ... }:
let
  dbd-map-overlay = pkgs.appimageTools.wrapType2 {
    pname = "dbd-map-overlay";
    version = "1.6.2";
    src = pkgs.fetchurl {
      url = "https://github.com/LucaFontanot/dbd-map-overlay/releases/download/v1.6.2/Dbd-Map-Overlay-1.6.2.AppImage";
      sha256 = "0whspll3yi87139s2ivz11prqpia2m6m18cnd8sxckg1vg0fbvgs";
    };
    extraInstallCommands =
      let
        extracted = pkgs.appimageTools.extract {
          pname = "dbd-map-overlay";
          version = "1.6.2";
          src = pkgs.fetchurl {
            url = "https://github.com/LucaFontanot/dbd-map-overlay/releases/download/v1.6.2/Dbd-Map-Overlay-1.6.2.AppImage";
            sha256 = "0whspll3yi87139s2ivz11prqpia2m6m18cnd8sxckg1vg0fbvgs";
          };
        };
      in
      ''
        install -Dm644 ${extracted}/usr/share/icons/hicolor/320x320/apps/dbd-map.png \
          $out/share/icons/hicolor/320x320/apps/dbd-map-overlay.png
        install -Dm644 ${extracted}/dbd-map.desktop \
          $out/share/applications/dbd-map-overlay.desktop
        sed -i \
          -e 's|Exec=AppRun|Exec=dbd-map-overlay|' \
          -e 's|Icon=dbd-map$|Icon=dbd-map-overlay|' \
          $out/share/applications/dbd-map-overlay.desktop
      '';
  };

  bedrockOnLinuxVersion = "2.1.1";
  bedrockOnLinuxBundle = pkgs.fetchurl {
    url = "https://github.com/Wyze3306/BedrockOnLinux/releases/download/v${bedrockOnLinuxVersion}/BedrockOnLinux-${bedrockOnLinuxVersion}-x86_64.flatpak";
    sha256 = "sha256-PcPH/Goc4070A+Fm+SY30DxhVEyr6QEuupWT/aLGNXg=";
  };
in
{
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
  services.flatpak = {
    enable = true;
    packages = [ "app.twintaillauncher.ttl" ]; # unchanged — this one IS on Flathub
  };

  # BedrockOnLinux ships only as a standalone bundle (not a Flathub ref),
  # so it can't live in `packages` above — install it as its own unit.
  systemd.services.flatpak-install-bedrockonlinux = {
    description = "Install BedrockOnLinux flatpak bundle";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.flatpak pkgs.gawk ];
    serviceConfig.Type = "oneshot";
    script = ''
      installed=$(flatpak info --system io.github.wyze3306.BedrockOnLinux 2>/dev/null | awk '/^Version/{print $2}')
      if [ "$installed" != "${bedrockOnLinuxVersion}" ]; then
        flatpak install --system --noninteractive -y ${bedrockOnLinuxBundle}
      fi
    '';
  };

  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;
  services.udev.extraRules = ''
    # Wooting One Legacy
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff01", MODE:="0660", GROUP="input", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff01", MODE:="0660", GROUP="input", TAG+="uaccess"
    # Wooting One update mode
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2402", MODE:="0660", GROUP="input", TAG+="uaccess"
    # Wooting Two Legacy
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff02", MODE:="0660", GROUP="input", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="ff02", MODE:="0660", GROUP="input", TAG+="uaccess"
    # Wooting Two update mode
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2403", MODE:="0660", GROUP="input", TAG+="uaccess"
    # Generic Wooting devices
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", MODE:="0660", GROUP="input", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", MODE:="0660", GROUP="input", TAG+="uaccess"
  '';
  systemd.services.joystickwake = {
    description = "Prevent sleep while a joystick is in use";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.joystickwake}/bin/joystickwake";
      Restart = "on-failure";
    };
  };
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  environment.systemPackages = with pkgs; [
    dbd-map-overlay
    equibop
    lutris
    mangohud
    goverlay
    gamescope
    joystickwake
    lact
    vibrantlinux
    bolt-launcher
    prismlauncher
  ];
}
