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
        # llm-agents.nix dropped overlays.default upstream (b195286, 2026-XX);
        # recreate it here so `pkgs.llm-agents.*` keeps working.
        (final: _prev: {
          llm-agents = inputs.llm-agents.packages.${final.stdenv.hostPlatform.system} or { };
        })
        (final: prev: {
          code-cursor = final.callPackage ../../pkgs/code-cursor.nix {
            inherit (prev) code-cursor fish;
          };
          claude-desktop = final.callPackage ../../pkgs/claude-desktop.nix { };
          helium-browser = final.callPackage ../../pkgs/helium-browser.nix { };
          macos-tahoe-cursor = final.callPackage ../../pkgs/macos-tahoe-cursor.nix { };
          # Dead custom package lives in archive/pkgs/zed-editor.nix (stock programs.zed-editor is used).
        })
      ];
    };
  };
}
