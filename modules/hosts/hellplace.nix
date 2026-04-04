{
  inputs,
  config,
  ...
}:
let
  inherit (config.flake.modules) nixos;
  hm = config.flake.modules.homeManager;

  sharedNixosModules = with nixos; [
    nix-settings
    agenix
    audio
    fonts
    gnome
    home-manager-base
    impermanence-base
    iago
    io-schedulers
    networking
    # niri
    nixpkgs-config
    ollama
    onepassword
    printing
    private
    shell
    ssh
    steam
    tailscale
    virtualisation
    vr
    yubikey
  ];

  sharedHmModules = with hm; [
    ai-tools
    ashell
    audio
    brave
    comfyui
    dev-tools
    discord
    ghostty
    git
    gnome
    helium-browser
    lmstudio
    obs-studio
    ollama
    onepassword
    opencode
    personal-git
    nixvim
    shell
    ssh
    steam
    tailscale
    telegram
    user-persistence
    virtualisation
    vr
    vscode
    work-git
    zed
  ];

  diskoConfig = import ../../disko/hellplace.nix;

  nixosModules = sharedNixosModules ++ [
    nixos.hellplace
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    diskoConfig
    (
      { config, ... }:
      {
        networking.hostName = "hellplace";

        fileSystems."/persist".neededForBoot = true;

        # Declarative password management (impermanence wipes /etc/shadow)
        age.secrets.iago-password = {
          rekeyFile = ../../secrets/iago-password.age;
          path = "/persist/secrets/iago-password";
          owner = "root";
          group = "root";
          mode = "0400";
        };

        age.secrets.git-personal = {
          rekeyFile = ../../secrets/git-personal.age;
          owner = "iago";
          group = "users";
          mode = "0400";
        };

        users.mutableUsers = false;
        users.users.iago.hashedPasswordFile = config.age.secrets.iago-password.path;

      }
    )
  ];

  hmModules = sharedHmModules ++ [
    inputs.nixvim.homeModules.nixvim
  ];
in
{
  flake.nixosConfigurations.hellplace = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = nixosModules ++ [ { home-manager.sharedModules = hmModules; } ];
  };
}
