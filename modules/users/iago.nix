{ inputs, ... }:
let
  username = "iago";
in
{
  flake.modules.nixos.${username} = _: {
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
        programs = {
          home-manager.enable = true;
          brave.enable = true;
          mpv.enable = true;
          tmux.enable = true;
          fish.enable = true;
        };

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
            (btop.overrideAttrs (old: {
              cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DBTOP_GPU=ON" ];
            }))
            _1password-cli
            android-tools
            cargo
            clang
            claude-code
            codex
            davinci-resolve-studio
            discord
            eza
            fd
            ffmpeg
            fuzzel
            gemini-cli
            gh
            inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode
            jetbrains.idea
            jujutsu
            libreoffice-still
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
