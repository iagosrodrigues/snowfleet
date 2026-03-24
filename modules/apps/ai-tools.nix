_: {
  flake.modules.homeManager.ai-tools = _: {
    home.persistence."/persist".directories = [
      ".claude"
      ".codex"
      ".gemini"
      ".cache/huggingface"
    ];
  };
}
