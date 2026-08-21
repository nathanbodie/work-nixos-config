{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/boot.nix
    ../../modules/nixos/core.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/gaming.nix
  ];

  networking.hostName = "home-pc";

  # Dual-GPU box: discrete RX 9070 XT (Navi 48/RDNA4) at PCI 03:00.0 already
  # drives the monitors and is X/Hyprland's primary GPU; the Granite Ridge iGPU
  # at 11:00.0 is only a secondary PRIME device with no displays attached.
  #
  # Do NOT pin the compositor's DRM device here (AQ_DRM_DEVICES / WLR_DRM_DEVICES
  # / DRI_PRIME) — forcing aquamarine's device list makes Hyprland exit on launch
  # and SDDM login-loops. The compositor picks the dGPU on its own.
  #
  # The only thing that can drift onto the iGPU is a Vulkan client picking the
  # "wrong" default device, so steer just those to the 9070 XT (1002:7550).
  # This is GLES-agnostic and cannot break the Hyprland/SDDM login path.
  environment.sessionVariables = {
    MESA_VK_DEVICE_SELECT = "1002:7550";
  };

  system.stateVersion = "25.11";
}
