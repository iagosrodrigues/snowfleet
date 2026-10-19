{
  lib,
  fetchzip,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "anthrosevka-mono";
  version = "0.4.0";

  # Prebuilt unhinted TTFs; building Iosevka from source takes a long time.
  src = fetchzip {
    url = "https://github.com/nanxstats/anthrosevka/releases/download/v${finalAttrs.version}/AnthrosevkaMono.zip";
    stripRoot = false;
    hash = "sha256-vMdTPFXH9D6JnTJDmMsoTgKUmsNuWAgtya+n0umW57I=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 -t "$out/share/fonts/truetype" *.ttf

    runHook postInstall
  '';

  meta = {
    description = "Iosevka custom build inspired by Anthropic Mono";
    homepage = "https://github.com/nanxstats/anthrosevka";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
})
