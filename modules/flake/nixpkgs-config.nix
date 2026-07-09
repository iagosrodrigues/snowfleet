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
        (final: prev: {
          code-cursor = final.callPackage ../../pkgs/code-cursor.nix {
            inherit (prev) code-cursor fish;
          };
          claude-desktop = final.callPackage ../../pkgs/claude-desktop.nix { };
          sweet-cursors = final.callPackage ../../pkgs/sweet-cursors.nix { };
          # zed-editor = final.callPackage ../../pkgs/zed-editor.nix { };
        })
      ];
    };
  };
}
