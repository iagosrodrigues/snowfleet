_: {
  flake.modules.homeManager.lmstudio = _: {
    home.persistence."/persist".directories = [
      ".lmstudio"
      ".config/LM Studio"
    ];
  };
}
