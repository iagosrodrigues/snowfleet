_: {
  flake.modules.homeManager.dev-tools = _: {
    programs.direnv = {
      enable = true;
      mise.enable = true;
      nix-direnv.enable = true;
    };

    programs.mise.enable = true;
  };
}
