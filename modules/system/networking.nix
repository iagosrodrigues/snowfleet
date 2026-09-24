_: {
  flake.modules.nixos.networking = {
    networking.networkmanager.enable = true;

    environment.persistence."/persist".directories = [
      "/var/lib/NetworkManager"
      "/etc/NetworkManager/system-connections"
    ];

    time.timeZone = "Etc/GMT+3";

    i18n = {
      defaultLocale = "C.UTF-8";
    };

    console.keyMap = "us";

    services.timesyncd.enable = true;
  };
}
