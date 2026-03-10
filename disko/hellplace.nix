{
  disko.devices = {
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=8G"
          "noatime"
          "defaults"
          "mode=755"
        ];
      };
    };
    disk = {
      nvme = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_2TB_S69ENF0W808555E";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                settings = {
                  allowDiscards = true;
                  # FIDO2 (YubiKey) is the primary unlock method.
                  # systemd-cryptsetup will fall back to a passphrase keyslot
                  # automatically if FIDO2 fails — but only if one is registered.
                  #
                  # To add a password fallback (do this once, manually):
                  #   sudo cryptsetup luksAddKey /dev/disk/by-id/nvme-Samsung_SSD_980_PRO_2TB_S69ENF0W808555E-part2
                  # (authenticate with the YubiKey when prompted, then enter the new passphrase)
                  crypttabExtraOpts = [ "fido2-device=auto" ];
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "@persist" = {
                      mountpoint = "/persist";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "@snapshots" = {
                      mountpoint = "/.snapshots";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "@swap" = {
                      mountpoint = "/swap";
                      mountOptions = [ "noatime" ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
