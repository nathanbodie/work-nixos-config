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
