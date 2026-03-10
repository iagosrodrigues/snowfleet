_: {
  flake.modules.nixos.tailscale = _: {
    services.tailscale.enable = true;
    environment.persistence."/persist".directories = [
      "/var/lib/tailscale"
    ];
  };

  flake.modules.homeManager.tailscale = _: {
    services.tailscale-systray.enable = true;
  };
}
