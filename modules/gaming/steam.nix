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
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };

      environment.systemPackages = with pkgs; [
        mangohud
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

  flake.modules.homeManager.steam = _: {
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
