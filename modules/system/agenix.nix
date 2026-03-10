{ inputs, ... }:
{
  flake.modules.nixos.agenix =
    { config, pkgs, ... }:
    {
      imports = [
        inputs.agenix.nixosModules.default
        inputs.agenix-rekey.nixosModules.default
      ];

      environment.systemPackages = [
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
        pkgs.age-plugin-yubikey
        pkgs.rage
      ];

      age.identityPaths = [
        "/persist/etc/ssh/ssh_host_ed25519_key"
      ];

      age.rekey = {
        storageMode = "local";
        localStorageDir = ./. + "/../../secrets/rekeyed/${config.networking.hostName}";
        hostPubkey = "/persist/etc/ssh/ssh_host_ed25519_key.pub";
        masterIdentities = [
          "/persist/secrets/agenix/master-iago-yubikey.txt"
        ];
      };
    };
}
