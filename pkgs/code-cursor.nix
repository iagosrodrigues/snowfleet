{
  lib,
  stdenv,
  code-cursor,
  fetchurl,
  appimageTools,
}:

let
  version = "3.8.11";
  commit = "e56ad3440df06d22ca7501e65fd518e905486ef7";

  sources = {
    x86_64-linux = {
      url = "https://downloads.cursor.com/production/${commit}/linux/x64/Cursor-${version}-x86_64.AppImage";
      hash = "sha256-K8MAPqgc6ZokWBAUeLFUCcTLgnFXe9nLlB6Krq6KORo=";
    };
  };

  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "code-cursor ${version}: unsupported platform ${stdenv.hostPlatform.system}");

  src = appimageTools.extract {
    pname = "cursor";
    inherit version;
    src = fetchurl source;
  };
in
code-cursor.overrideAttrs (oldAttrs: {
  inherit version src;
  sourceRoot = "cursor-${version}-extracted/usr/share/cursor";

  # 3.8.11 bundles a musl-linked variant of the whichlang-node binding next to
  # the glibc one; the glibc copy is what gets dlopened on NixOS, so silence
  # auto-patchelf on the unreachable musl libc dependency.
  autoPatchelfIgnoreMissingDeps = (oldAttrs.autoPatchelfIgnoreMissingDeps or [ ]) ++ [
    "libc.musl-x86_64.so.1"
  ];
})
