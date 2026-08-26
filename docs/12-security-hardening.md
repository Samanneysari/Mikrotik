# 12 — MTCNA+ Security Hardening and Modern VPN Choices

Security is a system of layers: supported software, limited exposure, strong identity, least privilege, explicit firewall policy, protected configuration, monitoring, and tested recovery.

## 1. Inventory before hardening

```routeros
/system resource print
/system package print
/user print detail
/user group print detail
/ip service print
/tool mac-server print
/tool mac-server mac-winbox print
/ip neighbor discovery-settings print
/ip firewall filter print stats
/ipv6 firewall filter print stats
/system scheduler print detail
/system script print detail
/certificate print detail
```

Do not delete unknown automation or firewall rules during discovery. Identify purpose and owner first.

## 2. Management-plane checklist

- use named accounts and remove/disable unused ones;
- create least-privilege groups for monitoring/helpdesk/automation;
- prefer SSH keys or centralized AAA where the operational model supports it;
- disable unused IP services; restrict source on required services;
- restrict MAC-WinBox, MAC server, neighbor discovery, RoMON, bandwidth server, DNS recursion, and proxy features;
- keep management in a dedicated VLAN or VRF with explicit firewall policy;
- use NTP and remote logs;
- protect backups, exports, certificates, private keys, RADIUS/IPsec secrets;
- patch through a tested channel and retain recovery access.

Service restriction is defense in depth:

```routeros
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/ip service set ssh address=192.168.99.0/24
/ip service set winbox address=192.168.99.0/24
```

Still add input-chain rules. A source field is not a complete firewall policy.

## 3. Explicit input policy

```routeros
/ip firewall address-list add list=MGMT-SOURCES address=192.168.99.0/24
/ip firewall filter
add chain=input action=accept connection-state=established,related,untracked
add chain=input action=drop connection-state=invalid
add chain=input action=accept protocol=icmp
add chain=input action=accept src-address-list=MGMT-SOURCES in-interface-list=MGMT \
    protocol=tcp dst-port=22,8291 comment="SSH/WinBox from management"
add chain=input action=accept src-address=192.168.10.0/24 in-interface=vlan10-users \
    protocol=udp dst-port=53 comment="client DNS UDP"
add chain=input action=accept src-address=192.168.10.0/24 in-interface=vlan10-users \
    protocol=tcp dst-port=53 comment="client DNS TCP"
add chain=input action=drop comment="default deny router services"
```

Add DHCP/OSPF/BGP/IPsec/WireGuard or other control traffic only where the router actually needs it. Interface lists and source/destination matches should express the trust boundary.

## 4. SSH keys and groups

Create a role based on required policy names rather than granting `full` by default. Import a user's public key through the current RouterOS user/SSH-key interface. Never upload a private key to the router for user authentication.

After key login works from an independent session, decide whether password login can be reduced according to current RouterOS capabilities and your recovery plan.

## 5. Certificates and time

TLS/IPsec certificate validation depends on correct time and trust. Configure NTP and timezone before enrollment:

```routeros
/system clock set time-zone-name=Europe/Berlin
/system ntp client set enabled=yes
/system ntp client servers add address=time.cloudflare.com
/system ntp client print
/certificate print detail
```

Use your organization's CA or a properly managed trust chain. Self-signed certificates are not automatically trusted just because encryption occurs.

## 6. WireGuard remote-management example

WireGuard is a routed encrypted interface. Router:

```routeros
/interface wireguard add name=wg-admin listen-port=13231 mtu=1420 comment="admin VPN"
/ip address add address=10.200.0.1/24 interface=wg-admin
/interface wireguard print detail where name=wg-admin
```

The print output exposes the router's public key; the private key must remain secret. Add one client:

```routeros
/interface wireguard peers add interface=wg-admin \
    public-key="CLIENT_PUBLIC_KEY_BASE64" allowed-address=10.200.0.2/32 \
    comment="admin laptop"
```

Firewall and policy:

```routeros
/ip firewall filter add chain=input in-interface-list=WAN protocol=udp dst-port=13231 \
    action=accept comment="WireGuard handshake"
/ip firewall filter add chain=input in-interface=wg-admin src-address=10.200.0.2 \
    protocol=tcp dst-port=22,8291 action=accept comment="VPN management"
```

Place these before the relevant final drop. `allowed-address` both associates destination prefixes with a peer and constrains accepted source addresses; overlapping peer ranges are a routing/identity error. The client needs the router public key, endpoint, its private address, DNS as desired, and carefully scoped allowed routes.

Verify:

```routeros
/interface wireguard peers print detail
/ip firewall filter print stats where comment~"WireGuard|VPN"
/ping 10.200.0.2 src-address=10.200.0.1
```

Handshake time alone does not prove management firewall/routing works.

## 7. IPsec/IKEv2 mental model

- proposal: data-plane algorithms/lifetimes;
- profile: IKE negotiation settings;
- peer: remote endpoint/matching;
- identity: authentication method and credentials/certificates;
- policy/template: which traffic is protected;
- installed SA: negotiated live cryptographic state.

Troubleshoot in stages: underlay reachability → IKE peer/identity/authentication → child SA/proposal/policy → routing/NAT bypass/firewall → MTU. Avoid weak algorithms copied from old examples. Use the current official IPsec guide for interoperable configurations.

## 8. Other exposures

Review and restrict/disable as appropriate:

```routeros
/ip upnp print
/ip socks print
/ip proxy print
/tool bandwidth-server print
/ip cloud print
/tool romon print
```

Features are not vulnerabilities merely because they exist; unnecessary enabled reachability is avoidable attack surface.

## 9. Backup and secret hygiene

- encrypt binary backups with unique strong passwords;
- store backups outside the router with access control and retention;
- use `show-sensitive=no` for review artifacts;
- assume an export made with sensitive values is a credential bundle;
- rotate credentials after accidental publication;
- do not paste full exports into public issues.

## 10. Hardening verification

From each zone, test what is allowed and denied. Record:

- exposed TCP/UDP services;
- MAC discovery/WinBox reachability;
- IPv4 and IPv6 firewall counters;
- VPN handshake and permitted routes;
- unauthorized-source denial;
- log visibility and time correctness;
- backup restore and console recovery.

Security is proven by negative tests, not by the existence of a final drop rule.
