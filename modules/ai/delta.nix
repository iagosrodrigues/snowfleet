# Delta is installed from its upstream archive into ~/.local/delta.app.
_: {
  flake.modules.homeManager.delta = {
    home.persistence."/persist".directories = [
      ".config/delta"
      ".local/delta.app"
      ".local/share/delta"
      ".local/share/applications"
    ];
  };
}
