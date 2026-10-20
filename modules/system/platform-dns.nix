_: {
  # Forward only platform.test to the Platform project's CoreDNS so host
  # browsers resolve *.platform.test (see Platform docs/runbooks/host-dns.md).
  # resolveLocalQueries (default) points resolvconf at 127.0.0.1; everything
  # else still goes to the existing resolvers (Tailscale MagicDNS).
  flake.modules.nixos.platform-dns = {
    security.pki.certificateFiles = [ ./platform-ca.crt ];
    services.dnsmasq = {
      enable = true;
      settings = {
        server = [ "/platform.test/172.30.0.10" ];
        # Loopback only: libvirt runs its own dnsmasq on virbr0.
        # resolvconf lists both 127.0.0.1 and ::1 as nameservers.
        listen-address = [
          "127.0.0.1"
          "::1"
        ];
        bind-interfaces = true;
      };
    };
  };
}
