{ inputs, ... }:
{
  flake.modules.homeManager.opencode-desktop =
    { pkgs, ... }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
      desktop =
        (inputs.opencode.packages.${system}.desktop.override {
          opencode = pkgs.opencode;
        }).overrideAttrs
          (_: {
            cargoDeps = pkgs.rustPlatform.importCargoLock {
              lockFile = "${inputs.opencode}/packages/desktop/src-tauri/Cargo.lock";
              outputHashes = {
                "specta-2.0.0-rc.22" = "sha256-YsyOAnXELLKzhNlJ35dHA6KGbs0wTAX/nlQoW8wWyJQ=";
                "tauri-2.9.5" = "sha256-dv5E/+A49ZBvnUQUkCGGJ21iHrVvrhHKNcpUctivJ8M=";
                "tauri-specta-2.0.0-rc.21" = "sha256-n2VJ+B1nVrh6zQoZyfMoctqP+Csh7eVHRXwUQuiQjaQ=";
              };
            };
          });
    in
    {
      home.packages = [ desktop ];

      home.persistence."/persist".directories = [
        ".config/opencode"
        ".cache/opencode"
        ".local/share/opencode"
      ];
    };
}
