let
  nate = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID1w4OTAaFlD4l9GSZUbYUdSVFSW0CYd3o5r00Ra3UBT nathan@bodie.dev";

  # Add the VPS host key here after first provisioning so the host itself
  # can decrypt secrets at boot (without your laptop present):
  #   ssh-keyscan -t ed25519 <vps-ip>
  # vps = "ssh-ed25519 AAAA...";
in {
  "secrets/tailscale-authkey.age".publicKeys = [ nate /* vps */ ];
}
