_: {
  flake.modules.homeManager.brave = _: {
    programs.brave.enable = true;

    home.persistence."/persist".directories = [
      ".config/BraveSoftware"
    ];
  };
}
