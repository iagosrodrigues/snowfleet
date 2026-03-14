_: {
  flake.modules.homeManager.ghostty = _: {
    programs.ghostty = {
      enable = true;
      enableFishIntegration = true;

      settings = {
        background-opacity = 1;
        command = "/etc/profiles/per-user/iago/bin/fish";
        font-family = "Jetbrains Mono";
        font-size = 18;
        theme = "Gruvbox Material";
      };
    };
  };
}
