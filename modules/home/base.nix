{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "refined";
      plugins = [ "git" ];
    };
    shellAliases = {
      ls        = "ls -lacgp";
      vim       = "nvim";
      gst       = "git status";
      lg        = "lazygit";
      pn        = "pnpm";
      neofetch  = "fastfetch";
      tm        = "task-master";
      taskmaster = "task-master";
    };
    sessionVariables = {
      MANPAGER = "nvim +Man!";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.tmux = {
    enable = true;
    prefix = "C-a";
    mouse = true;
    terminal = "tmux-256color";
    baseIndex = 1;
    keyMode = "vi";
    extraConfig = ''
      set-option -g status-position top
      set -ag terminal-overrides ",xterm-256color:RGB"

      unbind o
      bind o source-file ~/.config/tmux/tmux.conf

      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      bind  c  new-window      -c "#{pane_current_path}"
      bind  %  split-window -h -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"

      bind -r t run-shell "tmux neww ~/.local/bin/tmux-sessionizer"

      set -g status-right-length 200
      set -g status-left-length 100
      set -g status-left ""
      set -g status-right ""
      set -g status-style bg=default
      set -g status-justify centre
      set-window-option -g window-status-current-style fg="#E8B589",bold
    '';
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      vim-tmux-navigator
    ];
  };

  home.packages = with pkgs; [
    btop
    wl-clipboard
    pandoc
    lazygit
    claude-code
  ];
}
