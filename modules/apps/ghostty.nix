_: {
  flake.modules.homeManager.ghostty =
    { lib, pkgs, ... }:
    {
      programs.ghostty = {
        enable = true;

        settings = {
          background-opacity = 1;
          command = lib.getExe pkgs.nushell;
          font-family = "Google Sans Code";
          font-size = 20;
          theme = "Gruvbox Material";
        };
      };
    };
}
