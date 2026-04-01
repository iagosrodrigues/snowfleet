_: {
  flake.modules.nixos.ollama =
    { pkgs, ... }:
    {
      services.ollama = {
        enable = true;
        package = pkgs.ollama-rocm;
        loadModels = [
          "qwen2.5vl:7b"
          "qwen3.5:9b"
        ];
        environmentVariables = {
          # Keep ROCm on the RX 7800 XT. Letting Ollama probe the Raphael iGPU
          # has been triggering an amdgpu reset during boot.
          ROCR_VISIBLE_DEVICES = "GPU-6de0e4d48ee7c950";
          HSA_OVERRIDE_GFX_VERSION_0 = "11.0.1";
          HCC_AMDGPU_TARGET = "gfx1101";
          HSA_ENABLE_SDMA = "0";
          OLLAMA_NUM_CTX = "65536";
        };
      };

      environment.persistence."/persist".directories = [
        "/var/lib/private/ollama"
      ];
    };

  flake.modules.homeManager.ollama = _: {
    home.persistence."/persist".directories = [
      ".ollama"
    ];
  };
}
