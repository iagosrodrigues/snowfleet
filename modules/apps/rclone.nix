_: {
  flake.modules.homeManager.rclone = _: {
    programs.rclone.enable = true;

    home.persistence."/persist".directories = [
      ".config/rclone"
    ];
  };
}
