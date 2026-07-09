_: {
  flake.modules.homeManager.ai-tools =
    { pkgs, ... }:
    {
      # Prefer llm-agents packages (main e9ba5d9); keep gemini-cli from nixpkgs.
      home.packages = with pkgs; [
        gemini-cli
        llm-agents.claude-desktop
        llm-agents.claude-code
        llm-agents.codex
        llm-agents.crush
        llm-agents.grok
        llm-agents.pi
      ];

      home.persistence."/persist".directories = [
        ".cache/huggingface"
        ".claude"
        ".codex"
        ".config/crush"
        ".crush"
        ".gemini"
        ".local/share/crush"
      ];
    };
}
