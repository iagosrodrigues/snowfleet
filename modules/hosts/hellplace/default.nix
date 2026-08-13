{
  inputs,
  config,
  ...
}:
let
  inherit (config.flake.modules) nixos;
  profiles = config.flake.profiles.hellplace;

  # Host composes named profiles + host-specific exceptions (hardware, secrets, disk).
  sharedNixosModules =
    profiles.core.nixos
    ++ profiles.desktop-kde.nixos
    ++ profiles.gaming.nixos
    ++ profiles.ai.nixos
    ++ profiles.apps-daily.nixos
    ++ profiles.personal.nixos;

  sharedHmModules =
    profiles.core.hm
    ++ profiles.desktop-kde.hm
    ++ profiles.gaming.hm
    ++ profiles.ai.hm
    ++ profiles.apps-daily.hm
    ++ profiles.personal.hm;
in
{
  flake.nixosConfigurations.hellplace = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules =
      sharedNixosModules
      ++ [
        nixos.hellplace-hardware
        nixos.hellplace-secrets
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence
        inputs.chaotic.nixosModules.default
        (import ../../../disko/hellplace.nix)
        {
          networking.hostName = "hellplace";
          fileSystems."/persist".neededForBoot = true;
          i18n.supportedLocales = [
            "en_US.UTF-8/UTF-8"
            "ja_JP.UTF-8/UTF-8"
          ];
        }
      ]
      ++ [ { home-manager.sharedModules = sharedHmModules; } ];
  };
}
