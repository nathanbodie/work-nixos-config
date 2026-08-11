{ pkgs, ... }: {
  imports = [ ../../modules/home/cli-tools.nix ];

  home.username = "nate";
  home.homeDirectory = "/home/nate";
  home.stateVersion = "25.11";

  home.enableNixpkgsReleaseCheck = false;

  # Ensures a tmux session named "work" exists after every reboot.
  # Requires linger=true (set in hosts/vps/default.nix) so this user
  # systemd unit starts without an active login session.
  systemd.user.services.tmux-work = {
    Unit = {
      Description = "Persistent tmux work session";
      After = [ "default.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      # Interactive shells get TMUX_TMPDIR=/run/user/1000, but a systemd user
      # unit starts with a minimal environment where it is unset, so tmux falls
      # back to /tmp/tmux-1000. The session then exists on a socket your shells
      # never look at, and `tmux attach` reports no sessions. %t is the user's
      # runtime directory.
      Environment = "TMUX_TMPDIR=%t";
      ExecStart = "${pkgs.writeShellScript "start-tmux-work" ''
        ${pkgs.tmux}/bin/tmux has-session -t work 2>/dev/null || \
          ${pkgs.tmux}/bin/tmux new-session -d -s work
      ''}";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
