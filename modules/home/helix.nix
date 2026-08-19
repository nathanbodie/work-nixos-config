# Helix editor, set up to mirror the neovim config (../../../.dotfiles/nvim)
# as closely as Helix's design allows. See helix.README.md in this dir for the
# full nvim -> Helix crosswalk and the handful of things intentionally skipped
# because they cut against Helix's philosophy.
{ config, pkgs, ... }:
let
  # Faithful to the neovim config's global 2-space soft tabs. Helix has no
  # global indent setting (indentation is per-language), so we stamp the same
  # unit onto every language we configure below.
  indent2 = { tab-width = 2; unit = "  "; };

  # Hand-ported evergarden theme (variant "fall", accent "green") to match the
  # neovim colorscheme. Palette lifted verbatim from evergarden's fall palette;
  # scope->color mapping mirrors evergarden's hl/{syntax,editor}.lua and
  # theme.lua accent/diagnostic wiring, plus the user's overrides (float=mantle,
  # completion=surface0, sign=none). Styles (keyword/type/comment italic) match
  # evergarden's default style config.
  evergarden-fall = {
    "inherits" = "everforest_dark"; # fallback for any scope not set below

    # syntax --------------------------------------------------------------
    "comment" = { fg = "overlay2"; modifiers = [ "italic" ]; };
    "comment.block.documentation" = "overlay2";

    "keyword" = { fg = "red"; modifiers = [ "italic" ]; };
    "keyword.control" = { fg = "red"; modifiers = [ "italic" ]; };
    "keyword.control.import" = "cherry";
    "keyword.control.return" = { fg = "red"; modifiers = [ "italic" ]; };
    "keyword.function" = { fg = "red"; modifiers = [ "italic" ]; };
    "keyword.storage" = "red";
    "keyword.operator" = "orange";
    "keyword.directive" = "cherry";

    "function" = "green";
    "function.builtin" = "orange";
    "function.method" = "green";
    "function.macro" = "aqua";
    "constructor" = "green";

    "type" = { fg = "yellow"; modifiers = [ "italic" ]; };
    "type.builtin" = { fg = "yellow"; modifiers = [ "italic" ]; };
    "type.enum.variant" = "pink";

    "constant" = "pink";
    "constant.builtin" = "pink";
    "constant.numeric" = "pink";
    "constant.character" = "lime";
    "constant.character.escape" = "yellow";

    "string" = "lime";
    "string.regexp" = "yellow";
    "string.special" = "aqua";
    "string.special.path" = "blue";
    "string.special.url" = { fg = "blue"; modifiers = [ "underlined" ]; };

    "variable" = "text";
    "variable.builtin" = "pink";
    "variable.parameter" = "text";
    "variable.other.member" = "skye";

    "label" = "aqua";
    "punctuation" = "overlay1";
    "punctuation.delimiter" = "overlay1";
    "punctuation.bracket" = "overlay1";
    "punctuation.special" = "aqua";
    "operator" = "subtext0";

    "tag" = "skye";
    "attribute" = "cherry";
    "namespace" = "snow";
    "special" = "aqua";

    "markup.heading" = "cherry";
    "markup.heading.1" = "red";
    "markup.heading.2" = "orange";
    "markup.heading.3" = "yellow";
    "markup.heading.4" = "green";
    "markup.heading.5" = "aqua";
    "markup.heading.6" = "blue";
    "markup.bold" = { fg = "aqua"; modifiers = [ "bold" ]; };
    "markup.italic" = { fg = "skye"; modifiers = [ "italic" ]; };
    "markup.strikethrough" = { modifiers = [ "crossed_out" ]; };
    "markup.link.url" = { fg = "blue"; modifiers = [ "underlined" ]; };
    "markup.link.text" = "skye";
    "markup.link.label" = "skye";
    "markup.raw" = "overlay1";
    "markup.list" = "overlay1";
    "markup.quote" = "overlay2";

    "diff.plus" = "green";
    "diff.minus" = "red";
    "diff.delta" = "aqua";

    # ui ------------------------------------------------------------------
    "ui.background" = { bg = "base"; };
    "ui.text" = "text";
    "ui.text.focus" = "text";
    "ui.text.inactive" = "overlay2";

    "ui.cursor" = { fg = "crust"; bg = "subtext0"; };
    "ui.cursor.primary" = { fg = "crust"; bg = "green"; };
    "ui.cursor.primary.insert" = { fg = "crust"; bg = "text"; };
    "ui.cursor.primary.select" = { fg = "crust"; bg = "pink"; };
    "ui.cursor.match" = { fg = "orange"; modifiers = [ "underlined" ]; };

    "ui.selection" = { bg = "surface1"; };
    "ui.selection.primary" = { bg = "surface1"; };

    "ui.cursorline.primary" = { bg = "surface0"; };
    "ui.cursorline.secondary" = { bg = "surface0"; };

    "ui.linenr" = { fg = "surface2"; };
    "ui.linenr.selected" = { fg = "overlay2"; };
    "ui.gutter" = { bg = "base"; };

    "ui.statusline" = { fg = "subtext0"; bg = "mantle"; };
    "ui.statusline.inactive" = { fg = "overlay1"; bg = "mantle"; };
    "ui.statusline.normal" = { fg = "crust"; bg = "green"; modifiers = [ "bold" ]; };
    "ui.statusline.insert" = { fg = "crust"; bg = "text"; modifiers = [ "bold" ]; };
    "ui.statusline.select" = { fg = "crust"; bg = "pink"; modifiers = [ "bold" ]; };

    "ui.popup" = { fg = "text"; bg = "mantle"; };
    "ui.popup.info" = { fg = "text"; bg = "mantle"; };
    "ui.window" = { fg = "surface1"; };
    "ui.help" = { fg = "text"; bg = "mantle"; };

    "ui.menu" = { fg = "text"; bg = "surface0"; };
    "ui.menu.selected" = { fg = "text"; bg = "surface1"; modifiers = [ "bold" ]; };
    "ui.menu.scroll" = { fg = "overlay0"; bg = "surface1"; };

    "ui.virtual.whitespace" = "overlay0";
    "ui.virtual.ruler" = { bg = "surface0"; };
    "ui.virtual.indent-guide" = "surface1";
    "ui.virtual.inlay-hint" = { fg = "overlay1"; };
    "ui.virtual.jump-label" = { fg = "green"; modifiers = [ "bold" ]; };
    "ui.virtual.wrap" = "surface1";

    "ui.bufferline" = { fg = "overlay1"; bg = "surface0"; };
    "ui.bufferline.active" = { fg = "crust"; bg = "green"; };
    "ui.bufferline.background" = { bg = "mantle"; };

    "ui.highlight" = { bg = "surface1"; };

    # diagnostics ---------------------------------------------------------
    "diagnostic.error" = { underline = { color = "red"; style = "curl"; }; };
    "diagnostic.warning" = { underline = { color = "yellow"; style = "curl"; }; };
    "diagnostic.info" = { underline = { color = "aqua"; style = "curl"; }; };
    "diagnostic.hint" = { underline = { color = "skye"; style = "curl"; }; };
    "diagnostic.unnecessary" = { modifiers = [ "dim" ]; };
    "error" = "red";
    "warning" = "yellow";
    "info" = "aqua";
    "hint" = "skye";

    # evergarden "fall" palette, verbatim ---------------------------------
    "palette" = {
      red = "#f57f82";
      orange = "#f7a182";
      yellow = "#f5d098";
      lime = "#dbe6af";
      green = "#cbe3b3";
      aqua = "#b3e3ca";
      skye = "#b3e6db";
      snow = "#afd9e6";
      blue = "#b2caed";
      purple = "#d2bdf3";
      pink = "#f3c0e5";
      cherry = "#fae6ef";
      text = "#f8f9e8";
      subtext1 = "#adc9bc";
      subtext0 = "#96b4aa";
      overlay2 = "#839e9a";
      overlay1 = "#6f8788";
      overlay0 = "#58686d";
      surface2 = "#4a585c";
      surface1 = "#374145";
      surface0 = "#2b3337";
      base = "#232a2e";
      mantle = "#1c2225";
      crust = "#171c1f";
    };
  };
