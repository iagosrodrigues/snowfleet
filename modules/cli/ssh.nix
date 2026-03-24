_: {
  flake.modules.nixos.ssh = {
    environment.persistence."/persist".files = [
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };

  flake.modules.homeManager.ssh = _: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks."*" = {
        identityAgent = "~/.1password/agent.sock";
      };
    };

    home.persistence."/persist".directories = [
      ".ssh"
    ];
  };
}
