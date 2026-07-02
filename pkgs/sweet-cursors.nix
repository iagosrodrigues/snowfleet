{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "sweet-cursors";
  version = "unstable-2026-05-06";

  src = fetchFromGitHub {
    owner = "EliverLara";
    repo = "Sweet";
    rev = "5ce81a45f0f0b63cf732317e7f91f3467ccce084";
    hash = "sha256-IQjp6g+0ADwivZji3LmOs5GRJys+aLbEMrGSEW3devc=";
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
