{
  stdenv,
  code-cursor,
  fetchurl,
  appimageTools,
  fish,
}:

let
  version = "3.13.21";
  commit = "55434bd8062ece6fee083b82beed2aee42d253f3";

  sources = {
    x86_64-linux = {
      url = "https://downloads.cursor.com/production/${commit}/linux/x64/Cursor-${version}-x86_64.AppImage";
      hash = "sha256-ZF0cCKwgrziu9aF5oIvpmM1OD8G3jwcT6o0Le3wv2rI=";
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
