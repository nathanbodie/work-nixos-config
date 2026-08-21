{ pkgs, ... }: {
  home.packages = with pkgs; [
    zathura            # PDF / PostScript viewer
    imv                # image viewer (Wayland, keyboard-driven)
    libreoffice-fresh  # docx / xlsx / pptx / odt / ods / odp
  ];

  # nvim is a terminal editor, so "open a text file" from a file manager needs
  # a desktop entry that launches it inside a terminal. This writes
  # ~/.local/share/applications/nvim.desktop (id: nvim.desktop) which the
  # mimeApps map below points text/* at. Ghostty is our terminal (see
  # desktop.nix); `-e` runs the given command in it.
  xdg.desktopEntries.nvim = {
    name = "Neovim";
    genericName = "Text Editor";
    comment = "Edit text files in Neovim";
    exec = "ghostty -e nvim %F";
    terminal = false;              # ghostty *is* the terminal
    icon = "nvim";
    categories = [ "Utility" "TextEditor" ];
    mimeType = [ "text/plain" ];
  };

  # Declarative default-application map. Home Manager owns ~/.config/mimeapps.list
  # once this is enabled, so the pre-existing browser / scheme handlers are
  # re-declared here too (they were previously written at runtime); dropping them
  # would break "click a link -> open browser".
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # ── Browser / scheme handlers (ported from the old runtime mimeapps.list) ──
      "x-scheme-handler/http"           = "zen.desktop";
      "x-scheme-handler/https"          = "zen.desktop";
      "x-scheme-handler/chrome"         = "zen.desktop";
      "text/html"                       = "zen.desktop";
      "application/xhtml+xml"           = "zen.desktop";
      "application/x-extension-htm"     = "zen.desktop";
      "application/x-extension-html"    = "zen.desktop";
      "application/x-extension-shtml"   = "zen.desktop";
      "application/x-extension-xhtml"   = "zen.desktop";
      "application/x-extension-xht"     = "zen.desktop";
      "x-scheme-handler/about"          = "helium.desktop";
      "x-scheme-handler/unknown"        = "helium.desktop";
      "x-scheme-handler/claude-cli"     = "claude-code-url-handler.desktop";
      "x-scheme-handler/slack"          = "slack.desktop";
      "x-scheme-handler/discord-409416265891971072" = "discord-409416265891971072.desktop";

      # ── PDFs / PostScript -> zathura ──
      "application/pdf"                 = "org.pwmt.zathura.desktop";
      "application/postscript"          = "org.pwmt.zathura.desktop";

      # ── Images -> imv ──
      "image/png"                       = "imv.desktop";
      "image/x-png"                     = "imv.desktop";
      "image/jpeg"                      = "imv.desktop";
      "image/gif"                       = "imv.desktop";
      "image/webp"                      = "imv.desktop";
      "image/bmp"                       = "imv.desktop";
      "image/tiff"                      = "imv.desktop";
      "image/svg+xml"                   = "imv.desktop";
      "image/heif"                      = "imv.desktop";
      "image/avif"                      = "imv.desktop";
      "image/jxl"                       = "imv.desktop";

      # ── Plain text / config / code -> nvim (in a terminal) ──
      "text/plain"                      = "nvim.desktop";
      "text/markdown"                   = "nvim.desktop";
      "text/x-shellscript"             = "nvim.desktop";
      "application/json"                = "nvim.desktop";
      "application/xml"                 = "nvim.desktop";
      "text/xml"                        = "nvim.desktop";

      # ── LibreOffice: word processing -> Writer ──
      "application/msword"                                                        = "writer.desktop";
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"   = "writer.desktop";
      "application/vnd.oasis.opendocument.text"                                   = "writer.desktop";
      "application/rtf"                                                           = "writer.desktop";

      # ── LibreOffice: spreadsheets -> Calc ──
      "application/vnd.ms-excel"                                                  = "calc.desktop";
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"         = "calc.desktop";
      "application/vnd.oasis.opendocument.spreadsheet"                            = "calc.desktop";
      "text/csv"                                                                  = "calc.desktop";

      # ── LibreOffice: presentations -> Impress ──
      "application/vnd.ms-powerpoint"                                             = "impress.desktop";
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "impress.desktop";
      "application/vnd.oasis.opendocument.presentation"                           = "impress.desktop";
    };
  };
}
