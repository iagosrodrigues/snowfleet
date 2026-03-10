_: {
  flake.modules.nixos.vr =
    { pkgs, ... }:
    {
      services.wivrn = {
        enable = true;
        openFirewall = true;
        defaultRuntime = true;
        autoStart = false;
      };

      environment.systemPackages = with pkgs; [
        wayvr
      ];
    };
}
