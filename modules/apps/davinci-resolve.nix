_: {
  flake.modules.homeManager.davinci-resolve =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.davinci-resolve-studio ];

      home.persistence."/persist".directories = [
        ".local/share/DaVinciResolve"
      ];

      home.persistence."/persist".files = [
        ".cache/DaVinci_Resolve_Welcome"
      ];
    };
}
