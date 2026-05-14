{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ... } @ inputs: {
    nixosConfigurations.TSEP45550075 = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };  # <-- this is the key part
      modules = [
        ./configuration.nix
	inputs.silentSDDM.nixosModules.default
      ];
    };
  };
}
