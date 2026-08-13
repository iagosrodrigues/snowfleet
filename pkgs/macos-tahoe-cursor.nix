{
  lib,
  fetchzip,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "macos-tahoe-cursor";
  version = "1.2";

  # Cursors ship only as a release asset; the git tree holds just docs/preview.
  src = fetchzip {
    url = "https://github.com/witt-bit/MacOS-Tahoe-Cursor/releases/download/1.2/MacOS-Tahoe-Cursor.zip";
    hash = "sha256-yr5GXQrtDl7aGFp84tpd6+IjgM9QVAlBMs9sAtrUPZc=";
  };

  dontBuild = true;

  # Archive nests the theme one level deep (MacOS-Tahoe-Cursor/MacOS-Tahoe-Cursor).
  installPhase = ''
    runHook preInstall

    install -dm755 "$out/share/icons"
    cp -r MacOS-Tahoe-Cursor "$out/share/icons/MacOS-Tahoe-Cursor"

    runHook postInstall
  '';

  meta = {
    description = "macOS Tahoe cursor theme for Linux (nominal sizes 32/48/64/96)";
    homepage = "https://github.com/witt-bit/MacOS-Tahoe-Cursor";
    license = lib.licenses.cc-by-nc-nd-40;
    platforms = lib.platforms.linux;
  };
}
