_: {
  flake.modules.homeManager.zcode =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.llm-agents.zcode ];

      home.persistence."/persist".directories = [
        ".config/ZCode" # Electron userData (sessions, login, updater cache)
        ".zcode" # agent config, plugins cache, CLI logs
      ];
    };
}
