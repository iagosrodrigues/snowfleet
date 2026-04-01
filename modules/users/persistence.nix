_: {
  flake.modules.homeManager.user-persistence = {
    home.persistence."/persist".directories = [
      ".config/nvim"
      ".gnupg"
      ".icons"
      ".local/share/nix"
      "Downloads"
      "Projects"
    ];
  };
}
