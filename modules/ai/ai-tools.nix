_: {
  flake.modules.homeManager.ai-tools =
    { pkgs, ... }:
    {
      # Prefer llm-agents packages (main e9ba5d9).
      home.packages = with pkgs; [
        claude-desktop
        llm-agents.claude-code
        llm-agents.codex
        llm-agents.crush
        llm-agents.gemini-cli
        llm-agents.grok
        llm-agents.opencode
        llm-agents.pi
      ];

      home.persistence."/persist".directories = [
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
        ".pi"
      ];
    };
}
