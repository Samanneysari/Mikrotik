# Official Certification Coverage Matrix

This matrix maps the public outlines linked from MikroTik's training page to this RouterOS v7 book. It is a coverage audit, not a claim that reading alone grants certification.

Legend: **C** = concept, **W** = worked example, **L** = hands-on lab, **T** = troubleshooting/exam practice.

## MTCNA

| Official module | Official objective groups | Coverage | Evidence |
|---|---|---:|---|
| 1 Introduction | MikroTik, RouterOS, RouterBOARD, first access, WinBox/MAC-WinBox, WebFig/Quick Set, defaults, CLI, SSH/Telnet/terminal, navigation/history | C/W/L/T | Chapters 03–04; Labs 01–02 |
| 1 Introduction | First Internet configuration, DHCP client, LAN/gateway, masquerade | C/W/L/T | Chapters 03, 06, 08; Lab 02 |
| 1 Introduction | Packages, RouterOS and RouterBOOT upgrades, identity, users, services | C/W/L/T | Chapters 03, 12; Lab 03 |
| 1 Introduction | Backup/export, reset, Netinstall, licenses, support sources | C/W/L/T | Chapters 03, 10; Labs 03 and 12 |
| 2 DHCP | Client/server, setup, leases, networks, ARP and ARP modes | C/W/L/T | Chapters 01, 06; Lab 04 |
| 3 Bridging | Bridge concepts/settings, ports, wireless bridge/station bridge | C/W/L/T | Chapters 05, 11; Labs 05–06 |
| 4 Routing | Concepts, flags, static/default/dynamic routes | C/W/L/T | Chapters 07 and 14; Lab 07 |
| 5 Wireless | 802.11 bands/channels/rates/chains/power/regulation, AP/station, security, access/connect list, registration/monitoring | C/W/L/T | Chapter 05; Lab 06 |
| 6 Firewall | Principles, tracking/states, chains/actions, input/forward, address lists, src/dst NAT, redirect, FastTrack | C/W/L/T | Chapter 08; Lab 08 |
| 7 QoS | Simple Queue, target/destination, max-limit, limit-at, burst, PCQ | C/W/L/T | Chapter 09; Lab 09 |
| 8 Tunnels | PPP profiles/secrets/status, pools, PPPoE client/server, point-to-point addressing, PPTP/SSTP | C/W/L/T | Chapter 09; Lab 10 |
| 9 Misc | E-mail, Netwatch, ping, traceroute, profiler, traffic monitor, Torch, graphs, SNMP, Dude, supout, logs, comments/diagrams | C/W/L/T | Chapter 10; Labs 11–12 |

## MTCRE

| Official module | Official objective groups | Coverage | Evidence |
|---|---|---:|---|
| 1 Static Routing | Specific routes, ECMP, interface gateway, reachability/distance, route policy, recursive next hop, scope/target-scope | C/W/L/T | Chapter 14; Lab 13 |
| 2 Point-to-Point | Point-to-point address design and configuration | C/W/L/T | Chapters 14–15; Lab 13 |
| 3 VPN | VPN types; IPIP, EoIP, PPTP, SSTP, L2TP, PPPoE | C/W/L/T | Chapters 09, 12, 15; Lab 14 |
| 3 VLAN | VLAN purpose, QinQ, managed switching and hardware considerations | C/W/L/T | Chapters 11 and 15; Labs 05 and 14 |
| 4 OSPF | Operation, Hello, LSDB/LSAs, areas/router types, states, DR/BDR, external types, costs/types, SPF/multicast, stub/NSSA/ranges, virtual links, filters | C/W/L/T | Chapter 16; Lab 15 |

## MTCINE

| Official module | Official objective groups | Coverage | Evidence |
|---|---|---:|---|
| 1 BGP | AS, path vector, transport/messages, iBGP/eBGP, stub/non-stub, multihop/loopbacks, distribution/filters, best path, attributes, reflectors/confederations | C/W/L/T | Chapter 17; Labs 16–17 |
| 2 MPLS | Basics, static labels, LDP, PHP, traceroute, LDP/BGP VPLS, split horizon, control word, L2MTU, VRF/leaking, BGP L3VPN, OSPF CE-PE | C/W/L/T | Chapter 18; Labs 18–20 |
| 3 Traffic Engineering | RSVP-TE, static/dynamic path, CSPF, bandwidth reservation versus policing/shaping | C/W/L/T | Chapter 18; Lab 21 |

## RouterOS v7 production additions

The following are deliberately added because they materially affect current work even though the old outlines do not name them:

- bridge VLAN filtering and hardware-offload awareness;
- interface lists and rule intent;
- RouterOS v7 routing tables, rules, filters, templates, and process monitoring;
- WireGuard and contemporary IPsec/IKEv2;
- IPv6 foundations and firewall parity;
- certificate and management-plane hygiene;
- configuration history, Safe Mode, Git-friendly exports, scripting, REST/API;
- RPKI awareness, BFD awareness, and BGP operational safety;
- incident workflow and rollback design.

## WinBox GUI coverage

The [WinBox Menu-by-Menu Field Manual](winbox/README.md) adds a separate GUI
coverage contract beyond the certification objectives. Its manifest covers all
20 baseline sidebar families and a conditional package/hardware catalog. Each
family maps the visible submenu/window to purpose, controls, add/edit workflow,
verification, failure modes and CLI family. CI verifies that every manifest
entry resolves and that critical deep submenus—including **Tools → IP Scan**—do
not disappear during later edits.

## Known outline age and interpretation

The official PDFs currently linked by MikroTik show last-edited dates of 2016 (MTCNA), 2015 (MTCRE), and 2012 (MTCINE). They include RouterOS v6-era menus and protocols. Where the outline and current RouterOS differ, this repository:

1. teaches the underlying objective;
2. demonstrates RouterOS v7 syntax;
3. labels v6 or legacy syntax instead of silently mixing it with v7;
4. links the current manual for version-sensitive properties.
