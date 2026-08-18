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

      home.persistence."/persist".directories = [
        ".local/share/organice"
        ".cache/migraphx"
      ];
    };
}
