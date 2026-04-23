_:
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
          mpv.enable = true;
          fish.enable = true;
        };

        home = {
          inherit username;
          homeDirectory = "/home/${username}";
          stateVersion = "25.05";

          # macos-tahoe-cursor is only present when the out-of-tree zip is
          # visible to the overlay (i.e. with --impure). Fall back to
          # apple-cursor so pure evaluations still succeed.
          pointerCursor = {
            gtk.enable = true;
            name = if pkgs ? macos-tahoe-cursor then "MacOS-Tahoe-Cursor" else "macOS";
            package = pkgs.macos-tahoe-cursor or pkgs.apple-cursor;
            size = 48;
          };

          packages = with pkgs; [
            _1password-cli
            (btop.override { rocmSupport = true; })
            android-tools
            cargo
            clang
            discord
            eza
            fd
            ffmpeg
            fuzzel
            gemini-cli
            gh
            gnupg
            jq
            jujutsu
            libreoffice-still
            nil
            nixd
            nixfmt
            nodejs
            oversteer
            p7zip
            pkgs.claude-code
            pkgs.llm-agents.codex
            pkgs.llm-agents.crush
            proton-vpn
            python3
            ripgrep
            rocmPackages.rocm-smi
            rocmPackages.rocminfo
            statix
            telegram-desktop
            transmission_4-gtk
            unixtools.xxd
            unzip
            vscode
            wl-clipboard
            xwayland-satellite
          ];

          sessionVariables = {
            EDITOR = "nvim";
            # Wayland compatibility
            NIXOS_OZONE_WL = "1";
            MOZ_ENABLE_WAYLAND = "1";
            QT_QPA_PLATFORM = "wayland";
            GDK_BACKEND = "wayland";
            GTK_IM_MODULE = "ibus";
            QT_IM_MODULE = "ibus";
            STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/iago/.steam/root/compatibilitytools.d";
          };
        };

        fonts.fontconfig.enable = true;

        systemd.user.sessionVariables = {
          EDITOR = "nvim";
        };
      };
  };
}
