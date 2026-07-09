_: {
  flake.modules.homeManager.personal-git =
    { pkgs, ... }:
    {
      programs.git = {
        includes = [
          {
            path = "/run/agenix/git-personal";
          }
        ];

        signing.signByDefault = true;

        settings.gpg = {
          ssh = {
            program = "${pkgs._1password-gui}/bin/op-ssh-sign";
            allowedSignersFile = "~/.ssh/allowed_signers";
          };
          format = "ssh";
        };
      };
    };
}
