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
        # Blackmagic re-uploaded the 21.1 archive without bumping the version,
        # so the fixed-output hash in nixpkgs is stale until
        # https://github.com/NixOS/nixpkgs/pull/562336 reaches nixos-unstable.
        # Re-evaluate the upstream package.nix with the corrected studio hash.
        # Drop this overlay once the PR lands.
        (final: _prev: {
          davinci-resolve-studio = final.callPackage (builtins.toFile "davinci-resolve.nix" (
            builtins.replaceStrings
              [ "sha256-D5RjUukwKMpULrDfMJOPsPWW9FxhQ/IUMh76u5JLytA=" ]
              [ "sha256-P+zu8/OuFcDcIkwV3UMq0qg9U2JEGRkKDP+VLQesZjw=" ]
              (builtins.readFile "${inputs.nixpkgs}/pkgs/by-name/da/davinci-resolve/package.nix")
          )) { studioVariant = true; };
        })
        (final: _prev: {
          claude-desktop = final.callPackage ../../pkgs/claude-desktop.nix { };
          helium-browser = final.callPackage ../../pkgs/helium-browser.nix { };
          macos-goldengate-cursor = final.callPackage ../../pkgs/macos-goldengate-cursor.nix { };
          proton-drive-cli = final.callPackage ../../pkgs/proton-drive-cli.nix { };
          zcode = final.callPackage ../../pkgs/zcode.nix { };
          # TEMPORARILY DISABLED (disk space) together with the organice inputs
          # in flake.nix and the profile entry in hosts/hellplace/profiles.nix.
          # organice-proton-sidecar = final.callPackage ../../pkgs/organice-proton-sidecar.nix {
          #   inherit (inputs) organice-proton-sidecar-bin;
          # };
        })
      ];
    };
  };
}
