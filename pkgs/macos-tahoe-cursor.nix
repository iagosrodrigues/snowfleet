{
  lib,
  stdenvNoCC,
  unzip,
  src,
}:

stdenvNoCC.mkDerivation {
  pname = "macos-tahoe-cursor";
  version = "1.4";

  inherit src;

  nativeBuildInputs = [ unzip ];

  sourceRoot = ".";

  unpackCmd = ''
    unzip -qq "$curSrc"
  '';

  installPhase = ''
    runHook preInstall

    install -dm755 "$out/share/icons"

    find . -type f -name index.theme > themes.txt

    while IFS= read -r themeIndex; do
      theme="$(dirname "$themeIndex")"

      if [ -d "$theme/cursors" ]; then
        cp -r "$theme" "$out/share/icons/$(basename "$theme")"
      fi
    done < themes.txt

    if ! find "$out/share/icons" -mindepth 1 -maxdepth 1 -type d | grep -q .; then
      echo "No cursor themes found in archive" >&2
      exit 1
    fi

    runHook postInstall
  '';

  meta = {
    description = "MacOS Tahoe cursor theme";
    homepage = "https://www.gnome-look.org/p/2300466";
    platforms = lib.platforms.linux;
  };
}
