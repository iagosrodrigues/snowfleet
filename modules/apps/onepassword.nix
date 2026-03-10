_: {
  flake.modules.nixos.onepassword =
    { ... }:
    {
      programs._1password.enable = true;
      programs._1password-gui = {
        enable = true;
        polkitPolicyOwners = [ "iago" ];
      };
      environment.etc."1password/custom_allowed_browsers" = {
        text = ''
          helium-browser
        '';
        mode = "0755";
      };
    };
}
