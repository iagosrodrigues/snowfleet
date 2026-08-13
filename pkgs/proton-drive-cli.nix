{
  lib,
  runCommand,
  fetchurl,
  buildFHSEnv,
  libsecret,
  glib,
  libgcrypt,
  libgpg-error,
  xdg-utils,
}:

let
  version = "0.6.0";

  # Stock upstream release: a Bun single-file executable (bun --compile) with
  # the Bun runtime and Drive SDK appended to the ELF as a trailing payload.
  # The Organice NDJSON-progress fork is retired — cold-tier transfers now go
  # through `organice-proton-sidecar` (see pkgs/organice-proton-sidecar.nix);
  # this CLI is kept only for `proton-drive auth login`, whose session the
  # sidecar shares via the proton-drive-cli app dir + keyring. SHA-512 matches
  # the checksum published on the download page.
  src = fetchurl {
    url = "https://proton.me/download/drive/cli/${version}/linux-x64/proton-drive";
    hash = "sha512-539bJ6UagQY8I8FawKnwfg7FyGjnhnDzS0Wzw8Lmee12nmIleWuQDQ0Cc1oMUqIeunI1bzrWF94HbEBVMuaY3A==";
  };

  # Keep the binary byte-for-byte. The appended Bun payload is anchored to the
  # ELF's original section-header layout: any rewrite — autoPatchelfHook,
  # patchelf, or stdenv's default `strip` — shifts offsets and severs the
  # payload, after which the binary silently degrades into a bare `bun` runtime
  # (prints Bun's help, treats every arg as a Bun subcommand). `install` alone
  # doesn't touch bytes; disabling fixup is what matters.
  unwrapped = runCommand "proton-drive-unwrapped-${version}" { dontFixup = true; } ''
    install -Dm755 ${src} $out/libexec/proton-drive
  '';
in
# For credential storage the CLI dlopen()s libsecret-1.so.0 *by soname* through
# Bun's FFI, and libsecret in turn pulls in libglib/libgobject/libgcrypt. On a
# non-FHS distro that dlopen chain can't be satisfied by LD_LIBRARY_PATH alone
# (the loader does not consult it reliably for the FFI dependency graph), so the
# CLI aborts every command with "libsecret not available". An FHS sandbox gives
# it a standard /usr/lib + ld.so.cache covering libsecret's whole closure, which
# dlopen resolves unconditionally. The binary runs unmodified inside, so
# /proc/self/exe still points at the intact file and the Bun payload loads.
# pname becomes the wrapped command name -> `proton-drive` on PATH, matching
# upstream (the nixpkgs overlay attribute is still `proton-drive-cli`).
buildFHSEnv {
  pname = "proton-drive";
  inherit version;

  targetPkgs = _: [
    libsecret
    glib
    libgcrypt
    libgpg-error
    xdg-utils # `auth login` shells out to xdg-open to reach the browser
  ];

  # The 0.6.0 CLI's newer Bun runtime resolves the libsecret FFI dlopen only
  # via LD_LIBRARY_PATH — the FHS /usr/lib + ld.so.cache alone stopped being
  # enough (0.5.0 resolved it without this). Point it at the FHS merged lib
  # dirs; verified against the live keyring session.
  profile = ''
    export LD_LIBRARY_PATH=/usr/lib:/usr/lib64''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
  '';

  runScript = "${unwrapped}/libexec/proton-drive";

  meta = {
    description = "Proton Drive command-line client (official binary; kept for auth login)";
    homepage = "https://github.com/ProtonDriveApps/sdk/tree/main/cli";
    downloadPage = "https://proton.me/download/drive/cli/index.html";
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "proton-drive";
  };
}
