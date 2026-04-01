_: {
  flake.modules.homeManager.ghostty = _: {
    programs.ghostty = {
      enable = true;
      enableFishIntegration = true;

      settings = {
        background-opacity = 1;
        command = "/etc/profiles/per-user/iago/bin/fish";
        font-family = "Agave";
        font-size = 23;
        theme = "Gruvbox Material";
      };
    };
  };
}
