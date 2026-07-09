_:
let
  username = "iago";
in
{
  flake.modules.nixos.${username} = _: {
    users.users.${username} = {
      isNormalUser = true;
      description = "Iago Sousa Rodrigues";
      extraGroups = [
        "adbusers"
        "docker"
        "input"
        "libvirtd"
        "networkmanager"
        "render"
        "video"
        "wheel"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA+9boyw9MLSLia/aW9DQFD4NLpMc6mlG81FpIwSdkcu Chave principal"
      ];
      # Login shell is managed by home-manager (programs.fish.enable)
      # Setting shell here would require fish in system packages
    };

    home-manager.users.${username} = {
      programs = {
        home-manager.enable = true;
        mpv.enable = true;
        fish.enable = true;
      };

      home = {
        inherit username;
        homeDirectory = "/home/${username}";
        stateVersion = "25.05";
      };

      fonts.fontconfig.enable = true;
    };
  };
}
