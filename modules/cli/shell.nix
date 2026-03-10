_: {
  # NixOS side: enable fish as a system shell
  flake.modules.nixos.shell =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.fish
        pkgs.neovim
      ];
    };

  # Home-manager side: fish config, starship, zoxide
  flake.modules.homeManager.shell =
    { lib, pkgs, ... }:
    {
      programs = {
        fish = {
          enable = true;
          shellAliases = {
            ls = "eza --icons=always";
            ll = "eza --icons=always -l";
            la = "eza --icons=always -la";
            nrs = "nixos-rebuild switch --sudo --flake .#(hostname) &| ${lib.getExe pkgs.nix-output-monitor}";
            nrt = "nixos-rebuild test --sudo --flake .#(hostname) &| ${lib.getExe pkgs.nix-output-monitor}";
          };
        };

        starship.enable = true;

        zoxide.enable = true;
      };
    };
}
