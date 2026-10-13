_: {
  flake.modules.homeManager.blender =
    { pkgs, ... }:
    {
      # ROCm build: Cycles renders on the AMD GPU via HIP (plain `blender` is CPU-only here).
      home.packages = [ pkgs.pkgsRocm.blender ];

      # Preferences, startup file, add-ons and extensions (per Blender version).
      home.persistence."/persist".directories = [ ".config/blender" ];
    };
}
