# Optional HM module (not selected on hellplace). Prefer llm-agents.claude-desktop
# via modules/ai/ai-tools.nix when enabling AI tools.
_: {
  flake.modules.homeManager.claude-desktop = _: {
    home.persistence."/persist".directories = [
      ".config/Claude"
    ];
  };
}
