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
        gwenview
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
    { ... }:
    {
      imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

      programs.plasma = {
        enable = true;

        workspace = {
          lookAndFeel = "org.kde.breezedark.desktop";
          colorScheme = "BreezeDark";
          iconTheme = "Papirus-Dark";
          cursor = {
            theme = "macOS";
            size = 24;
          };
        };

        panels = [
          {
            location = "bottom";
            floating = true;
            widgets = [
              "org.kde.plasma.kickoff"
              "org.kde.plasma.icontasks"
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

      # KDE Plasma state that must survive reboots
      home.persistence."/persist".directories = [
        ".config/kde.org"
        ".config/kdedefaults"
        ".config/plasma-org.kde.plasma.desktop-appletsrc"
        ".local/share/kscreen"
        ".local/share/plasma"
        ".local/share/kwalletd"
        ".local/share/recently-used.xbel"
      ];
    };
}
