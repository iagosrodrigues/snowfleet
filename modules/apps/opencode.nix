_: {
  flake.modules.homeManager.opencode = _: {
    home.persistence."/persist".directories = [
      ".config/opencode"
      ".cache/opencode"
      ".local/share/opencode"
    ];
  };
}
