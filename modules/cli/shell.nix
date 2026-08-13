_: {
  # NixOS side: shells available system-wide (login shell stays fish via home-manager)
  flake.modules.nixos.shell =
    { pkgs, ... }:
    {
      environment = {
        shells = [
          pkgs.fish
          pkgs.nushell
        ];
        systemPackages = [
          pkgs.fish
          pkgs.nushell
          pkgs.neovim
        ];
      };
    };

  # Home-manager side: fish (login/SSH), nushell (Ghostty), starship, zoxide
  flake.modules.homeManager.shell =
    { lib, pkgs, ... }:
    let
      ezaAliases = {
        # ls = "eza --icons=always";
        # ll = "eza --icons=always -l";
        # la = "eza --icons=always -la";
      };

      nixRebuildAliases = {
        nrs = "nixos-rebuild switch --sudo --flake .#(hostname) &| ${lib.getExe pkgs.nix-output-monitor}";
        nrt = "nixos-rebuild test --sudo --flake .#(hostname) &| ${lib.getExe pkgs.nix-output-monitor}";
      };

      nushellNixRebuildAliases = {
        nrs = "nixos-rebuild switch --sudo --flake .#(hostname) | ${lib.getExe pkgs.nix-output-monitor}";
        nrt = "nixos-rebuild test --sudo --flake .#(hostname) | ${lib.getExe pkgs.nix-output-monitor}";
      };
    in
    {
      home.sessionVariables.EDITOR = "nvim";
      systemd.user.sessionVariables.EDITOR = "nvim";

      programs = {
        fish = {
          enable = true;
          shellAliases = ezaAliases // nixRebuildAliases;
        };

        nushell = {
          enable = true;
          shellAliases =
            ezaAliases
            // nushellNixRebuildAliases
            // {
              # Drop into fish when a script or habit still expects it
              fish = "fish";
            };
          extraEnv = ''
            # PATH is already a list here (nushell's default ENV_CONVERSIONS)
            $env.PATH = ($env.PATH | prepend $"($env.HOME)/.cargo/bin" | uniq)
          '';
          settings = {
            show_banner = false;
            history = {
              file_format = "sqlite";
              sync_on_enter = true;
              isolation = true;
            };
          };
        };

        starship = {
          enable = true;
          enableNushellIntegration = true;
        };

        zoxide = {
          enable = true;
          enableNushellIntegration = true;
        };
      };

      home.persistence."/persist" = {
        directories = [
          ".local/share/fish"
          ".local/share/zoxide"
        ];
        # Persist history only — not the whole dir, so HM can deploy config.nu/env.nu
        files = [
          ".config/nushell/history.txt"
          ".config/nushell/history.sqlite3"
          ".config/nushell/history.sqlite3-wal"
          ".config/nushell/history.sqlite3-shm"
        ];
      };
    };
}
