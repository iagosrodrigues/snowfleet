_: {
  flake.modules.nixos.networking = {
    networking.networkmanager.enable = true;

    time.timeZone = "America/Fortaleza";

    i18n = {
      defaultLocale = "en_US.UTF-8";
    };

    console.keyMap = "us";

    services.timesyncd.enable = true;
  };
}
