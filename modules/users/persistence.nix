_: {
  flake.modules.homeManager.user-persistence = {
    home.persistence."/persist".directories = [
      "Downloads"
      "Projects"
      ".icons"
      ".gnupg"
      ".local/share/nix"
    ];
  };
}
