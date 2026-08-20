{ pkgs, config, ... }:
# Cloud sync via rclone (FOSS, very actively maintained). One tool handles both
# Dropbox and OneDrive through `bisync` (bidirectional sync) on a systemd timer.
#
# One-time setup (interactive OAuth tokens are secret, so they can't be
# declared here):
#   1. rclone config          # create remotes named exactly `dropbox` and `onedrive`
#   2. rclone bisync dropbox:  ~/Dropbox  --resync   # seed the first sync
#      rclone bisync onedrive: ~/OneDrive --resync
# After the initial --resync, the timers below keep both dirs in sync.
let
  home = config.home.homeDirectory;

  # Build a oneshot service + timer pair that bisyncs one remote.
  mkSync = { remote, dir, onCalendar }: {
    services."rclone-${remote}" = {
      Unit.Description = "rclone bisync for ${remote}";
      Service = {
        Type = "oneshot";
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${dir}";
        ExecStart = ''
          ${pkgs.rclone}/bin/rclone bisync ${remote}: ${dir} \
            --create-empty-src-dirs --resilient --recover -v
        '';
      };
    };
    timers."rclone-${remote}" = {
      Unit.Description = "Periodic rclone bisync for ${remote}";
      Timer = {
        OnCalendar = onCalendar;
        Persistent = true;   # catch up runs missed while suspended/off
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };

  dropbox  = mkSync { remote = "dropbox";  dir = "${home}/Dropbox";  onCalendar = "*:0/15"; };
  onedrive = mkSync { remote = "onedrive"; dir = "${home}/OneDrive"; onCalendar = "*:0/15"; };
in {
  home.packages = [ pkgs.rclone ];

  systemd.user.services = dropbox.services // onedrive.services;
  systemd.user.timers   = dropbox.timers   // onedrive.timers;
}
