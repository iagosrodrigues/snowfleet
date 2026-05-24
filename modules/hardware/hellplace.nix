_: {
  flake.modules.nixos.hellplace =
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

        extraModulePackages = [ config.boot.kernelPackages.new-lg4ff ];

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
          "hid-logitech-new"
          "hid-logitech-hidpp"
          "kvm-amd"
          "uvcvideo"
        ];

        kernelParams = [
          "amdgpu.cwsr_enable=0"
        ];
      };

      # Networking (DHCP)
      networking.useDHCP = lib.mkDefault true;

      # AMD hardware
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware = {
        cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        amdgpu.opencl.enable = true;
        # nixpkgs.config.rocmSupport = true;

        # AMD ROCm GPU packages
        graphics.extraPackages = with pkgs; [
          amf
          rocmPackages.clr.icd
          rocmPackages.rocm-runtime
        ];
      };

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

      # Top-level btrfs mount so btrbk can see both @persist and @snapshots
      # from a single volume root.
      fileSystems."/mnt/btrfs" = {
        device = "/dev/mapper/cryptroot";
        fsType = "btrfs";
        options = [
          "subvolid=5"
          "compress=zstd"
          "noatime"
        ];
      };

      services = {
        open-webui = {
          package = pkgs.open-webui;
          enable = true;
        };

        # btrbk.instances.btrbk = {
        #   onCalendar = "hourly";
        #   settings = {
        #     snapshot_preserve_min = "2d";
        #     snapshot_preserve = "24h 7d 4w";
        #     volume."/mnt/btrfs" = {
        #       snapshot_dir = "@snapshots";
        #       subvolume."@persist" = {
        #         snapshot_name = "persist";
        #       };
        #     };
        #   };
        # };
      };

      services.udev.packages = [ pkgs.oversteer ];

      # services.udev.extraRules = ''
      #   # Logitech G923 (PS/PC)
      #   ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c266", MODE="0660", GROUP="users"
      # '';

      system.stateVersion = "25.05";
    };
}
