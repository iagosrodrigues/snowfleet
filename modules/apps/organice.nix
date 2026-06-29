{ inputs, ... }:
{
  flake.modules.homeManager.organice =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
    in
    {
      home.packages = [
        inputs.organice.packages.${system}.default
      ];

      home.persistence."/persist".directories = [
        ".local/share/organice"
        ".cache/migraphx"
      ];
    };
}
