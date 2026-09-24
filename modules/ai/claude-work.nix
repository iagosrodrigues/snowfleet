# Second, isolated Claude profile for the company account. State lives in
# ~/Projects/Professional/claude (persisted with Projects); this module only
# provides the global entry points so no `cd` is needed.
_: {
  flake.modules.homeManager.claude-work =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      root = "${config.home.homeDirectory}/Projects/Professional/claude";
      configDir = "${root}/.claude-code";
      userDataDir = "${root}/.claude-desktop";
      claude = "${pkgs.llm-agents.claude-code}/bin/claude";
      claudeDesktop = lib.getExe pkgs.claude-desktop;
      desktopExec = "env CLAUDE_USER_DATA_DIR=${userDataDir} ${claudeDesktop}";

      claude-work = pkgs.writeShellApplication {
        name = "claude-work";
        text = ''
          exec env CLAUDE_CONFIG_DIR=${configDir} ${claude} "$@"
        '';
      };

      claude-desktop-work = pkgs.writeShellApplication {
        name = "claude-desktop-work";
        runtimeInputs = [ pkgs.util-linux ];
        text = ''
          exec setsid -f ${desktopExec} "$@"
        '';
      };

      # Desktop login returns through a claude:// deep link, which the default
      # handler routes to the personal profile. Point it at the work entry for
      # the duration of the login, then restore.
      claude-desktop-work-login = pkgs.writeShellApplication {
        name = "claude-desktop-work-login";
        runtimeInputs = [
          pkgs.xdg-utils
          claude-desktop-work
        ];
        text = ''
          prev=$(xdg-mime query default x-scheme-handler/claude || true)
          [ -n "$prev" ] || prev=com.anthropic.Claude.desktop

          restore() {
            xdg-mime default "$prev" x-scheme-handler/claude
            echo "claude:// handler restored to $prev"
          }
          trap restore EXIT

          xdg-mime default claude-work.desktop x-scheme-handler/claude
          echo "claude:// handler temporarily set to the work profile. Sign in inside the Claude window that opens, then come back here."

          claude-desktop-work
          read -r -p "Press Enter after the login completed... " </dev/tty
        '';
      };
    in
    {
      home.packages = [
        claude-work
        claude-desktop-work
        claude-desktop-work-login
      ];

      xdg.desktopEntries.claude-work = {
        name = "Claude (Empresa)";
        comment = "Claude Desktop, work profile";
        exec = "${desktopExec} %U";
        icon = "claude-desktop";
        startupNotify = true;
        categories = [
          "Utility"
          "Development"
        ];
        mimeType = [ "x-scheme-handler/claude" ];
        settings = {
          StartupWMClass = "com.anthropic.Claude";
          SingleMainWindow = "true";
        };
        actions = {
          NewChat = {
            name = "New chat";
            exec = "${desktopExec} claude://claude.ai/new";
          };
          NewCode = {
            name = "New Claude Code session";
            exec = "${desktopExec} claude://code/new";
          };
        };
      };
    };
}
