_: {
  flake.modules.homeManager.davinci-resolve =
    { pkgs, ... }:
    {
      home = {
        packages = [ pkgs.davinci-resolve-studio ];
        persistence."/persist".directories = [
          ".local/share/DaVinciResolve"
        ];
        persistence."/persist".files = [
          ".cache/DaVinci_Resolve_Welcome"
        ];
      };
    };
}
