# Helix config — neovim parity notes

`helix.nix` sets up Helix (`hx`) via home-manager to mirror the neovim config
(`~/.dotfiles/nvim`) as closely as Helix's design allows. Helix is opinionated
and batteries-included, so much of the nvim setup (pickers, pairs, statusline,
which-key, completion, git gutter) is native and needs no plugin. This file
records what maps 1:1, what maps to a Helix-native equivalent, and what was
skipped because it fights Helix's philosophy.

## Editor options (init.lua)

| nvim | Helix | notes |
|---|---|---|
| `number` + `relativenumber` | `editor.line-number = "relative"` | current line shows absolute automatically |
| `signcolumn = "yes"` | default gutters | always present in Helix |
| `expandtab`, `tabstop/shiftwidth = 2` | per-language `indent = { tab-width = 2; unit = "  " }` | Helix has **no global** indent; set on each configured language |
| `termguicolors` | `editor.true-color = true` | |
| `wrap = false` | `editor.soft-wrap.enable = false` | |
| `winborder = "rounded"` | `editor.popup-border = "all"` | **partial** — Helix has no rounded-corner option |
| `clipboard = "unnamedplus"` | *(skipped)* | see "Skipped" below |

## Plugins

| nvim plugin | Helix | notes |
|---|---|---|
| `mini.pick` | built-in pickers (`space f`, `space b`, `space /`, `space s`) | |
| `mini.pairs` | `editor.auto-pairs` (on by default) | |
| `mini.statusline` | `editor.statusline` | replicated; **no `cwd` element** exists in Helix so that segment is dropped |
| `which-key` | built-in space/`g`/`z` menus | automatic |
| `blink.cmp` + `friendly-snippets` | built-in LSP completion | LSP-provided snippets work; the `friendly-snippets` corpus has no Helix equivalent |
| `gitsigns` | `diff` gutter (default) | listed explicitly in `gutters` |
| `direnv.vim` | shell-level direnv | launch `hx` from inside a direnv'd dir; Helix has no in-editor re-exec on env change |
| `evergarden` colorscheme | custom `evergarden-fall` theme | hand-ported in `helix.nix` — see "Theme" below |
| `oil.nvim` | *(skipped)* | see "Skipped" below |

## Keymaps (keymap.lua)

nvim leader is `<space>`; so is Helix's. Most nvim leader maps already have a
native Helix space-menu binding — those are **kept native** and listed here as a
crosswalk instead of overriding Helix defaults (overriding `space r`/`space g`
would clobber `rename_symbol` / the git-changed-file picker).

| nvim | Helix | |
|---|---|---|
| `<leader>f` files | `space f` | identical |
| `<leader>r` buffers | `space b` | Helix `space r` = rename |
| `<leader>g` live grep | `space /` | Helix `space g` = changed-file (git) picker |
| `<leader>e` line diagnostics | `space d` | diagnostics picker; diagnostics also render inline + on hover (`space k`) |
| `<leader>lf` format | `space l f` (→ `:format`) | rebound to match |
| `<leader>y` / `<leader>d` clipboard | `space y` / `space p` / `space R` | native clipboard register ops |
| `<leader>h` help picker | *(none)* | Helix has no `:help`-style docs system |
| `<leader>o` oil | *(none)* | see "Skipped" |
| `<leader>R` reload config | `:config-reload` | command, not bound to a key (would clobber `space R`) |
| `<leader>?` which-key | `space ?` command palette | native |

## Theme

`evergarden-fall` is a hand-ported Helix theme defined inline in `helix.nix`
(written to `~/.config/helix/themes/evergarden-fall.toml`). It reproduces the
neovim `evergarden` colorscheme with the same options: variant **fall**, accent
**green**, plus the editor overrides (float = `mantle`, completion = `surface0`,
sign = `none`).

- **Palette**: copied verbatim from evergarden's `palettes/fall.lua`.
- **Scope mapping**: mirrors evergarden's `hl/syntax.lua`, `hl/editor.lua`, and
  `theme.lua` (accent/diagnostic/diff wiring). Keyword/type/comment carry the
  same default `italic` style; statusline mode colors match evergarden's lualine
  integration (normal = green, insert = text, select = pink).
- **`inherits = "everforest_dark"`**: only a safety net for any Helix scope not
  explicitly set here — every meaningful scope is overridden above it.

Helix has a smaller, tree-sitter-based scope vocabulary than neovim's treesitter
`@`-captures, so this is a faithful port, not a byte-identical one: some fine
neovim distinctions (e.g. per-language `@` overrides) collapse onto a single
Helix scope. Colors, accents, and styles match.

## Skipped (against Helix philosophy)

- **`clipboard = "unnamedplus"` (unnamed register = system clipboard).** Helix
  deliberately keeps the yank register and the system clipboard separate, and
  exposes explicit clipboard ops (`space y` yank, `space p` paste,
  `space R` replace-with-clipboard). There's no supported global to alias them.
  Use the `space` clipboard bindings.
- **`oil.nvim` (editable buffer-as-directory file manager).** No equivalent —
  Helix's model is pickers + `:open`, plus an experimental read-mostly
  `file_explorer` (`space e` on recent builds). The nvim "edit the filesystem
  like a buffer" workflow isn't a Helix concept, so it's dropped rather than
  approximated poorly.
- **`<leader>R` live Lua config reload.** nvim re-`dofile`s its runtime; Helix
  config is static TOML. Nearest is the `:config-reload` command.

## Caveats

- **Odin (`ols`)**: depends on Helix shipping/fetching an `odin` tree-sitter
  grammar. Server config is in place; syntax highlighting relies on the grammar
  being available in your Helix build.
- **TypeScript fallback path** (`~/.local/share/ts5/.../tsserver.js`) is carried
  over verbatim from the nvim config. It's harmless if that path doesn't exist;
  local project `typescript` deps are preferred anyway.
- **LSP servers** are pulled in via `programs.helix.extraPackages` (heavy on a
  minimal host like the vps). Trim that list per-host if you don't need every
  language there.
