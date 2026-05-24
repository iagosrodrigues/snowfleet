_: {
  flake.modules.nixos.lact =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.lact ];

      hardware.amdgpu.overdrive.enable = true;

      services.lact = {
        enable = true;
      };

      # systemd.services.lact = {
      #   description = "AMDGPU Control Daemon";
      #   after = [ "multi-user.target" ];
      #   wantedBy = [ "multi-user.target" ];
      #   serviceConfig = {
      #     ExecStart = "${pkgs.lact}/bin/lact daemon";
      #     Nice = -10;
      #   };
      # };
    };
}
