_: {
  flake.modules.homeManager.organice =
    { pkgs, ... }:
    {
      home.packages = [
        # inputs.organice.packages.${system}.default
        # Proton Drive transport daemon; organice resolves it by name on PATH.
        # Shares the stock proton-drive CLI's login session (see
        # modules/apps/proton-drive-cli.nix persistence dirs + keyring).
        pkgs.organice-proton-sidecar
      ];
    };

  # Keep app data mounted even while the package module is disabled.
  flake.modules.homeManager.organice-persistence = {
    home.persistence."/persist".directories = [
      ".local/share/organice"
      ".cache/migraphx"
    ];
  };
}
