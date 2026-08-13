{
  lib,
  runCommand,
  makeWrapper,
  libsecret,
  glib,
  # Non-flake path input: the organice checkout's `tools/proton-sidecar/release`
  # build output (contains the compiled `organice-proton-sidecar`). Pinned in
  # flake.lock; re-pin after each `bun run build` with
  # `nix flake update organice-proton-sidecar-bin`.
  organice-proton-sidecar-bin,
}:

# Organice's Proton Drive transport daemon (NDJSON over stdio, built on the
# open-source @protontech/drive-sdk; spec: organice
# docs/superpowers/specs/2026-07-21-proton-sidecar-transport-design.md). It
# replaces the patched proton-drive CLI for all cold-tier transfers; the stock
# CLI remains only for `auth login`, whose session the sidecar shares via the
# proton-drive-cli app dir + keyring. Organice resolves it as
# `organice-proton-sidecar` on PATH (or the ORGANICE_PROTON_SIDECAR env var).
#
# Like the CLI it is a Bun single-file executable (bun --compile): the Bun
# runtime plus the daemon are appended to the ELF as a trailing payload
# anchored to the original section-header layout, so the binary must stay
# byte-for-byte — no autoPatchelfHook/patchelf/strip (dontFixup), or it
# silently degrades into a bare `bun` runtime. Its interpreter already points
# at a nix-store glibc (compiled by the dev-shell Bun), which Nix's reference
# scanner keeps in the closure.
#
# Bun.secrets dlopen()s libsecret-1.so.0 by soname at runtime; this Bun
# generation resolves that through LD_LIBRARY_PATH (same finding as the 0.6.0
# CLI), so a prefix wrapper suffices — no FHS env needed. Mirrors organice's
# dev shell, which exports ORGANICE_PROTON_SIDECAR_LIBS="${libsecret}/lib:
# ${glib.out}/lib" for the same purpose (live-smoke verified there).
runCommand "organice-proton-sidecar"
  {
    version = "0-unstable";
    dontFixup = true;
    nativeBuildInputs = [ makeWrapper ];
    meta = {
      description = "Organice Proton Drive sidecar transport daemon (local bun build)";
      license = lib.licenses.gpl3Only;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      platforms = [ "x86_64-linux" ];
      mainProgram = "organice-proton-sidecar";
    };
  }
  ''
    install -Dm755 ${organice-proton-sidecar-bin}/organice-proton-sidecar \
      $out/libexec/organice-proton-sidecar
    makeWrapper $out/libexec/organice-proton-sidecar $out/bin/organice-proton-sidecar \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libsecret
          glib
        ]
      }
  ''
