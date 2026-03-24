_: {
  flake.modules.homeManager.obs-studio = _: {
    home.persistence."/persist".directories = [
      ".config/obs-studio"
    ];
  };
}
