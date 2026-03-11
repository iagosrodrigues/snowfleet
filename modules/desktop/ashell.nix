_: {
  flake.modules.homeManager.ashell = _: {
    programs.ashell = {
      enable = true;
      settings = {
        log_level = "error";
        outputs = "All";
        position = "Top";
        app_launcher_cmd = "fuzzel";

        modules = {
          left = [
            "AppLauncher"
            "Workspaces"
            "WindowTitle"
          ];
          center = [ "MediaPlayer" ];
          right = [
            "Tray"
            "SystemInfo"
            [
              "Clock"
              "Clipboard"
              "Privacy"
              "Settings"
            ]
          ];
        };

        workspaces = {
          visibility_mode = "All";
          enable_workspace_filling = false;
        };

        system = {
          cpu_warn_threshold = 60;
          cpu_alert_threshold = 80;
          mem_warn_threshold = 70;
          mem_alert_threshold = 85;
          temp_warn_threshold = 60;
          temp_alert_threshold = 80;
        };

        settings = { };

        appearance = {
          style = "Islands";
          opacity = 1.0;
        };
      };
    };
  };
}
