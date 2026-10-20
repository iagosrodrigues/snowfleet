_: {
  flake.modules.homeManager.ai-memory =
    { pkgs, ... }:
    {
      home = {
        packages = [ pkgs.llm-agents.ai-memory ];

        # Wiki (git-backed markdown), SQLite index, config.toml, auth tokens
        # and the hook scripts `ai-memory setup` stages.
        persistence."/persist".directories = [ ".local/share/ai-memory" ];
      };

      # Declarative twin of the user unit `ai-memory setup` writes (upstream
      # packaging/systemd/ai-memory-user.service). Wire agents with
      # `ai-memory setup --no-service` so it does not write its own copy.
      systemd.user.services.ai-memory = {
        Unit = {
          Description = "ai-memory MCP server";
          Documentation = "https://github.com/akitaonrails/ai-memory";
        };
        Service = {
          ExecStart = "${pkgs.llm-agents.ai-memory}/bin/ai-memory --data-dir %h/.local/share/ai-memory serve --transport http --enable-web";
          Restart = "on-failure";
          RestartSec = 5;
          NoNewPrivileges = true;
          PrivateTmp = true;
        };
        Install.WantedBy = [ "default.target" ];
      };
    };
}
