{ inputs, ... }:
{
  flake.modules.homeManager.delta =
    { pkgs, ... }:
    {
      home.packages = [ inputs.delta.packages.${pkgs.stdenv.hostPlatform.system}.delta ];

      home.persistence."/persist".directories = [
        ".config/delta"
        ".local/share/delta"
      ];
    };
}
