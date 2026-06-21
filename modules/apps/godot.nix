_: {
  flake.modules.homeManager.godot =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.godot ];

      home.persistence."/persist".directories = [
        ".config/godot"
        ".local/share/godot"
      ];
    };
}
