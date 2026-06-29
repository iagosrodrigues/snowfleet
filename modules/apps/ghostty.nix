_: {
  flake.modules.homeManager.ghostty =
    { lib, pkgs, ... }:
    {
      programs.ghostty = {
        enable = true;

        settings = {
          background-opacity = 1;
          command = lib.getExe pkgs.nushell;
          font-family = "MonoLisaCode";
          font-size = 16;
          theme = "Gruvbox Material";
        };
      };
    };
}
