# Disk layout for nixos-anywhere provisioning.
# Adjust `device` if your VPS uses /dev/vda instead of /dev/sda.
# Swap is a file (configured in default.nix) rather than a partition so the
# disk can be resized without repartitioning.
{ ... }: {
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/sda";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
