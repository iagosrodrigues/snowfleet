_: {
  flake.modules.homeManager.google-chrome = _: {
    programs.google-chrome.enable = true;

    home.persistence."/persist".directories = [
      ".config/google-chrome"
    ];
  };
}
