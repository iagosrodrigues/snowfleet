_: {
  flake.modules.homeManager.eden =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.eden ];

      home.persistence."/persist".directories = [
        ".config/eden"
        # keys, firmware, NAND (saves, installed titles) and sdmc.
        ".local/share/eden"
        # Vulkan pipeline / shader cache.
        ".cache/eden"
      ];
    };
}
