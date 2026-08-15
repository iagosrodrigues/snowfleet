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
  mesa,
  libnotify,
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
  version = "3.7.7";

  # Official Z.ai CDN. The .deb bundles its own Electron runtime, so we only
  # extract it and repair the ELF interpreter / rpaths.
  src = fetchurl {
    url = "https://cdn-zcode.z.ai/zcode/electron/releases/${version}/linux-x64/ZCode-${version}-linux-x64.deb";
    hash = "sha256-/m9kfZs3+JvuEoQ8u6/VqP0LMzY5QfMu4V6OefCFbGM=";
  };
in
stdenv.mkDerivation {
  pname = "zcode";
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
    mesa
    libnotify
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
    # node-pty prebuild (resources/app.asar.unpacked) links libstdc++
    stdenv.cc.cc.lib
  ];

  # dlopen()ed at runtime; not caught by autoPatchelf.
  runtimeDependencies = [
    (lib.getLib systemd)
    libsecret
  ];

  # Chromium/Electron and bundled ANGLE libs dlopen native GL/Vulkan pieces at
  # runtime. LD_LIBRARY_PATH is stripped by Chromium's sandbox, so bake these
  # paths into DT_RUNPATH via autoPatchelfHook's appendRunpaths mechanism.
  appendRunpaths = [
    (lib.makeLibraryPath [ libGL ])
    "/run/opengl-driver/lib"
  ];

  # dpkg-deb preserves the setuid bit on chrome-sandbox, which tar cannot
  # apply inside the build sandbox. Unpack the data archive by hand and drop
  # the SUID helper: a non-setuid chrome-sandbox is fatal to Electron, and
  # the store copy could never be setuid anyway. Electron then falls back to
  # the unprivileged user-namespace sandbox, which NixOS enables by default.
  #
  # The upstream x64 .deb also ships an AArch64 build of ssh2's sshcrypto.node
  # (upstream packaging bug); remove it so the JS crypto fallback is used
  # deterministically instead of a load failure.
  unpackPhase = ''
    runHook preUnpack
    ar x "$src"
    tar --no-same-owner --no-same-permissions -xf data.tar.xz
    rm -f opt/ZCode/chrome-sandbox
    rm -f opt/ZCode/resources/app.asar.unpacked/node_modules/ssh2/lib/protocol/crypto/build/Release/sshcrypto.node
    runHook postUnpack
  '';

  # gappsWrapperArgs are applied via the wrapper we build below.
  dontWrapGApps = true;

  # autoPatchelf rewrites the bundled static-pie ripgrep (no PT_INTERP, no
  # NEEDED entries) and leaves it segfaulting — patchelf cannot round-trip
  # that ELF layout. Restore the pristine binary from the .deb in a phase
  # that runs after fixup (postFixup would still run before the hook).
  postPhases = [ "restoreStaticRipgrepPhase" ];

  restoreStaticRipgrepPhase = ''
    pristine="$(mktemp -d)"
    (
      cd "$pristine"
      ar x "$src"
      tar --no-same-owner --no-same-permissions -xf data.tar.xz \
        ./opt/ZCode/resources/tools/ripgrep/rg
    )
    install -m 555 "$pristine/opt/ZCode/resources/tools/ripgrep/rg" \
      "$out/lib/ZCode/resources/tools/ripgrep/rg"
    rm -rf "$pristine"
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib"
    cp -r opt/ZCode "$out/lib/ZCode"
    cp -r usr/share "$out/share"

    # .deb ships Exec=/opt/ZCode/zcode
    substituteInPlace "$out/share/applications/zcode.desktop" \
      --replace-fail "/opt/ZCode/zcode" "$out/bin/zcode"

    # Electron ships its own vulkan/EGL/ffmpeg; keep the whole app dir intact.
    makeWrapper "$out/lib/ZCode/zcode" "$out/bin/zcode" \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}" \
      --add-flags "--ozone-platform-hint=auto"

    runHook postInstall
  '';

  meta = {
    description = "Z.ai ZCode desktop app (official harness for GLM)";
    homepage = "https://zcode.z.ai";
    changelog = "https://zcode.z.ai/en/changelog";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "zcode";
  };
}
