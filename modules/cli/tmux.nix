_: {
  flake.modules.homeManager.tmux =
    { pkgs, ... }:
    {
      programs.tmux = {
        enable = true;
        shell = "${pkgs.fish}/bin/fish";
        terminal = "xterm-256color";
        historyLimit = 1000;
        escapeTime = 0;
        baseIndex = 1;
        keyMode = "vi";
        mouse = true;
        prefix = "C-a";
        resizeAmount = 10;
        customPaneNavigationAndResize = true;

        plugins = with pkgs.tmuxPlugins; [
          resurrect
          {
            plugin = continuum;
            extraConfig = ''
              set -g @continuum-restore 'off'
            '';
          }
        ];

        extraConfig = ''
          set -ga terminal-overrides ",*256col*:Tc"
          set -g renumber-windows on
          set -g focus-events on

          set -g allow-passthrough on
          set -s extended-keys on
          set -as terminal-features 'xterm*:extkeys'

          bind-key a send-prefix

          setw -g monitor-activity on
          set -g visual-activity on

          unbind =
          bind-key = select-layout tiled

          set-option -g set-titles on
          set-option -g set-titles-string "#T - #W"

          bind-key r source-file ~/.config/tmux/tmux.conf \; display "Tmux config reloaded."
          bind-key N new-window

          unbind '"'
          unbind %
          bind-key | split-window -h -c "#{pane_current_path}"
          bind-key - split-window -v -c "#{pane_current_path}"

          bind-key y setw synchronize-panes

          bind-key -r C-h select-window -t :-
          bind-key -r C-l select-window -t :+

          bind-key -r f run-shell "tmux new-window ~/.local/bin/tmux-sessionizer"

          unbind [
          bind-key Escape copy-mode
          unbind p
          bind-key p paste-buffer
          bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "${pkgs.wl-clipboard}/bin/wl-copy"
          bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "${pkgs.wl-clipboard}/bin/wl-copy"

          set -g pane-border-style fg=colour0
          set -g pane-active-border-style fg=colour238

          bind-key b set-option status

          set -g status-style bg=default
          set -g status-fg default
          set -g status-interval 2
          set -g status-position bottom
          set -g status-justify centre

          set -g message-style fg=black,bg=yellow
          set -g message-command-style fg=blue,bg=black

          setw -g mode-style bg=colour6,fg=colour0

          setw -g window-status-format "#[fg=colour3] •#[fg=colour8] #W "
          setw -g window-status-current-format "#[fg=colour2] •#[fg=colour7] #W "
          setw -g window-status-current-style dim
          set -g status-left "  #[fg=colour3]• #[fg=colour2]• #[fg=colour4]•"
          set -g status-right " #[fg=colour4] •#[fg=colour8] #S  "
        '';
      };

      home.persistence."/persist".directories = [
        ".tmux/resurrect"
      ];
    };
}
