_: {
  flake.modules.nixos.printing = {
    services.printing.enable = true;

    environment.persistence."/persist".directories = [
      "/var/lib/cups"
    ];
  };
}
