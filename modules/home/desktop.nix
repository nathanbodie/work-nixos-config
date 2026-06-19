{ pkgs, ... }: {

  # ── Hyprland ─────────────────────────────────────────────────────────────────

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    configType = "lua";

    settings = {
      monitor = [
        "DP-3,1920x1080@360,0x0,1"
        "DP-2,2560x1440@480,1920x0,1"
      ];

      # waybar and hyprpaper are managed as systemd user services by HM
      exec_once = [
        "ghostty"
        "zen-browser"
        "equibop"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "HYPRCURSOR_THEME,rose-pine-hyprcursor"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(6b4a1aee) rgba(2a1c08ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        rounding_power = 2;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      workspace = [
        "1, monitor:DP-2, default:true"
        "2, monitor:DP-2"
        "3, monitor:DP-2"
        "4, monitor:DP-2"
        "5, monitor:DP-2"
        "6, monitor:DP-2"
        "7, monitor:DP-2"
        "8, monitor:DP-2"
        "9, monitor:DP-2"
        "10, monitor:DP-2"
      ];

      master.new_status = "master";

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        accel_profile = "flat";
        touchpad = {
          natural_scroll = true;
          middle_button_emulation = false;
        };
      };

      gesture = [ "3, horizontal, workspace" ];

      device = [
        {
          name = "epic-mouse-v1";
          sensitivity = -0.5;
        }
      ];

      bind = [
        "SUPER, T, exec, ghostty"
        "SUPER, Q, killactive,"
        "SUPER, M, exit,"
        "SUPER, V, togglefloating,"
        "SUPER, R, exec, wofi --show drun"
        "SUPER, P, pseudo,"
        "SUPER, h, movefocus, l"
        "SUPER, l, movefocus, r"
        "SUPER, k, movefocus, u"
        "SUPER, j, movefocus, d"
        "SUPER SHIFT, h, movewindow, l"
        "SUPER SHIFT, l, movewindow, r"
        "SUPER SHIFT, k, movewindow, u"
        "SUPER SHIFT, j, movewindow, d"
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        "SUPER, 6, workspace, 6"
        "SUPER, 7, workspace, 7"
        "SUPER, 8, workspace, 8"
        "SUPER, 9, workspace, 9"
        "SUPER, 0, workspace, 10"
        "SUPER, TAB, workspace, previous"
        "SUPER, O, submap, launch"
        "SUPER, D, exec, wofi --show drun"
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
        "SUPER SHIFT, 6, movetoworkspace, 6"
        "SUPER SHIFT, 7, movetoworkspace, 7"
        "SUPER SHIFT, 8, movetoworkspace, 8"
        "SUPER SHIFT, 9, movetoworkspace, 9"
        "SUPER SHIFT, 0, movetoworkspace, 10"
        "SUPER SHIFT, period, movewindow, mon:+1"
        "SUPER SHIFT, comma, movewindow, mon:-1"
        "SUPER CTRL SHIFT, period, movecurrentworkspacetomonitor, +1"
        "SUPER CTRL SHIFT, comma, movecurrentworkspacetomonitor, -1"
        "SUPER, S, togglespecialworkspace, magic"
        "SUPER SHIFT, S, exec, hyprshot -m region"
        "SUPER SHIFT, C, exec, hyprpicker -a -f hex"
        "SUPER, mouse_down, workspace, e+1"
        "SUPER, mouse_up, workspace, e-1"
      ];

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];

      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      windowrule = [
        "match:class com.mitchellh.ghostty, workspace 1"
        "match:class zen, workspace 2"
        "match:class spotify, workspace 3"
        "match:class soundcloud-rpc, workspace 3"
        "match:class equibop, workspace 4"
        "match:class steam, workspace 6"
        "match:class .*, suppress_event maximize"
      ];
    };

    submaps.launch.settings = {
      binde = [
        ", F, exec, zen-browser"
        ", F, submap, reset"
        ", S, exec, steam"
        ", S, submap, reset"
        ", E, exec, dolphin"
      ];
      bind = [ ", escape, submap, reset" ];
    };
  };

  # ── Hyprpaper ────────────────────────────────────────────────────────────────

  xdg.configFile."hypr/wallpapers/A_Herefordshire_Lane.png".source =
    ../../assets/wallpapers/A_Herefordshire_Lane.png;

  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      ipc = "on";
      preload = [ "~/.config/hypr/wallpapers/A_Herefordshire_Lane.png" ];
      wallpaper = [
        "DP-2,~/.config/hypr/wallpapers/A_Herefordshire_Lane.png"
        "DP-3,~/.config/hypr/wallpapers/A_Herefordshire_Lane.png"
        "HDMI-A-1,~/.config/hypr/wallpapers/A_Herefordshire_Lane.png"
      ];
    };
  };

  # ── Ghostty ──────────────────────────────────────────────────────────────────

  programs.ghostty = {
    enable = true;
    settings = {
      font-size = 24;
      window-padding-x = 8;
      maximize = true;
      font-family = "JetBrainsMonoNL Nerd Font Mono";
      theme = "vague";
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

  # ── Wofi ─────────────────────────────────────────────────────────────────────

  xdg.configFile."wofi/style.css".text = ''
    window {
      font-size: 24px;
      font-family: "JetBrains Mono Nerd Font";
      background-color: #101213;
      color: #D8D6CE;
    }

    #input {
      margin: 5px;
      border: 2px solid #383A3B;
      background-color: #292C29;
      color: #D8D6CE;
      padding: 8px;
    }

    #inner-box { margin: 5px; background-color: #101213; }
    #outer-box { margin: 5px; background-color: #101213; }
    #scroll     { margin: 0px; }
    #text       { margin: 5px; color: #D8D6CE; }

    #entry:selected {
      background-color: #393A34;
      color: #D8D6CE;
    }

    #entry:hover {
      background-color: #4A4940;
      color: #D8D6CE;
    }
  '';

  # ── Kitty (secondary terminal) ───────────────────────────────────────────────

  programs.kitty = {
    enable = true;
    font = {
      name = "Terminess Nerd Font Mono";
      size = 25;
    };
    settings = {
      window_padding_width = 16;
      remember_window_size = "no";
      initial_window_width = "0c";
      initial_window_height = "0c";
    };
    extraConfig = ''
      include themes/vague2.conf
    '';
  };

  # ── Notification + automount daemons ─────────────────────────────────────────

  services.dunst.enable = true;

  services.udiskie = {
    enable = true;
    automount = true;
    tray = "auto";
  };

  # ── Extra packages required by keybinds / scripts ────────────────────────────

  home.packages = with pkgs; [
    playerctl
    brightnessctl
    hyprpicker
    wofi
  ];
}
