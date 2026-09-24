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
        # Cap per-build parallelism; 32-thread cargo builds (codex) peak >22 GB.
        cores = 16;
        trusted-users = [
          "iago"
        ];
        warn-dirty = false;
        extra-substituters = [
          "https://cache.nixos.org"
          "https://cache.numtide.com"
          "https://rocm.cachix.org"
          "https://zed.cachix.org"
          "https://comfyui.cachix.org"
          "https://nix-community.cachix.org"
        ];
        extra-trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
          "rocm.cachix.org-1:6Iv6py1xxKkNR0U/OTW7EQN0fJr1AZHpEUvBpyXGecw="
          "zed.cachix.org-1:/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU="
          "comfyui.cachix.org-1:33mf9VzoIjzVbp0zwj+fT51HG0y31ZTK3nzYZAX0rec="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      optimise.automatic = true;
    };

    programs.nix-ld.enable = true;
  };
}
