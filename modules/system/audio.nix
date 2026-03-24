_: {
  flake.modules.nixos.audio = {
    services = {
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
    };

    security.rtkit.enable = true;

    environment.persistence."/persist".directories = [
      "/var/lib/pipewire"
    ];
  };

  flake.modules.homeManager.audio = _: {
    home.persistence."/persist".directories = [
      ".local/state/wireplumber"
    ];
  };
}
