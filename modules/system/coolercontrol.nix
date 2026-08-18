_: {
  flake.modules.nixos.coolercontrol = {
    programs.coolercontrol.enable = true;

    # 4.x daemon: config.toml / config-ui.json / profiles / backups live in
    # /etc/coolercontrol; runtime state (web-UI sessions, plugins, alert logs)
    # lives in /var/lib/coolercontrol.
    environment.persistence."/persist".directories = [
      "/etc/coolercontrol"
      "/var/lib/coolercontrol"
    ];
  };

  flake.modules.homeManager.coolercontrol = _: {
    # GUI (Qt) settings: daemon address/port, tray and window preferences.
    home.persistence."/persist".directories = [
      ".config/org.coolercontrol.CoolerControl"
    ];
  };
}
