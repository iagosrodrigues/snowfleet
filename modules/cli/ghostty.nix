_: {
  flake.modules.homeManager.ghostty =
    { lib, pkgs, ... }:
    {
      programs.ghostty = {
        enable = true;

        settings = {
          background-opacity = 1;
          command = lib.getExe pkgs.nushell;
          font-family = [
            "Anthrosevka Mono"
            "Symbols Nerd Font"
          ];
          font-size = 18;
          theme = "Light Owl";
        };
      };
    };
}
