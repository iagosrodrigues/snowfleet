{ inputs, ... }: {
  flake.modules.homeManager.firefox-nightly = { pkgs, ... }: {
    home.persistence."/persist".directories = [
      ".mozilla/firefox"
    ];

    home.packages = [
      inputs.firefox-nightly.packages.${pkgs.stdenv.hostPlatform.system}.firefox-nightly-bin
    ];
  };
}
