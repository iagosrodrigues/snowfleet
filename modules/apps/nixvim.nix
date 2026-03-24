_: {
  flake.modules.homeManager.nixvim = _: {
    programs.nixvim = {
      enable = true;

      colorschemes.habamax.enable = true;

      clipboard = {
        providers.wl-copy.enable = true;
      };

      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };

      opts = {
        encoding = "utf-8";
        fileencoding = "utf-8";

        number = true;
        relativenumber = true;
        cursorline = true;

        tabstop = 2;
        softtabstop = 2;
        shiftwidth = 2;
        expandtab = true;

        smartindent = true;

        wrap = true;

        swapfile = false;
        backup = false;
        undodir = "os.getenv \"HOME\" .. \"/.vim/undodir\"";
        undofile = true;

        hlsearch = true;
        incsearch = true;

        termguicolors = true;

        scrolloff = 8;
        signcolumn = "yes";

        updatetime = 50;

        colorcolumn = "100";

        winborder = "rounded";
      };

      plugins = {
        oil.enable = true;
        web-devicons.enable = true;
        lightline.enable = true;
        telescope.enable = true;

        undotree.enable = true;
        flash.enable = true;

        mini-ai.enable = true;
        mini-comment.enable = true;
        mini-icons.enable = true;
        mini-pairs.enable = true;
        mini-surround.enable = true;

        treesitter = {
          enable = true;
          settings = {
            highlight.enable = true;
            indent.enable = true;
          };
        };

        lsp = {
          enable = true;
          servers = {
            nixd = {
              enable = true;
            };
            rust_analyzer = {
              installCargo = false;
              installRustc = false;
              enable = true;
            };
          };
        };

        conform-nvim = {
          enable = true;
          settings = {
            format_on_save = {
              lsp_fallback = true;
            };
            formatters_by_ft = {
              nix = [ "nixfmt" ];
            };
          };
        };
      };

      keymaps = [
        {
          mode = "";
          key = "<leader>cf";
          action = "function() require('conform').format { async = true; lsp_fallback = true } end";
          options.silent = true;
        }
        {
          mode = "n";
          key = "<Esc>";
          action = "<cmd>nohlsearch<CR>";
        }
        {
          mode = "n";
          key = "<leader>q";
          action = "vim.diagnostic.setloclist";
        }
        {
          mode = "n";
          key = ";";
          action = ":";
        }
      ];

      autoCmds = [
        {
        }
      ];
    };
  };
}
