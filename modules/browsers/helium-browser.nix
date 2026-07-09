_:
let
  onePasswordManifest = ''
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
  flake.modules.nixos.helium-browser =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.helium-browser ];
    };

  flake.modules.homeManager.helium-browser =
    { pkgs, ... }:
    {
      home = {
        packages = [ pkgs.helium-browser ];
        file.".config/net.imput.helium/NativeMessagingHosts/com.1password.1password.json".text =
          onePasswordManifest;
        persistence."/persist".directories = [
          ".config/net.imput.helium"
        ];
      };
    };
}
