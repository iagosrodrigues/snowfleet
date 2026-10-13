_: {
  flake.modules.homeManager.reverse-engineering =
    { config, pkgs, ... }:
    {
      home = {
        packages = with pkgs; [
          ghidra
          jadx
        ];

        sessionVariables = {
          # `rea setup` copies this into every agent's MCP registration, so use
          # the profile link rather than a store path that goes stale on bumps.
          GHIDRA_INSTALL_DIR = "/etc/profiles/per-user/${config.home.username}/lib/ghidra";
          # Ghidra headless (REA's Ghidra provider) needs a full JDK; nixpkgs
          # ghidra is built against 21. REA resolves this to a store path when
          # registering, so rerun `rea setup` after a JDK bump + GC.
          JAVA_HOME = pkgs.jdk21.home;
        };

        persistence."/persist".directories = [
          ".config/ghidra" # Ghidra user settings, tool layouts, recent projects
          ".config/jadx" # jadx-gui settings and recent files
          ".rea" # REA (npx rea-agents) cache and analysis state
        ];
      };
    };
}
