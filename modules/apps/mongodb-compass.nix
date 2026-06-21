_: {
  flake.modules.homeManager.mongodb-compass =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.mongodb-compass ];

      home.persistence."/persist".directories = [
        ".config/MongoDB Compass"
        ".config/MongoDB Compass Community"
      ];
    };
}
