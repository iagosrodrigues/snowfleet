_: {
  flake.modules.nixos.nix-settings = {
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
        auto-optimise-store = true;
        warn-dirty = false;
        extra-substituters = [
          "https://nix-community.cachix.org"
          "https://rocm.cachix.org"
        ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "rocm.cachix.org-1:6Iv6py1xxKkNR0U/OTW7EQN0fJr1AZHpEUvBpyXGecw="
        ];
      };

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };

      optimise.automatic = true;
    };

    programs.nix-ld.enable = true;
  };
}
