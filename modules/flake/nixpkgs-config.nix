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
          helium-browser = final.callPackage ../../pkgs/helium-browser.nix { };
          sweet-cursors = final.callPackage ../../pkgs/sweet-cursors.nix { };
          # Dead custom package lives in archive/pkgs/zed-editor.nix (stock programs.zed-editor is used).
        })
      ];
    };
  };
}
