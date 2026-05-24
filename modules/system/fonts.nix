_: {
  flake.modules.nixos.fonts =
    { pkgs, ... }:
    {
      fonts.packages = with pkgs; [
        _0xproto
        agave
        corefonts
        dejavu_fonts
        geist-font
        ibm-plex
        inconsolata
        inter
        julia-mono
        lilex
        maple-mono.variable
        nerd-fonts.jetbrains-mono
        nerd-fonts.symbols-only
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
      ];
    };
}
