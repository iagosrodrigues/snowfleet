_: {
  flake.modules.homeManager.proton-drive-cli =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.proton-drive-cli ];

      # The CLI is XDG-aware and namespaces its files under `proton-drive-cli`
      # (confirmed via its log path ~/.local/state/proton-drive-cli/). Auth
      # tokens go to the libsecret secret store (KWallet), persisted separately;
      # these dirs hold the session/config/state the login needs.
      home.persistence."/persist".directories = [
        ".config/proton-drive-cli"
        ".local/share/proton-drive-cli"
        ".local/state/proton-drive-cli"
      ];
    };
}
