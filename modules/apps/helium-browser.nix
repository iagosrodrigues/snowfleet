_:
let
  heliumBrowserPackage =
    {
      stdenv,
      lib,
      appimageTools,
      fetchurl,
      symlinkJoin,
      writeShellScript,
    }:
    let
      pname = "helium-browser";
      version = "0.11.3.2";

      architectures = {
        x86_64-linux = {
          arch = "x86_64";
          hash = "sha256-5gdyKg12ZV2hpf0RL+eoJnawuW/J8NobiG+zEA0IOHA=";
        };
        aarch64-linux = {
          arch = "arm64";
          hash = "sha256-k9YTB7SFmviS99u5eCiG7PsSCcGHLB350la2cgGKvvA=";
        };
      };

      release =
        architectures.${stdenv.hostPlatform.system}
          or (throw "Unsupported system for helium-browser: ${stdenv.hostPlatform.system}");

      src = fetchurl {
        url = "https://github.com/imputnet/helium/releases/download/${version}/helium-${version}-${release.arch}.AppImage";
        inherit (release) hash;
      };

      appimageContents = appimageTools.extractType2 {
        inherit pname version src;
      };

      meta = with lib; {
        description = "Privacy-focused browser built from Chromium";
        homepage = "https://github.com/imputnet/helium";
        license = licenses.unfree;
        mainProgram = pname;
        platforms = attrNames architectures;
        sourceProvenance = [ sourceTypes.binaryNativeCode ];
      };

      unwrapped = appimageTools.wrapType2 {
        inherit
          pname
          version
          src
          meta
          ;
        extraInstallCommands = ''
          desktopFile=""

          for candidate in \
            ${appimageContents}/*.desktop \
            ${appimageContents}/usr/share/applications/*.desktop
          do
            if [ -e "$candidate" ]; then
              desktopFile="$candidate"
              break
            fi
          done

          if [ -n "$desktopFile" ]; then
            install -Dm444 "$desktopFile" "$out/share/applications/${pname}.desktop"
            sed -i \
              -e 's|^Exec=.*|Exec=${pname} %U|' \
              -e 's|^Icon=.*|Icon=${pname}|' \
              "$out/share/applications/${pname}.desktop"
          fi

          if [ -d ${appimageContents}/usr/share/icons ]; then
            mkdir -p "$out/share/icons"
            cp -r ${appimageContents}/usr/share/icons/* "$out/share/icons/"
          fi

          if [ -f ${appimageContents}/.DirIcon ]; then
            mkdir -p "$out/share/pixmaps"
            install -m444 \
              ${appimageContents}/.DirIcon \
              "$out/share/pixmaps/${pname}.png"
          fi
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
