{ inputs, ... }:
{
  flake.modules.nixos.home-manager-base = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
