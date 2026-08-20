# Dev shell templates

Reusable `flake.nix` + `.envrc` starters for per-project dev shells, loaded
automatically by direnv + nix-direnv (configured in `modules/home/cli-tools.nix`).

## Use

From an empty (or existing) project directory:

```bash
nix flake init -t ~/.config/nixos#node-python   # copies flake.nix + .envrc
direnv allow                                     # trust the .envrc, load the shell
```

`nix flake init` won't clobber an existing `flake.nix`; move it aside first if needed.

## Available templates

| Name          | Toolchain                          |
|---------------|------------------------------------|
| `node-python` | Node 22 + pnpm, Python 3 + uv      |

Add a new one by dropping a folder under `templates/` and registering it in the
`templates` output of the repo root `flake.nix`.
