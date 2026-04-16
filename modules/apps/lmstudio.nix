_: {
  flake.modules.homeManager.lmstudio =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.lmstudio ];

      home.persistence."/persist".directories = [
        ".lmstudio"
        ".config/LM Studio"
      ];
    };
}
