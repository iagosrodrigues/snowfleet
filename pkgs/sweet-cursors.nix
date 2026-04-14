{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "sweet-cursors";
  version = "unstable-2026-03-17";

  src = fetchFromGitHub {
    owner = "EliverLara";
    repo = "Sweet";
    rev = "f5720cb4159498df628d063c27b1ebe40e7cb1be";
    hash = "sha256-HZUV0jQq6JTlN2Ats9huADXBIDG5M2zGirRqxbGIIHo=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -dm755 "$out/share/icons"
    cp -r kde/cursors/Sweet-cursors "$out/share/icons/Sweet-cursors"

    runHook postInstall
  '';

  meta = {
    description = "Sweet cursor theme from the Sweet nova branch";
    homepage = "https://github.com/EliverLara/Sweet/tree/nova";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
