_: {
  flake.modules.nixos.yubikey =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        yubikey-personalization
        yubikey-manager
        yubico-piv-tool
      ];

      security.pam.services = {
        kde.u2fAuth = true;
        su.u2fAuth = true;
        sudo.u2fAuth = true;
      };

      services = {
        pcscd.enable = true;
        udev.packages = [ pkgs.yubikey-personalization ];
      };
    };
}
