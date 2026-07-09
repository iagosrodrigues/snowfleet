_: {
  flake.modules.homeManager.discord =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.discord ];

      home.persistence."/persist".directories = [
        ".config/discord"
      ];
    };
}
