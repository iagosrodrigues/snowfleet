_: {
  flake.modules.homeManager.opencode =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.llm-agents.opencode ];

      home.persistence."/persist".directories = [
        ".config/opencode"
        ".cache/opencode"
        ".local/share/opencode"
      ];
    };
}
