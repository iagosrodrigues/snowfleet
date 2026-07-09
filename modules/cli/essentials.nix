# Loose CLI / desktop utility kit without a dedicated app module.
_: {
  flake.modules.homeManager.essentials =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        (btop.override { rocmSupport = true; })
        android-tools
        cargo
        clang
        eza
        fd
        ffmpeg
        file
        fuzzel
        gh
        gnupg
        jq
        libreoffice-still
        nil
        nixd
        nixfmt
        nodejs
        oversteer
        p7zip
        proton-vpn
        python3
        ripgrep
        rocmPackages.rocm-smi
        rocmPackages.rocminfo
        statix
        unixtools.xxd
        unar
        unzip
        wl-clipboard
        xwayland-satellite
      ];
    };
}
