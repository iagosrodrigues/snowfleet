{
  inputs,
  config,
  ...
}:
let
  inherit (config.flake.modules) nixos;
  hm = config.flake.modules.homeManager;

  sharedNixosModules = with nixos; [
    kde
    agenix
    audio
    fonts
    home-manager-base
    iago
    impermanence-base
    io-schedulers
    lact
    networking
    nix-settings
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
    amp
    kde
    audio
    brave
    code-cursor
    comfyui
    davinci-resolve
    dev-tools
    discord
    ghostty
    git
    helium-browser
    intellij
    lmstudio
    obs-studio
    ollama
    onepassword
    opencode
    personal-git
    rclone
    shell
    ssh
    steam
    tailscale
    telegram
    tmux
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

  hmModules = sharedHmModules;
in
{
  flake.nixosConfigurations.hellplace = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = nixosModules ++ [ { home-manager.sharedModules = hmModules; } ];
  };
}
