_: {
  flake.modules.homeManager.qbittorrent =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.qbittorrent ];

      home.persistence."/persist".directories = [
        # Settings, categories, watched folders, and per-torrent resume data
        # (BT_backup/*.fastresume tracks uploaded/downloaded bytes for ratio).
        ".config/qBittorrent"
        # Logs and GeoIP cache.
        ".local/share/qBittorrent"
      ];
    };
}
