# The MacOS-Tahoe-Cursor.zip is not redistributable, so it is not tracked in
# this repo. Download it from https://www.gnome-look.org/p/2300466 and drop it
# at $SNOWFLEET_DISTFILES_DIR/MacOS-Tahoe-Cursor.zip (default:
# ~/.local/share/snowfleet/distfiles/MacOS-Tahoe-Cursor.zip), then rebuild
# with `nixos-rebuild ... --impure` so the overlay can read outside the flake
# source. Pure builds fall back to apple-cursor (see modules/users/iago.nix).
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
