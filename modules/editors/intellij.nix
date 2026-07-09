_: {
  flake.modules.homeManager.intellij =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.jetbrains.idea ];

      home.persistence."/persist".directories = [
        ".config/JetBrains"
        ".java"
        ".jdks"
        ".local/share/JetBrains"
      ];
    };
}
