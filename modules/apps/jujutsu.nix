_: {
  flake.modules.homeManager.jujutsu =
    { pkgs, ... }:
    {
      programs.jujutsu = {
        enable = true;

        settings = {
          user = {
            name = "Iago S. Rodrigues";
            email = "me@iagosousa.com";
          };

          # SSH commit signing through 1Password's signer, mirroring the
          # personal-git module. `behavior = "own"` signs commits authored by
          # the configured user; the public key matches the one in
          # users/iago.nix and git's gpg.format = ssh setup.
          signing = {
            behavior = "own";
            backend = "ssh";
            key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA+9boyw9MLSLia/aW9DQFD4NLpMc6mlG81FpIwSdkcu";
            backends.ssh.program = "${pkgs._1password-gui}/bin/op-ssh-sign";
          };
        };
      };
    };
}
