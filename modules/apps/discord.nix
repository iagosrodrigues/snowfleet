_: {
  flake.modules.homeManager.discord = _: {
    home.persistence."/persist".directories = [
      ".config/discord"
    ];
  };
}
