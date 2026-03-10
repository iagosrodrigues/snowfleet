{
  inputs,
  ...
}:
{
  flake = {
    modules = {
      nixos.niri =
        { pkgs, ... }:
        {
          programs.niri = {
            enable = true;
            package = pkgs.niri-stable;
          };

          services.gnome.gnome-keyring.enable = true;
        };

      homeManager.niri =
        { ... }:
        {
          imports = [ inputs.niri.homeModules.niri ];
        };

      homeManager.niri-config =
        {
          lib,
          pkgs,
          ...
        }:
        {
          programs.niri.settings = {
            prefer-no-csd = false;

            spawn-at-startup = [
              { argv = [ "ashell" ]; }
              { argv = [ "ghostty" ]; }
            ];

            window-rules = [
              {
                draw-border-with-background = false;
              }
              {
                matches = [ { app-id = "^ghostty$"; } ];
                opacity = 0.8;
              }
            ];

            xwayland-satellite.path = "${lib.getExe pkgs.xwayland-satellite}";

            input = {
              focus-follows-mouse.max-scroll-amount = "0%";

              keyboard = {
                xkb = {
                  layout = "us,us,us";
                  variant = "intl,workman-intl,colemak_dh";
                  options = "ctrl:nocaps,cap:ctrl_shifted_capslock,grp:win_space_toggle";
                };
                repeat-delay = 250;
                repeat-rate = 40;
                track-layout = "global";
              };

              touchpad = {
                tap = true;
                dwt = true;
              };

              mouse = {
                accel-profile = "flat";
                accel-speed = 0.5;
              };
            };

            layout = {
              gaps = 10;
              center-focused-column = "never";
              default-column-width.proportion = 0.5;
              preset-column-widths = [
                { proportion = 0.33; }
                { proportion = 0.5; }
                { proportion = 0.66; }
              ];
            };

            hotkey-overlay.skip-at-startup = true;

            binds = {
              "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

              "Mod+Return".action.spawn = "ghostty";
              "Mod+E".action.spawn = "fuzzel";
              "Mod+B".action.spawn = "firefox";
              "Mod+S".action.spawn = "steam";
              "Mod+T".action.spawn = "telegram";

              "XF86AudioRaiseVolume" = {
                allow-when-locked = true;
                action.spawn = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
              };

              "XF86AudioLowerVolume" = {
                allow-when-locked = true;
                action.spawn = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
              };

              "XF86AudioMute" = {
                allow-when-locked = true;
                action.spawn = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
              };

              "XF86AudioMicMute" = {
                allow-when-locked = true;
                action.spawn = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
              };

              "XF86AudioPlay" = {
                allow-when-locked = true;
                action.spawn = "playerctl play-pause";
              };

              "Mod+O".action.toggle-overview = [ ];
              "Mod+Q".action.close-window = [ ];

              "Mod+Left".action.focus-column-left = [ ];
              "Mod+Down".action.focus-window-down = [ ];
              "Mod+Up".action.focus-window-up = [ ];
              "Mod+Right".action.focus-column-right = [ ];
              "Mod+H".action.focus-column-left = [ ];
              "Mod+L".action.focus-column-right = [ ];

              "Mod+Ctrl+Left".action.move-column-left = [ ];
              "Mod+Ctrl+Down".action.move-window-down = [ ];
              "Mod+Ctrl+Up".action.move-window-up = [ ];
              "Mod+Ctrl+Right".action.move-column-right = [ ];
              "Mod+Ctrl+H".action.move-column-left = [ ];

              "Mod+J".action.focus-window-or-workspace-down = [ ];
              "Mod+K".action.focus-window-or-workspace-up = [ ];
              "Mod+Ctrl+J".action.move-window-down-or-to-workspace-down = [ ];
              "Mod+Ctrl+K".action.move-window-up-or-to-workspace-up = [ ];

              "Mod+Home".action.focus-column-first = [ ];
              "Mod+End".action.focus-column-last = [ ];
              "Mod+Ctrl+Home".action.move-column-to-first = [ ];
              "Mod+Ctrl+End".action.move-column-to-last = [ ];

              "Mod+Shift+Left".action.focus-monitor-left = [ ];
              "Mod+Shift+Down".action.focus-monitor-down = [ ];
              "Mod+Shift+Up".action.focus-monitor-up = [ ];
              "Mod+Shift+Right".action.focus-monitor-right = [ ];
              "Mod+Shift+H".action.focus-monitor-left = [ ];
              "Mod+Shift+J".action.focus-monitor-down = [ ];
              "Mod+Shift+K".action.focus-monitor-up = [ ];
              "Mod+Shift+L".action.focus-monitor-right = [ ];

              "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
              "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
              "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
              "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];
              "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
              "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
              "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
              "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];

              "Mod+Page_Down".action.focus-workspace-down = [ ];
              "Mod+Page_Up".action.focus-workspace-up = [ ];
              "Mod+U".action.focus-workspace-down = [ ];
              "Mod+I".action.focus-workspace-up = [ ];
              "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [ ];
              "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [ ];
              "Mod+Ctrl+U".action.move-column-to-workspace-down = [ ];
              "Mod+Ctrl+I".action.move-column-to-workspace-up = [ ];

              "Mod+Shift+Page_Down".action.move-workspace-down = [ ];
              "Mod+Shift+Page_Up".action.move-workspace-up = [ ];
              "Mod+Shift+U".action.move-workspace-down = [ ];
              "Mod+Shift+I".action.move-workspace-up = [ ];

              "Mod+WheelScrollDown".action.focus-column-right = [ ];
              "Mod+WheelScrollUp".action.focus-column-left = [ ];
              "Mod+Ctrl+WheelScrollDown".action.move-column-to-workspace-down = [ ];
              "Mod+Ctrl+WheelScrollUp".action.move-column-to-workspace-up = [ ];

              "Mod+1".action.focus-workspace = 1;
              "Mod+2".action.focus-workspace = 2;
              "Mod+3".action.focus-workspace = 3;
              "Mod+4".action.focus-workspace = 4;
              "Mod+5".action.focus-workspace = 5;
              "Mod+6".action.focus-workspace = 6;
              "Mod+7".action.focus-workspace = 7;
              "Mod+8".action.focus-workspace = 8;
              "Mod+9".action.focus-workspace = 9;
              "Mod+Ctrl+1".action.move-column-to-workspace = 1;
              "Mod+Ctrl+2".action.move-column-to-workspace = 2;
              "Mod+Ctrl+3".action.move-column-to-workspace = 3;
              "Mod+Ctrl+4".action.move-column-to-workspace = 4;
              "Mod+Ctrl+5".action.move-column-to-workspace = 5;
              "Mod+Ctrl+6".action.move-column-to-workspace = 6;
              "Mod+Ctrl+7".action.move-column-to-workspace = 7;
              "Mod+Ctrl+8".action.move-column-to-workspace = 8;
              "Mod+Ctrl+9".action.move-column-to-workspace = 9;

              "Mod+F".action.maximize-column = [ ];
              "Mod+Shift+F".action.fullscreen-window = [ ];
            };

            outputs."DP-1" = {
              focus-at-startup = true;
              mode = {
                width = 2560;
                height = 1440;
                refresh = 74.924;
              };
              backdrop-color = "#001100";
            };

            cursor = {
              size = 48;
              theme = "macOS";
            };
          };
        };
    };
  };
}
