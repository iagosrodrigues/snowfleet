# Named module profiles for hellplace composition.
# flake-parts-safe: import-tree evaluates every .nix under modules/ as a
# flake-parts module — this file must not set NixOS/HM options directly.
# Membership must stay identical to the pre-profile host lists.
{ config, ... }:
let
  nixos = config.flake.modules.nixos;
  hm = config.flake.modules.homeManager;
in
{
  flake.profiles.hellplace = {
    core = {
      nixos = with nixos; [
        agenix
        home-manager-base
        iago
        impermanence-base
        networking
        nix-settings
        nixpkgs-config
        # hardware / platform
        io-schedulers
        lact
        yubikey
        # services
        printing
        shell
        ssh
        tailscale
        virtualisation
      ];
      hm = with hm; [
        shell
        ssh
        dev-tools
        essentials
        user-persistence
        tmux
        zellij
        tailscale
        virtualisation
      ];
    };

    desktop-kde = {
      nixos = with nixos; [
        kde
        audio
        fonts
      ];
      hm = with hm; [
        kde
        audio
      ];
    };

    gaming = {
      nixos = with nixos; [
        steam
        gamemode
        vr
      ];
      hm = with hm; [
        steam
        vr
        godot
      ];
    };

    ai = {
      nixos = with nixos; [
        ollama
      ];
      hm = with hm; [
        # claude-desktop omitted: main installs via llm-agents (e9ba5d9)
        ai-tools
        ollama
        lmstudio
        comfyui
      ];
    };

    apps-daily = {
      nixos = with nixos; [
        onepassword
      ];
      hm = with hm; [
        # vcs
        git
        personal-git
        work-git
        jujutsu
        # terminal / editors
        ghostty
        vscode
        zed
        code-cursor
        intellij
        opencode
        amp
        # browsers
        brave
        helium-browser
        # apps / media
        discord
        telegram
        onepassword
        qbittorrent
        rclone
        proton-drive-cli
        obs-studio
        davinci-resolve
        mongodb-compass
      ];
    };

    # Non-portable: modules that need local sibling flake checkouts
    # (see flake.nix path inputs + README "Personal flake").
    personal = {
      nixos = with nixos; [
        ai-jail
      ];
      hm = with hm; [
        organice
      ];
    };
  };
}
