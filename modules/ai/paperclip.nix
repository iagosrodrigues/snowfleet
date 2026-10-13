_:
let
  # Tailscale MagicDNS name of hellplace; Telegram calls this over Funnel.
  publicHost = "hellplace.tail5ef57.ts.net";
  # Only the chat webhook path is published. The instance runs in
  # local_trusted mode, so exposing the whole port would grant board access.
  webhookPath = "/api/chat-webhooks";
in
{
  flake.modules.nixos.paperclip =
    { config, ... }:
    let
      tailscale = "${config.services.tailscale.package}/bin/tailscale";
    in
    {
      systemd.services.paperclip-webhook-funnel = {
        description = "Expose Paperclip chat webhooks through Tailscale Funnel";
        after = [ "tailscaled.service" ];
        wants = [ "tailscaled.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${tailscale} funnel --bg --set-path ${webhookPath} http://127.0.0.1:3100${webhookPath}";
          ExecStop = "${tailscale} funnel --set-path ${webhookPath} off";
          # tailscaled may still be starting at boot.
          Restart = "on-failure";
          RestartSec = 10;
        };
      };
    };

  flake.modules.homeManager.paperclip =
    { pkgs, ... }:
    {
      home = {
        packages = [ pkgs.llm-agents.paperclip ];

        sessionVariables = {
          PAPERCLIP_CHAT_WEBHOOK_PUBLIC_URL = "https://${publicHost}";
          PAPERCLIP_ALLOWED_HOSTNAMES = publicHost;
        };

        # instances: embedded postgres, storage, backups, secrets/master.key, logs
        persistence."/persist".directories = [ ".paperclip" ];
      };
    };
}
