_:
let
  heliumBrowserPackage =
    {
      stdenv,
      lib,
      appimageTools,
      fetchurl,
    }:
    let
      pname = "helium-browser";
      version = "0.9.4.1";

      architectures = {
        x86_64-linux = {
          arch = "x86_64";
          hash = "sha256-N5gdWuxOrIudJx/4nYo4/SKSxakpTFvL4zzByv6Cnug=";
        };
        aarch64-linux = {
          arch = "arm64";
          hash = "sha256-BvU0bHtJMd6e09HY+9Vhycr3J0O2hunRJCHXpzKF8lk=";
        };
      };

      release =
        architectures.${stdenv.hostPlatform.system}
          or (throw "Unsupported system for helium-browser: ${stdenv.hostPlatform.system}");

      src = fetchurl {
        url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-${release.arch}.AppImage";
        inherit (release) hash;
      };

      appimageContents = appimageTools.extractType2 {
        inherit pname version src;
      };
    in
    appimageTools.wrapType2 {
      inherit pname version src;
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

      meta = with lib; {
        description = "Privacy-focused browser built from Chromium";
        homepage = "https://github.com/imputnet/helium-linux";
        license = licenses.unfree;
        mainProgram = pname;
        platforms = attrNames architectures;
        sourceProvenance = [ sourceTypes.binaryNativeCode ];
      };
    };
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
      home.persistence."/persist".directories = [
        ".config/net.imput.helium"
      ];
    };
}
