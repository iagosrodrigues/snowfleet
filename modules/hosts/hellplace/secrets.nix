# Host-local secrets as a registered NixOS module (import-tree requires
# flake-parts shape under modules/). Selected by hellplace via
# nixos.hellplace-secrets — not auto-applied by registration alone.
_: {
  flake.modules.nixos.hellplace-secrets =
    { config, ... }:
    {
      # Declarative password management (impermanence wipes /etc/shadow)
      age.secrets.iago-password = {
        rekeyFile = ../../../secrets/iago-password.age;
        path = "/persist/secrets/iago-password";
        owner = "root";
        group = "root";
        mode = "0400";
      };

      age.secrets.git-personal = {
        rekeyFile = ../../../secrets/git-personal.age;
        owner = "iago";
        group = "users";
        mode = "0400";
      };

      users.mutableUsers = false;
      users.users.iago.hashedPasswordFile = config.age.secrets.iago-password.path;
    };
}
