_:
let
  heliumBrowserPackage =
    {
      stdenv,
      lib,
      fetchurl,
      dpkg,
      makeWrapper,
      patchelf,
      symlinkJoin,
      writeShellScript,
      alsa-lib,
      atk,
      at-spi2-atk,
      at-spi2-core,
      cairo,
      cups,
      dbus,
      expat,
      fontconfig,
      freetype,
      gdk-pixbuf,
      glib,
      gtk3,
      libdrm,
      libgbm,
      libGL,
      libx11,
      libxcb,
      libxcomposite,
      libxdamage,
      libxext,
      libxfixes,
      libxkbcommon,
      libxrandr,
      libxshmfence,
      nspr,
      nss,
      pango,
      systemd,
    }:
    let
      pname = "helium-browser";
      version = "0.13.6.1";

      architectures = {
        x86_64-linux = {
          debArch = "amd64";
          hash = "sha256-ms+XG5/zl4lfrdgxTuCfOyfHQCeGUav+orzI680FxDE=";
        };
        aarch64-linux = {
          debArch = "arm64";
          hash = "sha256-lFNhrzWow2ChadSuQqMzFgGKEnZJMOgiGg/RCtmh1OE=";
        };
      };

      release =
        architectures.${stdenv.hostPlatform.system}
          or (throw "Unsupported system for helium-browser: ${stdenv.hostPlatform.system}");

      src = fetchurl {
        url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-bin_${version}-1_${release.debArch}.deb";
        inherit (release) hash;
      };

      meta = with lib; {
        description = "Privacy-focused browser built from Chromium";
        homepage = "https://github.com/imputnet/helium";
        license = licenses.unfree;
        mainProgram = pname;
        platforms = attrNames architectures;
        sourceProvenance = [ sourceTypes.binaryNativeCode ];
      };

      # The AppImage build runs inside nixpkgs bubblewrap, which strips setgid
      # when the extension spawns 1Password-BrowserSupport. The .deb ships a
      # native /opt/helium/helium binary without that sandbox (see
      # imputnet/helium-linux#168).
      runtimeLibs = [
        stdenv.cc.cc
        stdenv.cc.libc
        alsa-lib
        atk
        at-spi2-atk
        at-spi2-core
        cairo
        cups
        dbus
        expat
        fontconfig
        freetype
        gdk-pixbuf
        glib
        gtk3
        libdrm
        libgbm
        libGL
        libx11
        libxcb
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxkbcommon
        libxrandr
        libxshmfence
        nspr
        nss
        pango
        systemd
      ];

      runtimeLibPath =
        lib.makeLibraryPath runtimeLibs
        + lib.optionalString stdenv.hostPlatform.is64bit (
          ":" + lib.makeSearchPathOutput "lib" "lib64" runtimeLibs
        );

      unwrapped = stdenv.mkDerivation {
        inherit
          pname
          version
          src
          meta
          ;

        nativeBuildInputs = [
          dpkg
          makeWrapper
          patchelf
        ];

        buildInputs = runtimeLibs;

        # ANGLE dlopens libEGL.so.1 (libglvnd) at runtime; it is not a direct
        # DT_NEEDED, so stdenv's fixup `patchelf --shrink-rpath` would strip
        # libglvnd (and other dlopen-only libs) from the rpath we set below,
        # breaking GPU init. Keep our rpath intact.
        dontPatchELF = true;

        unpackPhase = ''
          runHook preUnpack
          dpkg-deb -x "$src" source
          runHook postUnpack
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p "$out/opt" "$out/bin"
          cp -a source/opt/helium "$out/opt/"

          mkdir -p "$out/share/applications" "$out/share/icons"
          if [ -f source/usr/share/applications/helium.desktop ]; then
            install -Dm444 source/usr/share/applications/helium.desktop \
              "$out/share/applications/${pname}.desktop"
            sed -i \
              -e 's|^Exec=.*|Exec=${pname} %U|' \
              -e 's|^Icon=.*|Icon=${pname}|' \
              "$out/share/applications/${pname}.desktop"
          fi
          if [ -d source/usr/share/icons ]; then
            cp -a source/usr/share/icons/. "$out/share/icons/"
          fi

          heliumLibPath="${runtimeLibPath}:$out/opt/helium"
          patchelf \
            --set-interpreter "$(cat "$NIX_CC/nix-support/dynamic-linker")" \
            --set-rpath "$heliumLibPath" \
            "$out/opt/helium/helium"

          for f in \
            helium_crashpad_handler \
            libEGL.so \
            libGLESv2.so \
            libqt5_shim.so \
            libqt6_shim.so \
            libvk_swiftshader.so \
            libvulkan.so.1
          do
            if [ -f "$out/opt/helium/$f" ]; then
              patchelf --set-rpath "$heliumLibPath" "$out/opt/helium/$f"
            fi
          done

          makeWrapper "$out/opt/helium/helium" "$out/bin/${pname}" \
            --argv0 helium \
            --chdir "$out/opt/helium"

          runHook postInstall
        '';
      };

      # Borrow Widevine CDM from Brave's component-updater cache. Helium
      # ignores --widevine-path; it only follows the hint file Chromium's
      # component updater writes, so build that file pointing at Brave's
      # latest CDM version directory.
      launcher = writeShellScript "${pname}-launcher" ''
        braveWvDir="$HOME/.config/BraveSoftware/Brave-Browser/WidevineCdm"
        heliumWvDir="$HOME/.config/net.imput.helium/WidevineCdm"

        version=""
        for d in "$braveWvDir"/*/; do
          name=$(basename "$d")
          if [ -f "$d/manifest.json" ] && [ -f "$d/_platform_specific/linux_x64/libwidevinecdm.so" ]; then
            version="$name"
          fi
        done

        if [ -n "$version" ]; then
          mkdir -p "$heliumWvDir"
          printf '{"Path":"%s/%s"}' "$braveWvDir" "$version" \
            > "$heliumWvDir/latest-component-updated-widevine-cdm"
        fi

        exec ${unwrapped}/bin/${pname} "$@"
      '';
    in
    symlinkJoin {
      name = "${pname}-${version}";
      paths = [ unwrapped ];
      postBuild = ''
        rm $out/bin/${pname}
        ln -s ${launcher} $out/bin/${pname}
      '';
      inherit meta;
      passthru = { inherit unwrapped; };
    };

  onePasswordManifest = ''
    {
      "name": "com.1password.1password",
      "description": "1Password BrowserSupport",
      "path": "/run/wrappers/bin/1Password-BrowserSupport",
      "type": "stdio",
      "allowed_origins": [
        "chrome-extension://aeblfdkhhhdcdjpifhhbdiojplfjncoa/",
        "chrome-extension://bkpbhnjcbehoklfkljkkbbmipaphipgl/",
        "chrome-extension://dppgmdbiimibapkepcbdbmkaabgiofem/",
        "chrome-extension://gejiddohjgogedgjnonbofjigllpkmbf/",
        "chrome-extension://hjlinigoblmkhjejkmbegnoaljkphmgo/",
        "chrome-extension://khgocmkkpikpnmmkgmdnfckapcdkgfaf/"
      ]
    }
  '';
in
{
  flake.modules.nixos.helium-browser =
    { pkgs, ... }:
    {
      environment.systemPackages = [ (pkgs.callPackage heliumBrowserPackage { }) ];
    };

  flake.modules.homeManager.helium-browser =
    { pkgs, ... }:
    {
      home.packages = [ (pkgs.callPackage heliumBrowserPackage { }) ];
      home.file.".config/net.imput.helium/NativeMessagingHosts/com.1password.1password.json".text =
        onePasswordManifest;
      home.persistence."/persist".directories = [
        ".config/net.imput.helium"
      ];
    };
}
