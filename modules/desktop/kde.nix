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
        # Cursor (matches programs.plasma.workspace.cursor below). Links the
        # theme into ~/.icons and ~/.local/share/icons: sandboxes that share
        # $HOME but not /etc/profiles (Steam's pressure-vessel runtime, umu)
        # cannot see the profile copy and fall back to another theme.
        # Theme ships nominal sizes 24-120 (incl. 64); 64 renders without rescaling.
        pointerCursor = {
          enable = true;
          package = pkgs.macos-goldengate-cursor;
          name = "macOS-GoldenGate";
          size = 30;
        };

        sessionVariables = {
          # Wayland compatibility for Electron / Firefox / Qt / GTK apps
          NIXOS_OZONE_WL = "1";
          MOZ_ENABLE_WAYLAND = "1";
          QT_QPA_PLATFORM = "wayland";
          GDK_BACKEND = "wayland";
        };

        file.".XCompose".text = ''
          include "%L"

          <dead_acute> <c> : "ç" ccedilla
          <dead_acute> <C> : "Ç" Ccedilla
        '';

        # KDE Plasma state that must survive reboots.
        # NOTE: panel layout, taskbar launchers, screen-lock and effects are
        # declared below via plasma-manager, so they are reapplied on every boot
        # and do NOT need persistence. Only list runtime-generated state here.
        persistence."/persist".directories = [
          ".config/kde.org"
          ".config/kdedefaults"
          ".local/share/baloo" # file-search index; rebuilt from scratch on tmpfs otherwise
          ".local/share/kscreen"
          ".local/share/plasma"
          ".local/share/kwalletd"
          # xdg-desktop-portal permission store: remembers "Allow restoring on
          # future sessions" grants (remote desktop, screencast, …).
          ".local/share/flatpak/db"
        ];
        # Global shortcuts, incl. those apps register through the portal
        # (1Password). Symlink, not bind mount: KConfig saves by rename.
        persistence."/persist".files = [
          {
            file = ".config/kglobalshortcutsrc";
            method = "symlink";
          }
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
          widgetStyle = "breeze";
          iconTheme = "breeze-dark";
          cursor = {
            theme = "macOS-GoldenGate";
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

          touchpads = [
            {
              enable = true;
              name = "Apple Inc. Magic Trackpad";
              vendorId = "05ac";
              productId = "0265";
              naturalScroll = false;
            }
            {
              enable = true;
              name = "Apple Inc. Magic Trackpad";
              vendorId = "004c";
              productId = "0265";
              naturalScroll = false;
            }
          ];

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
