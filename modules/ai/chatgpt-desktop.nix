_: {
  flake.modules.homeManager.chatgpt-desktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.llm-agents.chatgpt ];

      home.persistence."/persist".directories = [
        ".config/ChatGPT" # Electron userData (login, sessions)
        # Codex data (~/.codex) is persisted in ai-tools.nix (same profile).
      ];
    };
}
