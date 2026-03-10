{ inputs, ... }:
let
  opencodeDesktopPackage =
    { pkgs }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      lib = pkgs.lib;
      opencode = inputs.opencode.packages.${system}.opencode;
    in
    pkgs.rustPlatform.buildRustPackage (finalAttrs: {
      pname = "opencode-desktop";
      inherit (opencode) version src;
      node_modules = opencode.node_modules;
      patches = if opencode ? patches then opencode.patches else [ ];

      cargoRoot = "packages/desktop/src-tauri";
      cargoLock = {
        lockFile = "${inputs.opencode}/packages/desktop/src-tauri/Cargo.lock";
        outputHashes = {
          "specta-2.0.0-rc.22" = "sha256-YsyOAnXELLKzhNlJ35dHA6KGbs0wTAX/nlQoW8wWyJQ=";
          "tauri-2.9.5" = "sha256-dv5E/+A49ZBvnUQUkCGGJ21iHrVvrhHKNcpUctivJ8M=";
          "tauri-specta-2.0.0-rc.21" = "sha256-n2VJ+B1nVrh6zQoZyfMoctqP+Csh7eVHRXwUQuiQjaQ=";
        };
      };
      buildAndTestSubdir = finalAttrs.cargoRoot;

      nativeBuildInputs = [
        pkgs.pkg-config
        pkgs.cargo-tauri.hook
        pkgs.bun
        pkgs.nodejs
        pkgs.cargo
        pkgs.rustc
        pkgs.jq
        pkgs.makeWrapper
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.wrapGAppsHook4 ];

      buildInputs = lib.optionals pkgs.stdenv.isLinux [
        pkgs.dbus
        pkgs.glib
        pkgs.gtk4
        pkgs.libsoup_3
        pkgs.librsvg
        pkgs.libappindicator
        pkgs.glib-networking
        pkgs.openssl
        pkgs.webkitgtk_4_1
        pkgs.gst_all_1.gstreamer
        pkgs.gst_all_1.gst-plugins-base
        pkgs.gst_all_1.gst-plugins-good
        pkgs.gst_all_1.gst-plugins-bad
      ];

      strictDeps = true;

      preBuild = ''
        cp -a ${finalAttrs.node_modules}/{node_modules,packages} .
        chmod -R u+w node_modules packages
        patchShebangs node_modules
        patchShebangs packages/desktop/node_modules

        mkdir -p packages/desktop/src-tauri/sidecars
        cp ${opencode}/bin/opencode packages/desktop/src-tauri/sidecars/opencode-cli-${pkgs.stdenv.hostPlatform.rust.rustcTarget}
      '';

      tauriBuildFlags = [
        "--config"
        "tauri.prod.conf.json"
        "--no-sign"
      ];

      postFixup = lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
        mv $out/bin/OpenCode $out/bin/opencode-desktop
        sed -i 's|^Exec=OpenCode$|Exec=opencode-desktop|' $out/share/applications/OpenCode.desktop
      '';

      meta = {
        description = "OpenCode Desktop App";
        homepage = "https://opencode.ai";
        license = lib.licenses.mit;
        mainProgram = "opencode-desktop";
        inherit (opencode.meta) platforms;
      };
    });
in
{
  flake.modules.homeManager.opencode-desktop =
    { pkgs, ... }:
    {
      home.packages = [
        (opencodeDesktopPackage { inherit pkgs; })
      ];
    };
}
