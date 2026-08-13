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
          extraPackages = [ pkgs.kata-runtime ];
          daemon.settings.runtimes.kata = {
            runtimeType = "io.containerd.kata.v2";
          };
        };
      };

      # Trust traffic from docker bridges only. Containers already sit behind
      # the host; this adds no external exposure.
      networking.firewall.trustedInterfaces = [
        "docker0"
        "br-+"
      ];

      environment.systemPackages = with pkgs; [
        virt-manager
        kata-runtime
      ];

      environment.persistence."/persist".directories = [
        "/var/lib/docker"
        "/var/lib/libvirt"
      ];

      systemd.services.virt-secret-init-encryption.serviceConfig.ExecStart = [
        "" # clear upstream /usr/bin/sh
        "${pkgs.bash}/bin/sh -c 'umask 0077 && (dd if=/dev/random status=none bs=32 count=1 | ${pkgs.systemd}/bin/systemd-creds encrypt --name=secrets-encryption-key - /var/lib/libvirt/secrets/secrets-encryption-key)'"
      ];
    };

  flake.modules.homeManager.virtualisation = _: {
    home.persistence."/persist".directories = [
      ".config/libvirt"
    ];
  };
}
