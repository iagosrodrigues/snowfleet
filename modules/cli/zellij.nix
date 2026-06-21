_: {
  flake.modules.homeManager.zellij =
    { pkgs, ... }:
    {
      programs.zellij = {
        enable = true;
        settings = {
          default_shell = "${pkgs.nushell}/bin/nu";
          theme = "catppuccin-mocha";
        };
      };
    };
}
