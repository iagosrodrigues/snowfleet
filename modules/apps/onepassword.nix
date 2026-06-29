_: {
  flake.modules.nixos.onepassword =
    { pkgs, ... }:
    let
      nativeMessagingHost = pkgs.writeText "com.1password.1password.json" ''
        {
          "name": "com.1password.1password",
          "description": "1Password BrowserSupport",
          "path": "/run/wrappers/bin/1Password-BrowserSupport",
          "type": "stdio",
          "allowed_origins": [
            "chrome-extension://aeblfdkhhhdcdjpifhhbdiojplfjncoa/",
            "chrome-extension://bkpbhnjcbehoklfkljkkbbmipaphipgl/",
            "chrome-extension://dppgmdbiimibapkepcbdbmkaabgiofem/",
            "chrome-extension://gejiddohjgogedgjnonbofjigllpkmbf/",
            "chrome-extension://hjlinigoblmkhjejkmbegnoaljkphmgo/",
            "chrome-extension://khgocmkkpikpnmmkgmdnfckapcdkgfaf/"
          ]
        }
      '';
    in
    {
      programs._1password.enable = true;
      programs._1password-gui = {
        enable = true;
        polkitPolicyOwners = [ "iago" ];
      };
      environment.etc = {
        "1password/custom_allowed_browsers" = {
          text = ''
            helium
            helium-browser
            helium-wrapper
          '';
          mode = "0755";
        };
        # Helium reads Chromium's system-wide native messaging dir
        # (hardcoded at /etc/chromium/native-messaging-hosts/).
        "chromium/native-messaging-hosts/com.1password.1password.json".source = nativeMessagingHost;
      };
    };

  flake.modules.homeManager.onepassword = _: {
    home.persistence."/persist".directories = [
      ".config/1Password"
    ];

    # Start 1Password silently (minimized to tray) on login.
    xdg.configFile."autostart/1password.desktop".text = ''
      [Desktop Entry]
      Name=1Password
      Exec=1password --silent
      Terminal=false
      Type=Application
      Icon=1password
      X-GNOME-Autostart-enabled=true
    '';
  };
}
