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
    {
      home.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = "${config.home.homeDirectory}/.steam/root/compatibilitytools.d";

      home.persistence."/persist".directories = [
        ".local/share/Steam"
        ".cache/mesa_shader_cache"
      ];
    };
}
