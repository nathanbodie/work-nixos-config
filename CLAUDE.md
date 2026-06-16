# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
# Rebuild and switch (run as root or with sudo)
sudo nixos-rebuild switch --flake .#<hostname>

# Test a build without switching
sudo nixos-rebuild test --flake .#<hostname>

# Build without activating (check for errors)
sudo nixos-rebuild build --flake .#<hostname>

# Update all flake inputs
nix flake update

# Update a single input
nix flake update hyprland

# Check flake outputs
nix flake show

# Search available packages
nix search nixpkgs <term>

# Format nix files (if alejandra or nixfmt is available)
alejandra .
```

## Target Architecture

This repo is being restructured from a flat `configuration.nix` into a modular multi-host flake. The planned layout:

```
flake.nix                       # inputs: nixpkgs (unstable), home-manager, hyprland, etc.
                                # mkHost helper to reduce per-host boilerplate
modules/
  nixos/                        # NixOS system modules (shared, split from configuration.nix)
    boot.nix                    # grub, EFI, kernel
    core.nix                    # users, locale, audio, networking, SSH, nix settings
    desktop.nix                 # hyprland, sddm, polkit, bluetooth, graphics, gaming
  home/                         # Home Manager modules (replacing Stow dotfiles)
    base.nix                    # shell (zsh, tmux), core CLI tools
    desktop.nix                 # hyprland config, waybar, wofi, dunst, hyprpaper, hyprlock
    media.nix                   # media apps, fonts
hosts/
  TSEP45550075/
    default.nix                 # imports modules + hardware, sets hostname/stateVersion
    hardware-configuration.nix
  home-pc/
    default.nix
    hardware-configuration.nix
home/
  nate/
    TSEP45550075.nix            # per-user HM config for this host
    home-pc.nix
```

## Hosts

| Hostname | Notes |
|---|---|
| `TSEP45550075` | Current machine — AMD CPU/GPU, Steam, Sunshine, Waydroid |
| `home-pc` | Second machine — config to be built out in a later phase |

The flake `nixosConfigurations` key **must match the hostname** so `nixos-rebuild --flake .` works without specifying `#hostname`. A `mkHost` helper in `flake.nix` will wrap `nixpkgs.lib.nixosSystem` with shared `specialArgs` and the HM module.

## Key Design Decisions

**Channel**: `nixos-unstable` — do not pin to a stable release.

**Home Manager**: Use the `home-manager` NixOS module (not the standalone CLI). Add it as a flake input with `inputs.home-manager.follows = "nixpkgs"`. Wire it via `home-manager.nixosModules.home-manager` in each host's module list. User config lives under `home-manager.users.nate`.

**No Stow**: After Home Manager is in place, `stow` is removed from `environment.systemPackages`. All dotfiles previously managed by Stow move into `modules/home/`.

**Hyprland**: Sourced from the upstream `hyprland` flake input (not nixpkgs) to track the latest release. The `portalPackage` must come from the same input. Config files (`hyprland.conf`, etc.) will be managed by Home Manager via `wayland.windowManager.hyprland`.

**`specialArgs`**: Pass `{ inherit inputs; }` through to all modules so flake inputs (hyprland packages, zen-browser, rose-pine-hyprcursor) are accessible as `inputs.*` inside any module.

**`system.stateVersion`**: Currently `"25.11"`. Do not change it — it anchors stateful paths set at first install.

## Current State

The repo currently has a single monolithic `configuration.nix` with everything for the home-pc. `hardware-configuration.nix` contains UUIDs and AMD/NVMe specifics for that machine. The flake only declares one output (`nixosConfigurations.nixos`). Home Manager is not yet wired in.
