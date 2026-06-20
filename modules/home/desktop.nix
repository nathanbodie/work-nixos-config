{ pkgs, inputs, ... }: {
  imports = [ inputs.noctalia.homeModules.default ];

  # ── Noctalia Shell ───────────────────────────────────────────────────────────

  programs.noctalia-shell = {
    enable = true;
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;

    settings = {
      colorSchemes = {
        darkMode           = true;
        useWallpaperColors = true;
      };
      wallpaper = {
        enabled                   = true;
        directory                 = "/home/nate/.config/hypr/wallpapers";
        viewMode                  = "single";
        setWallpaperOnAllMonitors = true;
        useWallhaven              = false;
      };
      hooks = {
        enabled = true;
        startup = "sleep 1 && noctalia-shell ipc call wallpaper set $HOME/.config/hypr/wallpapers/A_Herefordshire_Lane.png all";
      };
      appLauncher.terminalCommand = "ghostty -e";
      dock.enabled = false;
      general = {
        showChangelogOnStartup = false;
        telemetryEnabled       = false;
      };
      idle = {
        enabled          = true;
        screenOffTimeout = 300;
        lockTimeout      = 360;
        suspendTimeout   = 1800;
      };
    };
  };

  # ── Wallpaper asset (used by noctalia) ───────────────────────────────────────

  xdg.configFile."hypr/wallpapers/A_Herefordshire_Lane.png".source =
    ../../assets/wallpapers/A_Herefordshire_Lane.png;

  # ── Ghostty ──────────────────────────────────────────────────────────────────

  programs.ghostty = {
    enable = true;
    settings = {
      font-size      = 24;
      window-padding-x = 8;
      maximize       = true;
      font-family    = "JetBrainsMonoNL Nerd Font Mono";
      theme          = "vague";
    };
  };

  xdg.configFile."ghostty/themes/vague".text = ''
    background = #141415
    foreground = #cdcdcd

    selection-background = #333738
    selection-foreground = #cdcdcd

    cursor-color = #cdcdcd
    cursor-text = #141415

    palette = 0=#141415
    palette = 1=#d8647e
    palette = 2=#7fa563
    palette = 3=#f3be7c
    palette = 4=#7e98e8
    palette = 5=#bb9dbd
    palette = 6=#9bb4bc
    palette = 7=#cdcdcd
    palette = 8=#606079
    palette = 9=#d8647e
    palette = 10=#7fa563
    palette = 11=#e0a363
    palette = 12=#6e94b2
    palette = 13=#bb9dbd
    palette = 14=#b4d4cf
    palette = 15=#c3c3d5

    window-padding-x = 8
    window-padding-y = 8
    window-theme = dark
  '';

  # ── Kitty (secondary terminal) ───────────────────────────────────────────────

  programs.kitty = {
    enable = true;
    font = {
      name = "Terminess Nerd Font Mono";
      size = 25;
    };
    settings = {
      window_padding_width  = 16;
      remember_window_size  = "no";
      initial_window_width  = "0c";
      initial_window_height = "0c";
    };
    extraConfig = ''
      include themes/vague2.conf
    '';
  };

  # ── Automount daemon ─────────────────────────────────────────────────────────

  services.udiskie = {
    enable    = true;
    automount = true;
    tray      = "auto";
  };

  # ── Extra packages required by keybinds / scripts ────────────────────────────

  home.packages = with pkgs; [
    playerctl
    brightnessctl
    hyprpicker
  ];
}
