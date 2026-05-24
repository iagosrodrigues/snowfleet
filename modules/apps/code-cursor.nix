_: {
  flake.modules.homeManager.code-cursor = _: {
    home.persistence."/persist".directories = [
      ".config/Cursor"
      ".cursor"
    ];
  };
}
