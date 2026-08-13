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
        trusted-users = [
          "iago"
        ];
        warn-dirty = false;
        extra-substituters = [
          "https://cache.numtide.com"
          "https://nix-community.cachix.org"
          "https://rocm.cachix.org"
          "https://zed.cachix.org"
        ];
        extra-trusted-public-keys = [
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "rocm.cachix.org-1:6Iv6py1xxKkNR0U/OTW7EQN0fJr1AZHpEUvBpyXGecw="
          "zed.cachix.org-1:/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU="
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
