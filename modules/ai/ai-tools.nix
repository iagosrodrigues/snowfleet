_: {
  flake.modules.homeManager.ai-tools =
    { pkgs, ... }:
    {
      home = {
        # Prefer llm-agents packages (main e9ba5d9).
        packages = with pkgs; [
          claude-desktop
          llm-agents.claude-code
          llm-agents.codex
          llm-agents.crush
          llm-agents.gemini-cli
          llm-agents.grok
          llm-agents.opencode2
          llm-agents.orca
          llm-agents.pi
        ];

        # bin/orca-ide is the Electron app, whose Wayland flags break CLI
        # subcommands; bare `orca` can resolve to the GNOME screen reader.
        sessionVariables.ORCA_CLI_COMMAND = "${pkgs.llm-agents.orca}/bin/orca";

        persistence."/persist".directories = [
          ".cache/huggingface"
          ".claude"
          ".config/Claude" # claude-desktop (login, sessions, MCP config)
          ".config/opencode"
          ".cache/opencode"
          ".codex"
          ".config/crush"
          ".crush"
          ".gemini"
          ".local/share/crush"
          ".local/share/opencode" # opencode (auth.json, sessions db)
          ".local/state/opencode"
          ".config/orca" # orca (Electron userData: profiles/orca-data.json, login, logs, daemon)
          ".local/share/orca" # orca managed claude/codex account homes
          ".orca" # orca keybindings.json, agent-hooks, worktrees, drops, templates
          ".pi"
        ];
      };
    };
}
