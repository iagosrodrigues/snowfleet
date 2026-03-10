_: {
  flake.modules.nixos.io-schedulers = {
    services.udev.extraRules = ''
      # HDD - set BFQ scheduler
      ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"

      # SSD (SATA/eMMC) - set mq-deadline scheduler
      ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"

      # NVMe - set none scheduler
      ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
    '';
  };
}
