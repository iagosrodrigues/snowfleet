{
  inputs,
  config,
  ...
}:
let
  inherit (config.flake.modules) nixos;
  hm = config.flake.modules.homeManager;

  sharedNixosModules = with nixos; [
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
    nix-settings
    nixpkgs-config
    ollama
    onepassword
    printing
    private
    shell
    steam
    tailscale
    virtualisation
    vr
    yubikey
  ];

  sharedHmModules = with hm; [
    ashell
    dev-tools
    ghostty
    git
    ollama
    opencode-desktop
    personal-git
    gnome
    helium-browser
    # niri
    # niri-config
    nixvim
    shell
    ssh
    steam
    tailscale
    user-persistence
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

        environment.persistence."/persist" = {
          files = [
            # SSH host keys (prevent fingerprint change on reboot)
            "/etc/ssh/ssh_host_rsa_key"
            "/etc/ssh/ssh_host_rsa_key.pub"
            "/etc/ssh/ssh_host_ed25519_key"
            "/etc/ssh/ssh_host_ed25519_key.pub"
          ];
        };

      }
    )
  ];

  hmModules = sharedHmModules ++ [
    inputs.nixvim.homeModules.nixvim
    {
      home.persistence."/persist" = {
        directories = [
          # Application state
          ".local/share/TelegramDesktop"
          ".local/share/keyrings"
          ".local/state/wireplumber"

          # Application config
          ".config/1Password"
          ".config/BraveSoftware"
          ".config/dconf"
          ".config/discord"
          ".config/libvirt"
          ".config/obs-studio"
          ".config/comfy-ui"
          ".config/Code"
          ".vscode"
          ".claude"
          ".codex"
          ".gemini"

          # Cache Vulkan shaders
          ".cache/huggingface"
          ".cache/mesa_shader_cache"
          ".cache/uv"

          # Crypto / Auth

          # AI / ML
          ".lmstudio"
          ".config/LM Studio"
        ];
      };
    }
  ];
in
{
  flake.nixosConfigurations.hellplace = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = nixosModules ++ [ { home-manager.sharedModules = hmModules; } ];
  };
}
