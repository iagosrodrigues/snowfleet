_: {
  flake.modules.nixos.impermanence-base = {
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/lib/AccountsService"
      ];
      files = [
        "/etc/machine-id"
        "/etc/adjtime"
      ];
    };
  };
}
