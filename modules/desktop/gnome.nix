_: {
  flake.modules.nixos.gnome =
    { pkgs, ... }:
    {
      services = {
        xserver = {
          enable = false;
          videoDrivers = [ "amdgpu" ];
          xkb = {
            layout = "us";
            variant = "intl";
          };
        };

        displayManager.gdm = {
          enable = true;
          wayland = true;
          autoSuspend = false;
        };

        desktopManager.gnome.enable = true;
        gnome.gnome-keyring.enable = true;
      };

      environment.gnome.excludePackages = with pkgs; [
        decibels
        epiphany
        geary
        gnome-connections
        gnome-console
        gnome-contacts
        gnome-logs
        gnome-maps
        gnome-music
        gnome-terminal
        gnome-tour
        gnome-user-docs
        gnome-user-share
        showtime
        simple-scan
        totem
        yelp
      ];

      environment.systemPackages = with pkgs; [
        gnomeExtensions.appindicator
        gnomeExtensions.astra-monitor
        gnomeExtensions.bluetooth-battery-meter
        gnomeExtensions.clipboard-indicator
        gnomeExtensions.dash-to-panel
        gnomeExtensions.simpleweather
        gnome-extension-manager
        gnome-shell-extensions
        gnome-tweaks
        nautilus
        resources
      ];
    };

  flake.modules.homeManager.gnome =
    { pkgs, lib, ... }:
    {
      dconf.settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = [
            "Bluetooth-Battery-Meter@maniacx.github.com"
            "appindicatorsupport@rgcjonas.gmail.com"
            "clipboard-indicator@tudmotu.com"
            "dash-to-panel@jderose9.github.com"
            "monitor@astraext.github.io"
            "user-theme@gnome-shell-extensions.gcampax.github.com"
          ];
          favorite-apps = [
            "brave-browser.desktop"
            "com.mitchellh.ghostty.desktop"
            "dev.zed.Zed.desktop"
            "org.telegram.desktop.desktop"
            "steam.desktop"
          ];
        };

        "org/gnome/desktop/wm/preferences" = {
          button-layout = "appmenu:minimize,maximize,close";
        };

        "org/gnome/desktop/input-sources" = {
          sources = [
            (lib.gvariant.mkTuple [
              "xkb"
              "us+alt-intl"
            ])
          ];
        };

        "org/gnome/desktop/interface" = {
          force = true;
          color-scheme = "prefer-dark";
          document-font-name = "IBM Plex Sans 10";
          font-name = "IBM Plex Sans 10";
          gtk-theme = "adw-gtk3-dark";
          icon-theme = "Tela-dark";
          monospace-font-name = "IBM Plex Mono 11";
        };

        "org/gnome/desktop/peripherals/mouse" = {
          accel-profile = "flat";
          speed = 1.0;
        };

        "org/gnome/mutter" = {
          experimental-features = [ ];
        };

        "org/gnome/nautilus/list-view" = {
          default-column-order = [
            "name"
            "size"
            "type"
            "owner"
            "group"
            "permissions"
            "date_modified"
            "date_accessed"
            "date_created"
            "recency"
            "detailed_type"
          ];
          default-visible-columns = [
            "name"
            "size"
            "type"
            "date_modified"
          ];
          default-zoom-level = "medium";
        };

        "org/gnome/shell/extensions/clipboard-indicator" = {
          history-size = 100;
          move-item-first = true;
        };

        "org/gnome/nautilus/preferences" = {
          default-folder-viewer = "list-view";
          migrated-gtk-settings = true;
          search-filter-time-type = "last_modified";
        };

        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
          night-light-schedule-from = "18.0";
          night-light-schedule-to = "06.0";
          night-light-temperature = lib.gvariant.mkUint32 4700;
        };

        "org/gnome/desktop/peripherals/keyboard" = {
          delay = lib.gvariant.mkUint32 300;
          repeat-interval = lib.gvariant.mkUint32 20;
        };

        "org/gnome/shell/extensions/dash-to-panel" = {
          panel-positions = ''{"0":"BOTTOM"}'';
          panel-sizes = ''{"0":48}'';
          taskbar-position = "CENTERED_MONITOR";
          show-appmenu-btn = false;
          show-show-apps-button = true;
        };
      };

      gtk = {
        enable = true;
        colorScheme = "dark";

        cursorTheme = {
          package = pkgs.apple-cursor;
          name = "macOS";
        };

        font = {
          name = "IBM Plex Sans";
          size = 10;
        };

        iconTheme = {
          name = "Tela-dark";
          package = pkgs.tela-icon-theme;
        };

        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };

      };
    };
}
