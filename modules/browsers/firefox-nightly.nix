{ inputs, ... }: {
  # Default browser. System-level (/etc/xdg/mimeapps.list) so it survives the
  # tmpfs root and still leaves ~/.config/mimeapps.list writable for apps that
  # register their own schemes at runtime. Without it KDE falls back to any
  # app claiming http(s) — e.g. chatgpt.desktop (Codex).
  flake.modules.nixos.firefox-nightly = {
    xdg.mime.defaultApplications = {
      "text/html" = "firefox-nightly.desktop";
      "application/xhtml+xml" = "firefox-nightly.desktop";
      "x-scheme-handler/http" = "firefox-nightly.desktop";
      "x-scheme-handler/https" = "firefox-nightly.desktop";
    };
  };

  flake.modules.homeManager.firefox-nightly = { pkgs, ... }: {
    home.persistence."/persist".directories = [
      ".mozilla/firefox"
    ];

    home.packages = [
      inputs.firefox-nightly.packages.${pkgs.stdenv.hostPlatform.system}.firefox-nightly-bin
    ];
  };
}
