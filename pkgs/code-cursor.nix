{
  lib,
  stdenv,
  code-cursor,
  fetchurl,
  appimageTools,
}:

let
  version = "3.4.20";
  commit = "0cf8b06883f54e26bb4f0fb8647c9500ccb4331f";

  sources = {
    x86_64-linux = {
      url = "https://downloads.cursor.com/production/${commit}/linux/x64/Cursor-${version}-x86_64.AppImage";
      hash = "sha256-7lR3nHucG0aTzMYpihTaxRw2CwCiZ/7gzQZsmMf0nL4=";
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

  # 3.4.20 bundles a musl-linked variant of the whichlang-node binding next to
  # the glibc one; the glibc copy is what gets dlopened on NixOS, so silence
  # auto-patchelf on the unreachable musl libc dependency.
  autoPatchelfIgnoreMissingDeps = (oldAttrs.autoPatchelfIgnoreMissingDeps or [ ]) ++ [
    "libc.musl-x86_64.so.1"
  ];
})
