_: {
  flake.modules.homeManager.user-persistence = {
    home.persistence."/persist".directories = [
      ".cache/nvim"
      ".config/knowcore"
      ".config/nvim"
      ".gnupg"
      ".icons"
      ".local/share/fonts"
      ".local/share/nix"
      ".local/share/nvim"
      ".local/share/organice"
      ".local/share/snowfleet"
      ".local/state/nvim"
      "Downloads"
      "Projects"
    ];
  };
}
