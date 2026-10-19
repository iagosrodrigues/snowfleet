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
        # Hermes bundles the Honcho plugin but omits its optional Python SDK.
        # Add it to both the CLI closure and the Python used by TUI workers.
        (final: prev: {
          honcho-ai = final.callPackage ../../pkgs/honcho-ai.nix { };
          llm-agents = prev.llm-agents // {
            hermes-agent = prev.llm-agents.hermes-agent.overridePythonAttrs (old: {
              dependencies = old.dependencies ++ [ final.honcho-ai ];
              makeWrapperArgs = old.makeWrapperArgs ++ [
                "--set"
                "HERMES_PYTHON"
                "${final.python3.withPackages (_: old.dependencies ++ [ final.honcho-ai ])}/bin/python3"
              ];
              pythonImportsCheck = old.pythonImportsCheck ++ [ "honcho" ];
            });
            # Paperclip ships two embedded-postgres copies (top level and under
            # @paperclipai/db). Upstream's postInstall patches only the first
            # one found, then deletes every @embedded-postgres platform package,
            # so the other copy fails with ERR_MODULE_NOT_FOUND at startup.
            # Patch every copy to use nixpkgs PostgreSQL.
            paperclip = prev.llm-agents.paperclip.overrideAttrs {
              postInstall = ''
                    find $out/lib/node_modules -path '*/embedded-postgres/dist/binary.js' | grep -q .
                    while IFS= read -r embedded; do
                      cat > "$embedded" <<'EOF'
                function getBinaries() {
                  return Promise.resolve({
                    postgres: "${final.postgresql_18}/bin/postgres",
                    initdb: "${final.postgresql_18}/bin/initdb",
                    pg_ctl: "${final.postgresql_18}/bin/pg_ctl",
                  });
                }
                export default getBinaries;
                EOF

                      # Keep the unix socket in the data dir; /run/postgresql is not
                      # writable for unprivileged users.
                      substituteInPlace "$(dirname "$embedded")/index.js" \
                        --replace-fail "...this.options.postgresFlags," \
                          "'-k', this.options.databaseDir, ...this.options.postgresFlags,"
                    done < <(find $out/lib/node_modules -path '*/embedded-postgres/dist/binary.js')

                    # Drop the now unused FHS-linked binaries.
                    while IFS= read -r scope; do
                      find "$scope" -mindepth 1 -maxdepth 1 ! -name symlink-reader -exec rm -rf {} +
                    done < <(find $out/lib/node_modules -path '*/node_modules/@embedded-postgres' -type d)
              '';
            };
          };
        })
        (final: _prev: {
          anthrosevka-mono = final.callPackage ../../pkgs/anthrosevka-mono.nix { };
          claude-desktop = final.callPackage ../../pkgs/claude-desktop.nix { };
          helium-browser = final.callPackage ../../pkgs/helium-browser.nix { };
          macos-goldengate-cursor = final.callPackage ../../pkgs/macos-goldengate-cursor.nix { };
          proton-drive-cli = final.callPackage ../../pkgs/proton-drive-cli.nix { };
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
