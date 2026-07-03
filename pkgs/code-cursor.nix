{
  stdenv,
  code-cursor,
  fetchurl,
  appimageTools,
  fish,
}:

let
  version = "3.9.16";
  commit = "042b3c1a4c53f2c3808067f519fbfc67b72cad8b";

  sources = {
    x86_64-linux = {
      url = "https://downloads.cursor.com/production/${commit}/linux/x64/Cursor-${version}-x86_64.AppImage";
      hash = "sha256-dG61VYGMHPip57ldzNICEi1yPc4s1dON+MlDGiKadKc=";
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

  # 3.9.16 bundles a musl-linked variant of the whichlang-node binding next to
  # the glibc one; the glibc copy is what gets dlopened on NixOS, so silence
  # auto-patchelf on the unreachable musl libc dependency.
  autoPatchelfIgnoreMissingDeps = (oldAttrs.autoPatchelfIgnoreMissingDeps or [ ]) ++ [
    "libc.musl-x86_64.so.1"
  ];

  # Cursor's agent terminal sandbox mounts tmpfs over /run, hiding
  # /run/current-system/sw/bin where $SHELL normally points on NixOS.
  preFixup = (oldAttrs.preFixup or "") + ''
    gappsWrapperArgs+=(
      --set SHELL ${fish}/bin/fish
    )
  '';
})
