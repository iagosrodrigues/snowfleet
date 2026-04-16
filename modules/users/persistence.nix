_: {
  flake.modules.homeManager.user-persistence = {
    home.persistence."/persist".directories = [
      ".config/nvim"
      ".local/share/nvim"
      ".local/state/nvim"
      ".cache/nvim"
      ".gnupg"
      ".icons"
      ".local/share/nix"
      ".local/share/fonts"
      "Downloads"
      "Projects"
    ];
  };
}
