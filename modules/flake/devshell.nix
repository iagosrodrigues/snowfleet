_: {
  perSystem =
    { config, pkgs, ... }:
    {
      formatter = pkgs.nixfmt;

      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          deadnix
          nil
          nixfmt
          statix
          config.agenix-rekey.package
        ];

        shellHook = ''
          echo "NixOS development environment"
          echo "Available commands: nixfmt, deadnix, statix, nil, agenix"
        '';
      };
    };
}
