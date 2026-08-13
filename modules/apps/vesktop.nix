_: {
  flake.modules.homeManager.vesktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.vesktop ];

      home.persistence."/persist".directories = [
        ".config/vesktop"
      ];
    };
}
