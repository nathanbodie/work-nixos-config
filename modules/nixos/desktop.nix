{ pkgs, inputs, ... }: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  security.polkit.enable = true;

  systemd.user.services.hyprpolkitagent = {
    description = "Hyprland Polkit Agent";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
    };
  };

  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;
    package = pkgs.kdePackages.sddm;
    theme = "";
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr
    ];
  };

  environment.sessionVariables = {
    AMD_VULKAN_ICD = "RADV";
    RADV_PERFTEST = "gpl";
  };

  hardware.uinput.enable = true;

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
    # terminals, browsers, comms → managed by HM (programs.ghostty, etc.)
    hyprcursor
    hyprlock
    hyprshot
    firefox
    microsoft-edge
    teams-for-linux
    kdePackages.dolphin
    yazi
    qemu
    quickemu
    quickgui
    spice
    virt-viewer
    obsidian
    pavucontrol
    libnotify
    zathura
    imv
    equibop
    heroic
    mangohud
    goverlay
    gamescope
    joystickwake
    lact
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
