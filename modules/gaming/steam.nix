_: {
  flake.modules.nixos.steam =
    { pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        # Offer an isolated Steam session at the display manager so game-triggered
        # GPU resets do not also kill the day-to-day desktop session.
        gamescopeSession.enable = true;
        protontricks.enable = true;
      };

      environment.systemPackages = with pkgs; [
        mangohud
        protonup-ng
        umu-launcher
        heroic
      ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          libva
          rocmPackages.clr.icd
        ];
      };
    };

  flake.modules.homeManager.steam =
    { config, ... }:
    let
      # umu-launcher only scans $XDG_DATA_HOME/Steam/compatibilitytools.d and
      # $XDG_DATA_HOME/umu/compatibilitytools. Keeping every Proton build in the
      # former is what makes `umu-run` resolve the same set `protonup -l` prints.
      compatTools = "${config.xdg.dataHome}/Steam/compatibilitytools.d";
    in
    {
      home.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = compatTools;

      # protonup-ng defaults to ~/.steam/root/compatibilitytools.d, which is wiped
      # on boot and invisible to umu. Heroic has the same trap: its
      # defaultSteamPath setting must be ~/.local/share/Steam (stored in the
      # persisted ~/.config/heroic/config.json), because it discovers Proton
      # builds via <steamPath>/steamapps/libraryfolders.vdf and falls back to
      # scanning only /usr/share/steam when that file is missing. The trailing slash is load-bearing: protonup
      # concatenates installdir with the version name rather than joining paths.
      xdg.configFile."protonup/config.ini".text = ''
        [protonup]
        installdir = ${compatTools}/
      '';

      home.persistence."/persist".directories = [
        ".local/share/Steam"
        ".cache/mesa_shader_cache"
        # umu's Steam Linux Runtime (sniper) and its own compat-tools dir.
        ".local/share/umu"
        # Heroic keeps store logins, the installed-games database and its
        # bundled legendary/gogdl/nile config under a single Electron dir.
        ".config/heroic"
        # Heroic's defaultInstallPath — game files and their wine prefixes.
        "Games"
      ];
    };
}
