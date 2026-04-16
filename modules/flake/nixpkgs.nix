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
          final: _:
          let
            macosTahoeCursorZipPath = toString ../../pkgs/distfiles + "/MacOS-Tahoe-Cursor.zip";
            macosTahoeCursorZip =
              if builtins.pathExists macosTahoeCursorZipPath then
                builtins.path {
                  path = macosTahoeCursorZipPath;
                  name = "MacOS-Tahoe-Cursor.zip";
                }
              else
                null;
          in
          {
            sweet-cursors = final.callPackage ../../pkgs/sweet-cursors.nix { };
            claude-code = final.callPackage ../../pkgs/claude-code {
              inherit (final.llm-agents) wrapBuddy;
            };
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
