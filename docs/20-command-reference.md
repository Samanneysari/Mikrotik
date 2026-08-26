# 20 — RouterOS and WinBox Field Reference

This is a lookup sheet, not a substitute for chapters or the generated official CLI reference.

## Management and system

| Task | CLI | WinBox |
|---|---|---|
| resources/version | `/system resource print` | System → Resources |
| packages/update | `/system package print`; `/system package update` | System → Packages |
| RouterBOOT | `/system routerboard print` | System → RouterBOARD |
| identity | `/system identity` | System → Identity |
| users/groups | `/user`; `/user group` | System → Users |
| clock/NTP | `/system clock`; `/system ntp client` | System → Clock / NTP Client |
| history/undo | `/system history`; `/undo`; `/redo` | System → History; toolbar |
| export | `/export show-sensitive=no` | New Terminal |
| binary backup | `/system backup save` | Files → Backup |
| reset | `/system reset-configuration` | System → Reset Configuration |
| support output | `/system sup-output` | Make Supout.rif |

## Interfaces and Layer 2

| Task | CLI | WinBox |
|---|---|---|
| interface state | `/interface print detail` | Interfaces |
| Ethernet link/stats | `/interface ethernet monitor`; `print stats` | Interfaces → Ethernet/Status/Stats |
| bridges | `/interface bridge` | Bridge → Bridge |
| bridge ports | `/interface bridge port` | Bridge → Ports |
| learned MACs | `/interface bridge host` | Bridge → Hosts |
| bridge VLANs | `/interface bridge vlan` | Bridge → VLANs |
| VLAN interfaces | `/interface vlan` | Interfaces → VLAN |
| Wi-Fi current | `/interface wifi` | WiFi |
| legacy wireless | `/interface wireless` | Wireless |

## IP services

| Task | CLI | WinBox |
|---|---|---|
| IPv4 addresses | `/ip address` | IP → Addresses |
| ARP | `/ip arp` | IP → ARP |
| DHCP client | `/ip dhcp-client` | IP → DHCP Client |
| DHCP server | `/ip dhcp-server` | IP → DHCP Server |
| pools | `/ip pool` | IP → Pool |
| DNS | `/ip dns` | IP → DNS |
| IPv6 addresses/ND | `/ipv6 address`; `/ipv6 nd` | IPv6 → Addresses / ND |
| IP services | `/ip service` | IP → Services |

## Routing

| Task | CLI | WinBox |
|---|---|---|
| static/IPv4 route | `/ip route` | IP → Routes |
| protocol-rich route view | `/routing route` | Routing → Routes |
| tables/rules | `/routing table`; `/routing rule` | Routing → Tables / Rules |
| routing filters | `/routing filter rule` | Routing → Filters |
| nexthops | `/routing nexthop` | Routing → Nexthops |
| OSPF | `/routing ospf` | Routing → OSPF |
| BGP | `/routing bgp` | Routing → BGP |
| BFD | `/routing bfd` | Routing → BFD |

## Firewall, NAT and queues

| Task | CLI | WinBox |
|---|---|---|
| connections | `/ip firewall connection` | IP → Firewall → Connections |
| filter/NAT/mangle/raw | `/ip firewall {filter,nat,mangle,raw}` | IP → Firewall tabs |
| address lists | `/ip firewall address-list` | IP → Firewall → Address Lists |
| simple queues | `/queue simple` | Queues → Simple Queues |
| queue tree/types | `/queue tree`; `/queue type` | Queues → Queue Tree / Queue Types |

## PPP, VPN and MPLS

| Task | CLI | WinBox |
|---|---|---|
| PPP profiles/secrets/active | `/ppp` | PPP tabs |
| tunnel interfaces | `/interface ipip`; `/interface eoip`; etc. | Interfaces → add type |
| WireGuard | `/interface wireguard` | WireGuard/Interfaces |
| IPsec | `/ip ipsec` | IP → IPsec |
| LDP | `/mpls ldp` | MPLS → LDP |
| label forwarding | `/mpls forwarding-table` | MPLS → Forwarding Table |
| VPLS | `/interface vpls` | Interfaces/VPLS |
| VRF | `/ip vrf` | IP → VRF |
| TE | `/interface traffic-eng`; `/mpls traffic-eng` | Interfaces/MPLS |

## Diagnostics

```routeros
/ping ADDRESS count=5 src-address=SOURCE
/tool traceroute ADDRESS src-address=SOURCE
/tool torch interface=INTERFACE
/tool sniffer quick interface=INTERFACE
/interface monitor-traffic INTERFACE once
/tool profile cpu=all duration=10
/log print follow
/system resource print
```

## CLI selection patterns

```routeros
print
print detail
print where disabled=yes
print where comment~"WAN"
get [find where name="OBJECT"] property
set [find where name="OBJECT"] disabled=yes
remove [find where comment="LAB-ONLY"]
```

Before a destructive `set/remove`, run the `find` selector in `print where ...` and confirm it matches exactly what you intend.

## Common flags

| Flag | Frequent meaning |
|---|---|
| X | disabled |
| I | invalid/inactive depending on view |
| D | dynamic |
| A | active |
| R | running |
| H | hardware-offloaded/eligible in relevant views |
| S or s | static |
| C or c | connected |
| o | OSPF |
| b | BGP |
| + | ECMP |
| B | blackhole in route views |

Always read the legend in the current command/window.

## Port/protocol reminders

| Function | Protocol/port |
|---|---|
| SSH | TCP 22 |
| DNS | UDP/TCP 53 |
| DHCPv4 | UDP 67/68 |
| HTTP/HTTPS | TCP 80/443 |
| NTP | UDP 123 |
| SNMP | UDP 161/162 commonly |
| BGP | TCP 179 |
| OSPF | IP protocol 89, not TCP/UDP |
| WinBox | TCP 8291 by default |
| WireGuard | configured UDP port |
| IPIP | IP protocol 4 |
| GRE/EoIP/PPTP data | GRE IP protocol 47 in relevant designs |

Port tables are starting points. Firewall policy must also specify source, destination, interface, state, IP family, and role.
