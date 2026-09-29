_: {
  flake.modules.homeManager.user-persistence = {
    home.persistence."/persist".directories = [
      ".cache/nix"
      ".cache/nvim"
      ".config/knowcore"
      ".config/nvim"
      ".gnupg"
      ".icons"
      ".local/share/fonts"
      ".local/share/nix"
      ".local/share/nvim"
      ".local/share/snowfleet"
      ".local/state/nvim"
      "Downloads"
      "Projects"
    ];

    # ~/.cache lives on the root tmpfs: age out what is not persisted.
    # tmpfiles does not descend into the persisted bind mounts inside it.
    systemd.user.tmpfiles.rules = [ "e %h/.cache - - - 7d" ];
  };
}
