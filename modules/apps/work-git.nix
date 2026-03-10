_: {
  flake.modules.homeManager.work-git = _: {
    programs.git.settings = {
      IncludeIf."gitdir:~/Work/" = {
        path = "~/Work/.gitconfig";
      };
    };
  };
}
