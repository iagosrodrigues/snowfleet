{ inputs, ... }:
let
  username = "iago";
in
{
  flake.modules.nixos.${username} =
    { pkgs, ... }:
    {
      users.users.${username} = {
        isNormalUser = true;
        description = "Iago Sousa Rodrigues";
        extraGroups = [
          "adbusers"
          "docker"
          "input"
          "libvirtd"
          "networkmanager"
          "render"
          "video"
          "wheel"
        ];
        # Login shell is managed by home-manager (programs.fish.enable)
        # Setting shell here would require fish in system packages
      };

      home-manager.users.${username} =
        { pkgs, ... }:
        {
          programs.home-manager.enable = true;

          programs.brave.enable = true;
          programs.mpv.enable = true;
          programs.tmux.enable = true;
          programs.fish.enable = true;

          home = {
            inherit username;
            homeDirectory = "/home/${username}";
            stateVersion = "25.05";

            pointerCursor = {
              gtk.enable = true;
              name = "macOS";
              package = pkgs.apple-cursor;
              size = 48;
            };

            packages = with pkgs; [
              libreoffice-still
              _1password-cli
              android-tools
              (btop.overrideAttrs (old: {
                cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DBTOP_GPU=ON" ];
              }))
              cargo
              clang
              davinci-resolve-studio
              discord
              eza
              fd
              ffmpeg
              fuzzel
              gh
              inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode
              jetbrains.idea
              jujutsu
              lmstudio
              nil
              nixd
              nixfmt
              nodejs
              p7zip
              ripgrep
              rocmPackages.rocm-smi
              rocmPackages.rocminfo
              statix
              telegram-desktop
              transmission_4-gtk
              unixtools.xxd
              unzip
              wl-clipboard
              xwayland-satellite
            ];

            sessionVariables = {
              EDITOR = "nvim";
              # Wayland compatibility
              NIXOS_OZONE_WL = "1";
              MOZ_ENABLE_WAYLAND = "1";
              QT_QPA_PLATFORM = "wayland";
              SDL_VIDEODRIVER = "wayland";
              GDK_BACKEND = "wayland";
              GTK_IM_MODULE = "simple";
              QT_IM_MODULE = "simple";
            };
          };

          fonts.fontconfig.enable = true;

          systemd.user.sessionVariables = {
            EDITOR = "nvim";
          };
        };
    };
}
