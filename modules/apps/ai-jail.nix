{ inputs, ... }:
{
  flake.modules.nixos.ai-jail =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
    in
    {
      environment.systemPackages = [
        inputs.ai-jail.packages.${system}.default
      ];
    };
}
