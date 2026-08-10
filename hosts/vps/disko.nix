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
        # Hetzner Cloud VMs may be BIOS- or UEFI-booted depending on the
        # instance. This 1M BIOS boot partition lets GRUB install its i386-pc
        # stage to the gap, so the same image boots either way. Without it a
        # BIOS-booting VM installs fine and then fails to boot.
        bios = {
          size = "1M";
          type = "EF02";
          priority = 1;
        };
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
