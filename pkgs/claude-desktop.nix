{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  # runtime / autopatchelf libs
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libGL,
  libgbm ? null,
  mesa,
  libcap_ng,
  libnotify,
  libseccomp,
  libsecret,
  libuuid,
  libxkbcommon,
  nspr,
  nss,
  pango,
  systemd,
  libayatana-appindicator,
  xdg-utils,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
  libxtst,
  libxshmfence,
}:

let
  version = "1.17377.1";

  # Official Anthropic apt repository. The .deb bundles its own Electron
  # runtime, so we only extract it and repair the ELF interpreter / rpaths.
  src = fetchurl {
    url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${version}_amd64.deb";
    hash = "sha256-9L14VFIAh3tZEXmDjeeteld99u0uhFlp3SVpDvxchcc=";
  };
in
stdenv.mkDerivation {
  pname = "claude-desktop";
  inherit version src;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libGL
    (if libgbm != null then libgbm else mesa)
    libcap_ng
    libnotify
    libseccomp
    libsecret
    libuuid
    libxkbcommon
    nspr
    nss
    pango
    libayatana-appindicator
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    libxtst
    libxshmfence
  ];

  # dlopen()ed at runtime; not caught by autoPatchelf.
  runtimeDependencies = [
    (lib.getLib systemd)
    libsecret
  ];

  # Chromium/Electron and bundled ANGLE libs dlopen native GL/Vulkan pieces at
  # runtime. LD_LIBRARY_PATH is stripped by Chromium's sandbox, so bake these
  # paths into DT_RUNPATH via autoPatchelfHook's appendRunpaths mechanism.
  # libGL provides libglvnd dispatchers (libEGL.so.1 / libGL.so.1), while
  # /run/opengl-driver/lib provides mesa implementations, libva and Vulkan ICDs.
  appendRunpaths = [
    (lib.makeLibraryPath [ libGL ])
    "/run/opengl-driver/lib"
  ];

  # dpkg-deb preserves the setuid bit on chrome-sandbox, which tar cannot
  # apply inside the build sandbox. Unpack the data archive by hand and drop
  # the SUID helper: a non-setuid chrome-sandbox is fatal to Electron, and
  # the store copy could never be setuid anyway. Electron then falls back to
  # the unprivileged user-namespace sandbox, which NixOS enables by default.
  unpackPhase = ''
    runHook preUnpack
    ar x "$src"
    tar --no-same-owner --no-same-permissions -xf data.tar.xz
    rm -f usr/lib/claude-desktop/chrome-sandbox
    runHook postUnpack
  '';

  # gappsWrapperArgs are applied via the wrapper we build below.
  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -r usr/lib "$out/lib"
    cp -r usr/share "$out/share"

    # Electron ships its own vulkan/EGL/ffmpeg; keep the whole app dir intact.
    makeWrapper "$out/lib/claude-desktop/claude-desktop" "$out/bin/claude-desktop" \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}" \
      --add-flags "--ozone-platform-hint=auto"

    runHook postInstall
  '';

  meta = {
    description = "Desktop application for Claude.ai (official Linux beta)";
    homepage = "https://claude.ai";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "claude-desktop";
  };
}
