{
  description = "Node + Python dev shell";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      # Add more systems here if you work across machines.
      systems = [ "x86_64-linux" ];
      forAll = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in {
      devShells = forAll (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs_22
            pnpm
            python3
            uv          # fast Python venv / dependency manager
          ];

          # Runs when the shell is entered (direnv triggers this on `cd`).
          shellHook = ''
            echo "node $(node --version) · python $(python3 --version)"
          '';
        };
      });
    };
}
