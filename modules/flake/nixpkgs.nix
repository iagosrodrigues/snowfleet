{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
  ];

  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  flake.modules.nixos.nixpkgs-config = {
    nixpkgs = {
      config.allowUnfree = true;
      overlays = [
        inputs.nur.overlays.default
        inputs.niri.overlays.niri
        inputs.llm-agents.overlays.default
        (
          final: prev:
          let
            # Third-party distfile that we do not redistribute. Resolve the zip
            # from $SNOWFLEET_DISTFILES_DIR (default ~/.local/share/snowfleet/
            # distfiles). Pure flake evaluation cannot read paths outside the
            # source tree, so building with the cursor requires --impure; in
            # pure mode macosTahoeCursorZip is null and the package is simply
            # not defined.
            distfilesDir =
              let
                env = builtins.getEnv "SNOWFLEET_DISTFILES_DIR";
                home = builtins.getEnv "HOME";
              in
              if env != "" then
                env
              else if home != "" then
                "${home}/.local/share/snowfleet/distfiles"
              else
                null;
            macosTahoeCursorZipPath =
              if distfilesDir == null then null else "${distfilesDir}/MacOS-Tahoe-Cursor.zip";
            macosTahoeCursorZip =
              if macosTahoeCursorZipPath != null && builtins.pathExists macosTahoeCursorZipPath then
                builtins.path {
                  path = macosTahoeCursorZipPath;
                  name = "MacOS-Tahoe-Cursor.zip";
                }
              else
                null;
          in
          {
            code-cursor = final.callPackage ../../pkgs/code-cursor.nix {
              inherit (prev) code-cursor;
            };
            claude-desktop = final.callPackage ../../pkgs/claude-desktop.nix { };
            sweet-cursors = final.callPackage ../../pkgs/sweet-cursors.nix { };
            # zed-editor = final.callPackage ../../pkgs/zed-editor.nix { };
          }
          // (
            if macosTahoeCursorZip == null then
              { }
            else
              {
                macos-tahoe-cursor = final.callPackage ../../pkgs/macos-tahoe-cursor.nix {
                  src = macosTahoeCursorZip;
                };
              }
          )
        )
      ];
    };
  };
}
