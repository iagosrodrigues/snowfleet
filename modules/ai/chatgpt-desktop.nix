_: {
  flake.modules.homeManager.chatgpt-desktop =
    { pkgs, ... }:
    let
      chatgpt = pkgs.symlinkJoin {
        name = "chatgpt";
        paths = [ pkgs.llm-agents.chatgpt ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram "$out/bin/chatgpt" --unset QT_PLUGIN_PATH
        '';
      };
    in
    {
      home.packages = [ chatgpt ];

      home.persistence."/persist".directories = [
        ".config/ChatGPT" # Electron userData (login, sessions)
        # Codex data (~/.codex) is persisted in ai-tools.nix (same profile).
      ];
    };
}
