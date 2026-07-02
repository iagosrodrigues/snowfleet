_: {
  flake.modules.homeManager.claude-desktop = _: {
    home.persistence."/persist".directories = [
      ".config/Claude"
    ];
  };
}
