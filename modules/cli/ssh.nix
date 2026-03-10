_: {
  flake.modules.homeManager.ssh = _: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks."*" = {
        identityAgent = "~/.1password/agent.sock";
      };
    };
  };
}
