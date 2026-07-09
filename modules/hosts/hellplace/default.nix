{
  inputs,
  config,
  ...
}:
let
  inherit (config.flake.modules) nixos;
  hm = config.flake.modules.homeManager;

  sharedNixosModules = with nixos; [
    # --- core ---
    agenix
    home-manager-base
    iago
    impermanence-base
    networking
    nix-settings
    nixpkgs-config
    # --- hardware / platform ---
    io-schedulers
    lact
    yubikey
    # --- desktop ---
    kde
    # --- services ---
    audio
    fonts
    printing
    shell
    ssh
    tailscale
    virtualisation
    # --- apps (system side) ---
    ai-jail
    ollama
    onepassword
    # --- gaming ---
    steam
    gamemode
    vr
  ];

  sharedHmModules = with hm; [
    # --- core / shell ---
    shell
    ssh
    dev-tools
    user-persistence
    tmux
    zellij
    # --- desktop ---
    kde
    audio
    # --- vcs ---
    git
    personal-git
    work-git
    jujutsu
    # --- terminal / editors ---
    ghostty
    vscode
    zed
    code-cursor
    intellij
    opencode
    amp
    # --- browsers ---
    brave
    helium-browser
    # --- AI ---
    # claude-desktop intentionally omitted: main installs via llm-agents (e9ba5d9)
    ai-tools
    ollama
    lmstudio
    comfyui
    # --- apps / media ---
    discord
    telegram
    onepassword
    organice
    qbittorrent
    rclone
    obs-studio
    davinci-resolve
    mongodb-compass
    # --- gaming ---
    steam
    vr
    godot
    # --- services / platform ---
    tailscale
    virtualisation
  ];
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
        (import ../../../disko/hellplace.nix)
        {
          networking.hostName = "hellplace";
          fileSystems."/persist".neededForBoot = true;
        }
      ]
      ++ [ { home-manager.sharedModules = sharedHmModules; } ];
  };
}
