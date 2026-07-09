_: {
  flake.modules.homeManager.ai-tools = _: {
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
