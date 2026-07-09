_: {
  flake.modules.homeManager.vscode = _: {
    home.persistence."/persist".directories = [
      ".config/Code"
      ".vscode"
    ];
  };
}