in
{
  programs.helix = {
    enable = true;
    # Helix is the default $EDITOR (zsh's EDITOR in cli-tools.nix matches).
    defaultEditor = true;

    themes.evergarden-fall = evergarden-fall;

    # Language servers + tree-sitter tooling on hx's PATH, so servers resolve
    # even when they aren't installed globally (they aren't, on the vps host).
    extraPackages = with pkgs; [
      lua-language-server
      typescript-language-server
      rust-analyzer
      basedpyright
      ols
      clang-tools # clangd
      nixd
    ];

    settings = {
      # Hand-ported evergarden "fall"/green theme (defined above, written to
      # themes/evergarden-fall.toml). Mirrors the neovim colorscheme.
      theme = "evergarden-fall";

      editor = {
        line-number = "relative"; # number + relativenumber
        true-color = true; # termguicolors
        popup-border = "all"; # closest to winborder="rounded" (no rounded option)
        color-modes = true;
        bufferline = "multiple";

        soft-wrap.enable = false; # wrap = false

        cursor-shape.insert = "bar";

        file-picker.hidden = false;

        # gitsigns equivalent: the diff gutter is on by default. Listed
        # explicitly so the intent is obvious.
        gutters = [ "diagnostics" "spacer" "line-numbers" "spacer" "diff" ];

        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        # mini.statusline replica. Helix has no "cwd" element, so that piece of
        # the nvim statusline is dropped (noted in README).
        statusline = {
          left = [ "mode" "spinner" "version-control" "file-name" "file-modification-indicator" ];
          center = [ ];
          right = [ "diagnostics" "file-type" "total-line-numbers" "position" ];
          separator = "│";
          mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
        };
      };

      # Leader (space) bindings. Most nvim leader maps already have a native
      # Helix space-menu home (space f files, space b buffers, space / grep,
      # space r rename, ...); those are kept as-is and documented in the README
      # crosswalk rather than clobbering Helix defaults. Only the maps with no
      # native single-key equivalent are (re)bound here.
      keys.normal.space = {
        # nvim <leader>lf -> :format
        l.f = ":format";
      };
    };

    languages = {
      language-server = {
        lua-language-server.config.Lua = {
          diagnostics.globals = [ "vim" ];
          workspace.checkThirdParty = false;
        };

        # Fallback TS install for projects without a local `typescript` dep,
        # mirroring the nvim init_options. Path is nvim-era and may not exist;
        # harmless when absent (see README).
        typescript-language-server = {
          command = "typescript-language-server";
          args = [ "--stdio" ];
          config.tsserver.path =
            "${config.home.homeDirectory}/.local/share/ts5/node_modules/typescript/lib/tsserver.js";
        };

        rust-analyzer.config."rust-analyzer" = {
          cargo.allFeatures = true;
          check.command = "clippy";
        };

        basedpyright = {
          command = "basedpyright-langserver";
          args = [ "--stdio" ];
        };

        ols.command = "ols";
        nixd.command = "nixd";
      };

      language = [
        {
          name = "lua";
          language-servers = [ "lua-language-server" ];
          indent = indent2;
        }
        {
          name = "typescript";
          language-servers = [ "typescript-language-server" ];
          indent = indent2;
        }
        {
          name = "tsx";
          language-servers = [ "typescript-language-server" ];
          indent = indent2;
        }
        {
          name = "javascript";
          language-servers = [ "typescript-language-server" ];
          indent = indent2;
        }
        {
          name = "jsx";
          language-servers = [ "typescript-language-server" ];
          indent = indent2;
        }
        {
          name = "rust";
          language-servers = [ "rust-analyzer" ];
          indent = indent2;
        }
        {
          name = "python";
          language-servers = [ "basedpyright" ];
          indent = indent2;
        }
        {
          name = "odin";
          language-servers = [ "ols" ];
          indent = indent2;
        }
        {
          name = "c";
          language-servers = [ "clangd" ];
          indent = indent2;
        }
        {
          name = "cpp";
          language-servers = [ "clangd" ];
          indent = indent2;
        }
        {
          name = "nix";
          language-servers = [ "nixd" ];
          indent = indent2;
        }
      ];
    };
  };
}
