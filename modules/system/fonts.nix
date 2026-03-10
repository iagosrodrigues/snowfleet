_: {
  flake.modules.nixos.fonts =
    { pkgs, ... }:
    {
      fonts.packages = with pkgs; [
        _0xproto
        corefonts
        dejavu_fonts
        geist-font
        ibm-plex
        inconsolata
        inter
        nerd-fonts.jetbrains-mono
        julia-mono
        lilex
        maple-mono.variable
        nerd-fonts.symbols-only
      ];
    };
}
