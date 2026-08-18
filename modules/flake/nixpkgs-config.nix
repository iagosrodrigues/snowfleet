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
      # vesktop bundles an older electron flagged insecure upstream; no fix
      # available yet from the vesktop/nixpkgs side.
      config.permittedInsecurePackages = [
        "electron-40.10.5"
      ];
      overlays = [
        inputs.nur.overlays.default
        inputs.niri.overlays.niri
        inputs.opencode.overlays.default
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
          proton-drive-cli = final.callPackage ../../pkgs/proton-drive-cli.nix { };
          zcode = final.callPackage ../../pkgs/zcode.nix { };
          organice-proton-sidecar = final.callPackage ../../pkgs/organice-proton-sidecar.nix {
            inherit (inputs) organice-proton-sidecar-bin;
          };
        })
        # GE-Proton pinned explicitly (nixpkgs lags and predates the
        # arch-suffixed asset names). Drop this override once nixpkgs ships
        # GE-Proton >= 11-5.
        (final: prev: {
          proton-ge-bin =
            (prev.proton-ge-bin.override { steamDisplayName = "GE-Proton11-5"; }).overrideAttrs
              (_: {
                version = "GE-Proton11-5";
                src = final.fetchzip {
                  url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton11-5/GE-Proton11-5-x86_64.tar.gz";
                  hash = "sha256-Sbyi5zXMhPIKSotvL5LEZ2dbDoLpXRcCyuY9TsnBnus=";
                };
              });
        })
      ];
    };
  };
}
