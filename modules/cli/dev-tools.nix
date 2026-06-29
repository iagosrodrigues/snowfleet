_: {
  flake.modules.homeManager.dev-tools = _: {
    programs = {
      bash.enable = true;
      direnv = {
        enable = true;
        mise.enable = true;
        nix-direnv.enable = true;
      };
      mise.enable = true;
    };

    home.persistence."/persist".directories = [
      ".local/share/direnv"
      ".cache/uv"
    ];

    home.persistence."/persist".files = [
      ".claude.json"
    ];
  };
}
