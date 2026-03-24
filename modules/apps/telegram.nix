_: {
  flake.modules.homeManager.telegram = _: {
    home.persistence."/persist".directories = [
      ".local/share/TelegramDesktop"
    ];
  };
}
