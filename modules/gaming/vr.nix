_: {
  flake.modules.nixos.vr =
    { pkgs, ... }:
    {
      services.wivrn = {
        enable = true;
        openFirewall = true;
        autoStart = false;
        steam = {
          enable = true;
        };
      };

      environment.systemPackages = with pkgs; [
        wayvr
      ];
    };
}
