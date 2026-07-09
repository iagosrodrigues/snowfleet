{
  self,
  inputs,
  ...
}:
{
  flake.modules.nixos.niri =
    { pkgs, ... }:
    {
      programs.niri = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
      };
    };

  perSystem =
    { pkgs, lib, ... }:
    let
      noArgs = action: _: {
        content.${action} = _: { };
      };
      withProps = props: action: _: {
        inherit props;
        content.${action} = _: { };
      };
      withArg = action: arg: {
        ${action} = arg;
      };
      spawnWithProps = props: command: _: {
        inherit props;
        content.spawn = command;
      };
      spawnShWithProps = props: command: _: {
        inherit props;
        content.spawn-sh = command;
      };
      namedWorkspace = name: {
        workspace = _: {
          props = name;
        };
      };

      allowWhenLocked = {
        allow-when-locked = true;
      };
      wpctl = lib.getExe' pkgs.wireplumber "wpctl";
      playerctl = lib.getExe pkgs.playerctl;
      brightnessctl = lib.getExe pkgs.brightnessctl;
      terminalAppIds = "^(com\\.mitchellh\\.ghostty|ghostty|Alacritty|kitty|foot|footclient|org\\.wezfurlong\\.wezterm)$";
      browserAppIds = "^(brave-browser|Brave-browser|brave|net\\.imput\\.helium|helium|helium-browser|firefox|librewolf|floorp|zen|chromium|google-chrome)$";
      socialAppIds = "^(org\\.telegram\\.desktop|telegram-desktop|telegramdesktop|discord|Discord|discordcanary|discordptb|vesktop|dev\\.vencord\\.Vesktop|WebCord|org\\.signal\\.Signal|signal|Element|element|im\\.riot\\.Riot|Slack|slack)$";
    in
    {
      packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;

        settings = {
          prefer-no-csd = false;
          spawn-at-startup = [
            (lib.getExe pkgs.ashell)
          ];

          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          outputs."DP-1".mode = "2560x1440@74.924";

          cursor = {
            xcursor-theme = "macOS";
            xcursor-size = 54;
          };

          window-rules = [
            # Check app IDs with `niri msg pick-window` if an app lands elsewhere.
            {
              matches = [ { app-id = terminalAppIds; } ];
              open-on-workspace = "terminal";
            }
            {
              matches = [ { app-id = browserAppIds; } ];
              open-on-workspace = "browser";
            }
            {
              matches = [ { app-id = socialAppIds; } ];
              open-on-workspace = "social";
            }
          ];

          input = {
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
            # Niri does not auto-fill default binds once this block is declared.
            "Mod+Shift+Slash" = noArgs "show-hotkey-overlay";
            "Mod+Return".spawn-sh = lib.getExe pkgs.ghostty;
            "Mod+D" = spawnWithProps { hotkey-overlay-title = "Run an Application: fuzzel"; } [
              (lib.getExe pkgs.fuzzel)
            ];
            "Super+Alt+L" = spawnWithProps { hotkey-overlay-title = "Lock the Screen: swaylock"; } [
              (lib.getExe pkgs.swaylock)
            ];
            "Super+Alt+S" = spawnShWithProps (
              allowWhenLocked // { hotkey-overlay-title = null; }
            ) "${lib.getExe' pkgs.procps "pkill"} orca || exec ${lib.getExe pkgs.orca}";

            "XF86AudioRaiseVolume" =
              spawnShWithProps allowWhenLocked "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
            "XF86AudioLowerVolume" =
              spawnShWithProps allowWhenLocked "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
            "XF86AudioMute" = spawnShWithProps allowWhenLocked "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "XF86AudioMicMute" =
              spawnShWithProps allowWhenLocked "${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

            "XF86AudioPlay" = spawnShWithProps allowWhenLocked "${playerctl} play-pause";
            "XF86AudioStop" = spawnShWithProps allowWhenLocked "${playerctl} stop";
            "XF86AudioPrev" = spawnShWithProps allowWhenLocked "${playerctl} previous";
            "XF86AudioNext" = spawnShWithProps allowWhenLocked "${playerctl} next";

            "XF86MonBrightnessUp" = spawnWithProps allowWhenLocked [
              brightnessctl
              "--class=backlight"
              "set"
              "+10%"
            ];
            "XF86MonBrightnessDown" = spawnWithProps allowWhenLocked [
              brightnessctl
              "--class=backlight"
              "set"
              "10%-"
            ];

            "Mod+O" = withProps { repeat = false; } "toggle-overview";
            "Mod+Q" = withProps { repeat = false; } "close-window";

            "Mod+Left" = noArgs "focus-column-left";
            "Mod+Down" = noArgs "focus-window-down";
            "Mod+Up" = noArgs "focus-window-up";
            "Mod+Right" = noArgs "focus-column-right";
            "Mod+H" = noArgs "focus-column-left";
            "Mod+J" = noArgs "focus-window-down";
            "Mod+K" = noArgs "focus-window-up";
            "Mod+L" = noArgs "focus-column-right";

            "Mod+Ctrl+Left" = noArgs "move-column-left";
            "Mod+Ctrl+Down" = noArgs "move-window-down";
            "Mod+Ctrl+Up" = noArgs "move-window-up";
            "Mod+Ctrl+Right" = noArgs "move-column-right";
            "Mod+Ctrl+H" = noArgs "move-column-left";
            "Mod+Ctrl+J" = noArgs "move-window-down";
            "Mod+Ctrl+K" = noArgs "move-window-up";
            "Mod+Ctrl+L" = noArgs "move-column-right";

            "Mod+Home" = noArgs "focus-column-first";
            "Mod+End" = noArgs "focus-column-last";
            "Mod+Ctrl+Home" = noArgs "move-column-to-first";
            "Mod+Ctrl+End" = noArgs "move-column-to-last";

            "Mod+Shift+Left" = noArgs "focus-monitor-left";
            "Mod+Shift+Down" = noArgs "focus-monitor-down";
            "Mod+Shift+Up" = noArgs "focus-monitor-up";
            "Mod+Shift+Right" = noArgs "focus-monitor-right";
            "Mod+Shift+H" = noArgs "focus-monitor-left";
            "Mod+Shift+J" = noArgs "focus-monitor-down";
            "Mod+Shift+K" = noArgs "focus-monitor-up";
            "Mod+Shift+L" = noArgs "focus-monitor-right";

            "Mod+Shift+Ctrl+Left" = noArgs "move-column-to-monitor-left";
            "Mod+Shift+Ctrl+Down" = noArgs "move-column-to-monitor-down";
            "Mod+Shift+Ctrl+Up" = noArgs "move-column-to-monitor-up";
            "Mod+Shift+Ctrl+Right" = noArgs "move-column-to-monitor-right";
            "Mod+Shift+Ctrl+H" = noArgs "move-column-to-monitor-left";
            "Mod+Shift+Ctrl+J" = noArgs "move-column-to-monitor-down";
            "Mod+Shift+Ctrl+K" = noArgs "move-column-to-monitor-up";
            "Mod+Shift+Ctrl+L" = noArgs "move-column-to-monitor-right";

            "Mod+Page_Down" = noArgs "focus-workspace-down";
            "Mod+Page_Up" = noArgs "focus-workspace-up";
            "Mod+U" = noArgs "focus-workspace-down";
            "Mod+I" = noArgs "focus-workspace-up";
            "Mod+Ctrl+Page_Down" = noArgs "move-column-to-workspace-down";
            "Mod+Ctrl+Page_Up" = noArgs "move-column-to-workspace-up";
            "Mod+Ctrl+U" = noArgs "move-column-to-workspace-down";
            "Mod+Ctrl+I" = noArgs "move-column-to-workspace-up";

            "Mod+Shift+Page_Down" = noArgs "move-workspace-down";
            "Mod+Shift+Page_Up" = noArgs "move-workspace-up";
            "Mod+Shift+U" = noArgs "move-workspace-down";
            "Mod+Shift+I" = noArgs "move-workspace-up";

            "Mod+WheelScrollDown" = withProps { cooldown-ms = 150; } "focus-workspace-down";
            "Mod+WheelScrollUp" = withProps { cooldown-ms = 150; } "focus-workspace-up";
            "Mod+Ctrl+WheelScrollDown" = withProps { cooldown-ms = 150; } "move-column-to-workspace-down";
            "Mod+Ctrl+WheelScrollUp" = withProps { cooldown-ms = 150; } "move-column-to-workspace-up";

            "Mod+WheelScrollRight" = noArgs "focus-column-right";
            "Mod+WheelScrollLeft" = noArgs "focus-column-left";
            "Mod+Ctrl+WheelScrollRight" = noArgs "move-column-right";
            "Mod+Ctrl+WheelScrollLeft" = noArgs "move-column-left";

            "Mod+Shift+WheelScrollDown" = noArgs "focus-column-right";
            "Mod+Shift+WheelScrollUp" = noArgs "focus-column-left";
            "Mod+Ctrl+Shift+WheelScrollDown" = noArgs "move-column-right";
            "Mod+Ctrl+Shift+WheelScrollUp" = noArgs "move-column-left";

            "Mod+1" = withArg "focus-workspace" "terminal";
            "Mod+2" = withArg "focus-workspace" "browser";
            "Mod+3" = withArg "focus-workspace" "social";
            "Mod+4" = withArg "focus-workspace" 4;
            "Mod+5" = withArg "focus-workspace" 5;
            "Mod+6" = withArg "focus-workspace" 6;
            "Mod+7" = withArg "focus-workspace" 7;
            "Mod+8" = withArg "focus-workspace" 8;
            "Mod+9" = withArg "focus-workspace" 9;
            "Mod+Ctrl+1" = withArg "move-column-to-workspace" "terminal";
            "Mod+Ctrl+2" = withArg "move-column-to-workspace" "browser";
            "Mod+Ctrl+3" = withArg "move-column-to-workspace" "social";
            "Mod+Ctrl+4" = withArg "move-column-to-workspace" 4;
            "Mod+Ctrl+5" = withArg "move-column-to-workspace" 5;
            "Mod+Ctrl+6" = withArg "move-column-to-workspace" 6;
            "Mod+Ctrl+7" = withArg "move-column-to-workspace" 7;
            "Mod+Ctrl+8" = withArg "move-column-to-workspace" 8;
            "Mod+Ctrl+9" = withArg "move-column-to-workspace" 9;

            "Mod+BracketLeft" = noArgs "consume-or-expel-window-left";
            "Mod+BracketRight" = noArgs "consume-or-expel-window-right";
            "Mod+Comma" = noArgs "consume-window-into-column";
            "Mod+Period" = noArgs "expel-window-from-column";

            "Mod+R" = noArgs "switch-preset-column-width";
            "Mod+Shift+R" = noArgs "switch-preset-column-width-back";
            "Mod+Ctrl+Shift+R" = noArgs "switch-preset-window-height";
            "Mod+Ctrl+R" = noArgs "reset-window-height";
            "Mod+F" = noArgs "maximize-column";
            "Mod+Shift+F" = noArgs "fullscreen-window";
            "Mod+M" = noArgs "maximize-window-to-edges";
            "Mod+Ctrl+F" = noArgs "expand-column-to-available-width";
            "Mod+C" = noArgs "center-column";
            "Mod+Ctrl+C" = noArgs "center-visible-columns";

            "Mod+Minus" = withArg "set-column-width" "-10%";
            "Mod+Equal" = withArg "set-column-width" "+10%";
            "Mod+Shift+Minus" = withArg "set-window-height" "-10%";
            "Mod+Shift+Equal" = withArg "set-window-height" "+10%";

            "Mod+V" = noArgs "toggle-window-floating";
            "Mod+Shift+V" = noArgs "switch-focus-between-floating-and-tiling";
            "Mod+W" = noArgs "toggle-column-tabbed-display";

            "Print" = noArgs "screenshot";
            "Ctrl+Print" = noArgs "screenshot-screen";
            "Alt+Print" = noArgs "screenshot-window";

            "Mod+Escape" = withProps { allow-inhibiting = false; } "toggle-keyboard-shortcuts-inhibit";
            "Mod+Shift+E" = noArgs "quit";
            "Ctrl+Alt+Delete" = noArgs "quit";
            "Mod+Shift+P" = noArgs "power-off-monitors";
          };
        };

        extraSettings = map namedWorkspace [
          "terminal"
          "browser"
          "social"
        ];
      };
    };
}
