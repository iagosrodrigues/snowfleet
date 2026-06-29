_: {
  flake.modules.homeManager.zed =
    { lib, pkgs, ... }:
    {
      programs.zed-editor = {
        enable = true;
        extensions = [
          "biome"
          "nix"
          "dockerfile"
          "docker-compose"
        ];
        userSettings = {
          vim_mode = true;
          buffer_font_family = "MonoLisaCode";
          buffer_font_size = 16;
          buffer_font_features = {
            calt = true;
          };
          lsp = {
            tinymist = {
              settings = {
                formatterMode = "typstyle";
              };
            };
            biome = {
              binary = {
                arguments = [ "lsp-proxy" ];
                path = lib.getExe pkgs.biome;
              };
            };
            nil = {
              binary = {
                path = lib.getExe pkgs.nil;
              };
            };
          };
          terminal = {
            shell = {
              program = "${lib.getExe pkgs.nushell}";
            };
          };
        };
        userKeymaps = [
          {
            context = "Editor && edit_prediction_conflict && showing_completions";
            bindings = {
              tab = "editor::AcceptEditPrediction";
            };
          }
        ];
      };
      home.persistence."/persist".directories = [
        ".local/share/zed"
        ".config/zed"
      ];
    };
}
