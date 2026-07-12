_: {
  flake.modules.homeManager.mongodb-compass =
    { pkgs, lib, ... }:
    {
      home.packages = [
        (pkgs.mongodb-compass.overrideAttrs (
          old:
          lib.optionalAttrs (old ? buildCommand) {
            # Upstream buildCommand calls `wrapGAppsHook` directly, outside
            # fixupPhase, where genericBuild normally sets $output. Unset ->
            # "wrapGAppsHookHasRunForOutput: bad array subscript" in
            # wrap-gapps-hook.sh. Export it ourselves before the script runs.
            buildCommand = "output=out\n" + old.buildCommand;
          }
        ))
      ];

      home.persistence."/persist".directories = [
        ".config/MongoDB Compass"
        ".config/MongoDB Compass Community"
      ];
    };
}
