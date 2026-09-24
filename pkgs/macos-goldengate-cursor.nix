{
  lib,
  requireFile,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "macos-goldengate-cursor";
  version = "1";

  # Cursors extracted from macOS: Apple assets, not redistributable, so the
  # tarball stays out of this public repo. Register it once per machine.
  src = requireFile {
    name = "macOS-GoldenGate.tar.gz";
    hash = "sha256-s/82UXxG3zM9/MGiZV2Domhm8F4TZMgJ+Wr0a1htWUM=";
    message = ''
      Add the macOS GoldenGate cursor tarball to the Nix store:
        nix-store --add-fixed sha256 macOS-GoldenGate.tar.gz
    '';
  };

  dontBuild = true;

  # Shipped index.theme inherits itself; fall back to Breeze for missing shapes.
  installPhase = ''
    runHook preInstall

    install -dm755 "$out/share/icons"
    cp -r . "$out/share/icons/macOS-GoldenGate"
    sed -i 's/^Inherits=.*/Inherits=breeze_cursors/' "$out/share/icons/macOS-GoldenGate/cursor.theme"
    cp "$out/share/icons/macOS-GoldenGate/cursor.theme" "$out/share/icons/macOS-GoldenGate/index.theme"

    runHook postInstall
  '';

  meta = {
    description = "macOS GoldenGate cursor theme (nominal sizes 24-120)";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
  };
}
