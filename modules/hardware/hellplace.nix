_: {
  flake.modules.nixos.hellplace-hardware =
    {
      lib,
      pkgs,
      config,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot = {
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };

        kernelPackages = pkgs.linuxPackages_latest;

        initrd = {
          systemd.enable = true;
          availableKernelModules = [
            "nvme"
            "xhci_pci"
            "ahci"
            "usbhid"
            "usb_storage"
            "sd_mod"
          ];
        };

        kernelModules = [
          "amdgpu"
          "kvm-amd"
          "uvcvideo"
        ];
      };

      # Networking (DHCP)
      networking.useDHCP = lib.mkDefault true;

      # AMD hardware
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

      # AMD ROCm GPU packages
      hardware.graphics.extraPackages = with pkgs; [
        rocmPackages.clr.icd
        rocmPackages.rocm-runtime
      ];

      i18n.inputMethod = {
        enable = true;
        type = "ibus";
        ibus.engines = with pkgs.ibus-engines; [ anthy ];
      };

      swapDevices = [
        {
          device = "/swap/swapfile";
          size = 32 * 1024;
        }
      ];

      services = {
        open-webui = {
          package = pkgs.open-webui;
          enable = true;
        };
      };

      system.stateVersion = "25.05";
    };
}
