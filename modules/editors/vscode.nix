_: {
  flake.modules.homeManager.vscode =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.vscode ];

      home.persistence."/persist".directories = [
        ".config/Code"
        ".vscode"
      ];
    };
}
