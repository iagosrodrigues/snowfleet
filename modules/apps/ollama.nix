_: {
  flake.modules.nixos.ollama =
    { lib, pkgs, ... }:
    {
      services.ollama = {
        enable = true;
        package = pkgs.ollama-vulkan;
        rocmOverrideGfx = "11.0.1";
        home = "/home/iago/Projects/Personal/ollama";
        models = "/home/iago/Projects/Personal/ollama/models";
      };

      # Run as the main user so Ollama can access models stored in ~/Projects.
      # This trades systemd sandboxing for simpler model/data management.
      systemd.services.ollama.serviceConfig = {
        DynamicUser = lib.mkForce false;
        ProtectHome = lib.mkForce false;
        StateDirectory = lib.mkForce [ ];
        User = lib.mkForce "iago";
        Group = lib.mkForce "users";
      };
    };
}
