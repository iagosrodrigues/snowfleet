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
          HSA_OVERRIDE_GFX_VERSION = "11.0.1";
          HCC_AMDGPU_TARGET = "gfx1101";
          HSA_ENABLE_SDMA = "0";
        };
      };
    };
}
