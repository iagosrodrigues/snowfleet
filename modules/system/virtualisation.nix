_: {
  flake.modules.nixos.virtualisation =
    { pkgs, ... }:
    {
      virtualisation = {
        libvirtd = {
          enable = true;
          qemu = {
            swtpm.enable = true;
          };
        };

        spiceUSBRedirection.enable = true;

        docker = {
          enable = true;
          enableOnBoot = false;
        };
      };

      environment.systemPackages = with pkgs; [
        virt-manager
      ];

      systemd.services.virt-secret-init-encryption.serviceConfig.ExecStart = [
        "" # clear upstream /usr/bin/sh
        "${pkgs.bash}/bin/sh -c 'umask 0077 && (dd if=/dev/random status=none bs=32 count=1 | ${pkgs.systemd}/bin/systemd-creds encrypt --name=secrets-encryption-key - /var/lib/libvirt/secrets/secrets-encryption-key)'"
      ];
    };
}
