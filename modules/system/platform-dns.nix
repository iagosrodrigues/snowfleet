_: {
  # dnsmasq on loopback is the system resolver: resolveLocalQueries (default)
  # points resolvconf at 127.0.0.1, and upstreams come from DHCP (the router).
  # platform.test goes to the Platform project's CoreDNS so host browsers
  # resolve *.platform.test (see Platform docs/runbooks/host-dns.md), and the
  # tailnet suffix goes to Tailscale MagicDNS.
  flake.modules.nixos.platform-dns = {
    security.pki.certificateFiles = [ ./platform-ca.crt ];

    # With accept-dns on, Tailscale registers 100.100.100.100 as dnsmasq's only
    # upstream while MagicDNS falls back to the OS resolvers, which include
    # 127.0.0.1 — a forwarding loop that saturates dnsmasq. Tailnet names are
    # routed explicitly below instead.
    services.tailscale.extraSetFlags = [ "--accept-dns=false" ];

    services.dnsmasq = {
      enable = true;
      settings = {
        server = [
          "/platform.test/172.30.0.10"
          "/tail5ef57.ts.net/100.100.100.100"
        ];
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
