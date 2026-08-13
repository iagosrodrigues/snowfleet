{ inputs, ... }:
{
  flake.modules.nixos.kde =
    { pkgs, ... }:
    {
      services = {
        desktopManager.plasma6.enable = true;
        displayManager.plasma-login-manager.enable = true;
        xserver.enable = false;
      };

      environment.plasma6.excludePackages = with pkgs.kdePackages; [
        elisa
        khelpcenter
        kmail
        kontact
        konsole
        korganizer
        marble
        oxygen
        print-manager
      ];
    };

  flake.modules.homeManager.kde =
    { pkgs, ... }:
    {
      imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

      home = {
        packages = [
          pkgs.macos-tahoe-cursor
          # Fallback for icons candy-icons lacks
          pkgs.papirus-icon-theme
          pkgs.candy-icons
          # Application style (Qt style supporting QtQuick and QtWidgets)
          pkgs.kdePackages.union
        ];

        sessionVariables = {
          # Wayland compatibility for Electron / Firefox / Qt / GTK apps
          NIXOS_OZONE_WL = "1";
          MOZ_ENABLE_WAYLAND = "1";
          QT_QPA_PLATFORM = "wayland";
          GDK_BACKEND = "wayland";
          # Cursor (matches programs.plasma.workspace.cursor below)
          XCURSOR_THEME = "MacOS-Tahoe-Cursor";
          # Theme ships nominal sizes 32/48/64/96; 64 renders without rescaling.
          XCURSOR_SIZE = "64";
        };

        # KDE Plasma state that must survive reboots.
        # NOTE: panel layout, taskbar launchers, screen-lock and effects are
        # declared below via plasma-manager, so they are reapplied on every boot
        # and do NOT need persistence. Only list runtime-generated state here.
        persistence."/persist".directories = [
          ".config/kde.org"
          ".config/kdedefaults"
          ".local/share/kscreen"
          ".local/share/plasma"
          ".local/share/kwalletd"
        ];
        persistence."/persist".files = [
          ".local/share/recently-used.xbel"
        ];
      };

      programs.plasma = {
        enable = true;

        powerdevil = {
          AC = {
            autoSuspend.action = "nothing";
            turnOffDisplay.idleTimeout = "never";
            dimDisplay.enable = false;
          };
          battery = {
            turnOffDisplay.idleTimeout = "never";
            dimDisplay.enable = false;
          };
        };

        # Never lock the screen
        kscreenlocker = {
          autoLock = false;
          lockOnResume = false;
        };

        # Wobbly windows effect
        kwin.effects.wobblyWindows.enable = true;

        workspace = {
          lookAndFeel = "org.kde.breezedark.desktop";
          colorScheme = "BreezeDark";
          widgetStyle = "union";
          iconTheme = "candy-icons";
          cursor = {
            theme = "MacOS-Tahoe-Cursor";
            size = 64;
          };
        };

        panels = [
          {
            location = "bottom";
            floating = true;
            widgets = [
              "org.kde.plasma.kickoff"
              {
                iconTasks.launchers = [
                  "applications:com.mitchellh.ghostty.desktop"
                  "applications:dev.zed.Zed.desktop"
                ];
              }
              "org.kde.plasma.marginsseparator"
              "org.kde.plasma.systemtray"
              "org.kde.plasma.digitalclock"
            ];
          }
        ];

        input = {
          keyboard = {
            layouts = [
              {
                layout = "us";
                variant = "intl";
              }
            ];
            repeatDelay = 300;
            repeatRate = 50;
            numlockOnStartup = "on";
          };

          mice = [
            {
              enable = true;
              name = "Beken 2.4G Wireless Device";
              vendorId = "1d57";
              productId = "fa60";
              accelerationProfile = "none";
              acceleration = 1.0;
              naturalScroll = false;
            }
          ];
        };

        configFile = {
          "kdeglobals"."KDE"."SingleClick".value = false;
        };
      };
    };
}
