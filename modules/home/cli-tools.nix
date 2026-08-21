{ pkgs, osConfig, ... }:
let
  # Route diffs through a wrapper that drops ANSI colour, spools to a temp .diff
  # file (so filetype detection kicks in), and opens it in nvim read-only.
  nvim-diff-pager = pkgs.writeShellScriptBin "nvim-diff-pager" ''
    tmp=$(mktemp --suffix=.diff)
    trap 'rm -f "$tmp"' EXIT
    sed 's/\x1b\[[0-9;]*m//g' > "$tmp"
    [ -s "$tmp" ] && ${pkgs.neovim}/bin/nvim -R "$tmp"
  '';
in {
  programs.git = {
    enable = true;
    userName = "nathanbodie";
    userEmail = "nathanbodie@gmail.com";
    settings = {
      # Read `git diff` / `git show` through nvim; leave `git log` on the
      # default pager so plain log output stays in less.
      pager.diff = "${nvim-diff-pager}/bin/nvim-diff-pager";
      pager.show = "${nvim-diff-pager}/bin/nvim-diff-pager";
    };
  };

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
      pn        = "pnpm";
      neofetch  = "fastfetch";
      nrs       = "nixos-rebuild switch --flake .#${osConfig.networking.hostName}";
      # Read a GitHub PR diff in nvim via the same wrapper `git diff` uses.
      prd       = "gh pr diff --color=always | ${nvim-diff-pager}/bin/nvim-diff-pager";
    };
    sessionVariables = {
      EDITOR = "nvim";
      MANPAGER = "nvim +Man!";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # GitHub CLI + gh-dash extension (TUI PR/issue dashboard, vim keybinds).
  # Read PR diffs with `gh pr diff` (see the `prd` alias); comment/approve with
  # `gh pr review` / `gh pr comment`. Run `gh auth login` once to authenticate.
  programs.gh = {
    enable = true;
    extensions = [ pkgs.gh-dash ];
  };

  # Render lazygit's diffs through delta (word-level / side-by-side). This is
  # scoped to lazygit only and does not touch the `git diff` -> nvim pager above.
  programs.lazygit.settings.git.paging = {
    colorArg = "always";
    pager = "${pkgs.delta}/bin/delta --paging=never";
  };

  # direnv + nix-direnv: auto-load a repo's flake devShell on cd.
  # enableZshIntegration adds the shell hook (the managed ~/.zshrc is the only
  # place it can live); nix-direnv caches the shell so re-entry is instant.
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
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
    pandoc
    lazygit
    delta
    claude-code
  ];
}
