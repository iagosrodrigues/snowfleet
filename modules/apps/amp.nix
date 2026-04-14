_: {
  flake.modules.homeManager.amp =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.llm-agents.amp ];

      home.persistence."/persist".directories = [
        ".config/amp"
        ".local/share/amp"
      ];
    };
}
