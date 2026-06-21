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
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA+9boyw9MLSLia/aW9DQFD4NLpMc6mlG81FpIwSdkcu Chave principal"
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

          pointerCursor = {
            gtk.enable = true;
            name = "Breeze_Light";
            package = pkgs.kdePackages.breeze;
            size = 30;
          };

          packages = with pkgs; [
            # immersed
            (btop.override { rocmSupport = true; })
            _1password-cli
            android-tools
            cargo
            clang
            code-cursor
            discord
            eza
            fd
            ffmpeg
            fuzzel
            gemini-cli
            gh
            gnupg
            jq
            libreoffice-still
            nil
            nixd
            nixfmt
            nodejs
            oversteer
            p7zip
            pkgs.llm-agents.claude-code
            pkgs.llm-agents.codex
            pkgs.llm-agents.crush
            proton-vpn
            python3
            ripgrep
            rocmPackages.rocm-smi
            rocmPackages.rocminfo
            statix
            telegram-desktop
            # transmission_4-gtk ships an unwrapped GTK3 binary; without the
            # GTK3 gsettings schemas on XDG_DATA_DIRS its file-chooser teardown
            # hits a fatal g_error ("org.gtk.Settings.FileChooser not installed")
            # and aborts. Wrap it to inject the schema dir.
            (symlinkJoin {
              name = "transmission_4-gtk-wrapped";
              paths = [ transmission_4-gtk ];
              nativeBuildInputs = [ makeWrapper ];
              postBuild = ''
                wrapProgram $out/bin/transmission-gtk \
                  --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}"
              '';
            })
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
