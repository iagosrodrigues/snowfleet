{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.niri =
    { pkgs, ... }:
    {
      programs.niri = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
      };
    };

  perSystem =
    { pkgs, lib, ... }:
    {
      packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;

        settings = {
          prefer-no-csd = false;
          spawn-at-startup = [
            (lib.getExe pkgs.ashell)
          ];

          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

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
            "Mod+Return".spawn-sh = lib.getExe pkgs.ghostty;
          };
        };
      };
    };
}
