_: {
  flake.modules.nixos.steam =
    { pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        # Offer an isolated Steam session in GDM so game-triggered GPU resets do
        # not also kill the day-to-day desktop session.
        gamescopeSession.enable = true;
        protontricks.enable = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };

      environment.systemPackages = with pkgs; [ mangohud ];

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
    ];
  };
}
