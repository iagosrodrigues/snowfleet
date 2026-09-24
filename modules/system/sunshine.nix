_: {
  flake.modules.nixos.sunshine = {
    services.sunshine = {
      enable = true;
      autoStart = true;
      # DRM/KMS capture — required on KDE Wayland (no X11).
      capSysAdmin = true;
      openFirewall = true;
    };
  };

  flake.modules.homeManager.sunshine = _: {
    # Web UI credentials + paired Moonlight clients.
    home.persistence."/persist".directories = [
      ".config/sunshine"
    ];
  };
}
