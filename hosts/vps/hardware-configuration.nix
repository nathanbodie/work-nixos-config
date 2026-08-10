# Placeholder — replace with real output of `nixos-generate-config` after
# first provisioning via nixos-anywhere. The real file will have correct
# UUIDs, interface names, and kernel modules for the actual VPS hardware.
{ modulesPath, lib, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci" "virtio_pci" "virtio_scsi" "usbhid"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = "x86_64-linux";
}
