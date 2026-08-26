# MikroTik: Zero to Inter-Networking Engineer

A lab-first RouterOS v7 book for readers who are starting from **zero networking knowledge** and want to progress through:

1. networking foundations;
2. **MTCNA** (MikroTik Certified Network Associate);
3. **MTCNA+** (this project's non-official production-skills bridge);
4. **MTCRE** (MikroTik Certified Routing Engineer);
5. **MTCINE** (MikroTik Certified Inter-Networking Engineer).

> [!IMPORTANT]
> `MTNCA`, `MTNCA+`, and `MTNCE` are not current official MikroTik certification names. The official path covered here is **MTCNA → MTCRE → MTCINE**. In this repository, **MTCNA+** is deliberately used as an *unofficial* bridge between associate-level exam knowledge and real junior network-engineer work.

## What makes this book different?

- Starts below MTCNA prerequisites: binary, Ethernet, OSI/TCP-IP, IPv4, subnetting, ARP, TCP, UDP, DNS, and DHCP.
- Uses **RouterOS v7 syntax and behavior**. The baseline checked while creating this edition was RouterOS **7.22.3 stable** (2026-05-08).
- Maps every bullet in the official MTCNA, MTCRE, and MTCINE outlines to a chapter or lab.
- Explains each major configuration in four passes: **concept → topology → command/WinBox path → verification and failure modes**.
- Treats WinBox and CLI as two views of the same RouterOS object model.
- Includes original practice exams, incident-style troubleshooting, and reusable `.rsc` lab configurations.
- Clearly labels legacy exam topics such as PPTP instead of teaching unsafe technology as a modern recommendation.

This is independent educational material. It is not an official MikroTik course, exam dump, or substitute for the trainer-led session required to earn a MikroTik certificate.

## Start here

Read [Start Here](docs/00-start-here.md), build the [Lab Environment](docs/02-lab-environment.md), and do not skip the checkpoint at the end of each chapter.

| Stage | Read | You are ready when... |
|---|---|---|
| Zero | Chapters 00–02 | You can subnet `/24` through `/30`, explain ARP, and boot three CHRs |
| MTCNA | Chapters 03–10 | You can safely configure and troubleshoot a small routed office |
| MTCNA+ | Chapters 11–13 | You can segment, harden, monitor, back up, and recover a production-style router |
| MTCRE | Chapters 14–16 | You can design static/policy routes, tunnels, VLAN/QinQ, and multi-area OSPF |
| MTCINE | Chapters 17–18 | You can reason about BGP, MPLS/LDP, VPLS, VRF/L3VPN, and RSVP-TE |
| Job/exam prep | Chapters 19–21, labs, exams | You can diagnose unseen failures and justify each answer |

## Book map

### Part I — Absolute foundations

- [00 — Start here and how to learn](docs/00-start-here.md)
- [01 — Networking from zero](docs/01-networking-foundations.md)
- [02 — Build a safe RouterOS lab](docs/02-lab-environment.md)

### Part II — MTCNA

- [03 — RouterOS, RouterBOARD, first access, upgrades, backup and recovery](docs/03-routeros-first-access.md)
- [04 — WinBox complete guided tour](docs/04-winbox-complete-tour.md)
- [05 — Ethernet, bridges, switching, VLAN foundations and wireless](docs/05-layer2-wireless.md)
- [06 — IPv4/IPv6, ARP, DHCP and DNS](docs/06-ip-services.md)
- [07 — Routing fundamentals and static routes](docs/07-routing-fundamentals.md)
- [08 — Packet flow, firewall and NAT](docs/08-firewall-nat.md)
- [09 — QoS, PPP, PPPoE and tunnels](docs/09-qos-ppp-tunnels.md)
- [10 — Tools, monitoring and troubleshooting](docs/10-operations-monitoring.md)

### Part III — MTCNA+ production bridge

- [11 — VLAN filtering and production switching](docs/11-vlan-switching.md)
- [12 — Security hardening, VPN choices and management plane](docs/12-security-hardening.md)
- [13 — Automation, scripting, API and configuration discipline](docs/13-automation.md)

### Part IV — MTCRE

- [14 — Advanced static routing, ECMP, recursion and policy routing](docs/14-mtcre-routing.md)
- [15 — Tunnels, VLAN, QinQ and routed design](docs/15-mtcre-tunnels.md)
- [16 — OSPF from first adjacency to multi-area troubleshooting](docs/16-ospf.md)

### Part V — MTCINE

- [17 — BGP from first principles to policy, reflectors and confederations](docs/17-bgp.md)
- [18 — MPLS, LDP, VPLS, VRF/L3VPN and traffic engineering](docs/18-mpls.md)

### Part VI — Proving competence

- [19 — Incident-driven troubleshooting](docs/19-troubleshooting.md)
- [20 — Command and WinBox path reference](docs/20-command-reference.md)
- [21 — Four-week review plan and competency checklists](docs/21-study-plan.md)
- [Official outline coverage matrix](docs/coverage-matrix.md)
- [Sources and version policy](docs/sources.md)
- [Hands-on labs](labs/README.md)
- [Original practice exams](exams/README.md)

## The method used in every worked example

Suppose clients on `192.168.10.0/24` must reach the Internet through `ether1`.

```routeros
/ip firewall nat
add chain=srcnat out-interface-list=WAN action=masquerade \
    comment="LAB: translate changing WAN address"
```

What it means:

- `chain=srcnat`: inspect packets after RouterOS has chosen their outgoing route.
- `out-interface-list=WAN`: match traffic leaving through an interface classified as WAN. The list must already exist and contain `ether1`.
- `action=masquerade`: replace the private source with the current address of the egress interface and clear related tracking entries when that address changes.
- `comment=...`: makes intent visible to the next operator.

How to prove it works:

```routeros
/ip firewall nat print stats
/ip firewall connection print where src-address~"192.168.10."
/tool torch interface=ether1
```

If the counter remains zero, the rule is not being matched: verify the route, interface-list membership, rule order, connection tracking, and whether an existing connection must be cleared. This explanation pattern is used throughout the book.

## Accuracy promise and limits

The official training outlines linked by MikroTik are old enough to mention RouterOS v6-era concepts and legacy protocols. This book preserves those concepts for exam coverage while teaching their RouterOS v7 equivalents and current operational guidance. RouterOS menus also vary by device, installed packages, architecture, license, and hardware offload capabilities; therefore no static screenshot can represent every possible WinBox menu.

Before applying any example to a real router:

1. export and back up the device;
2. read the whole scenario, including rollback;
3. use Safe Mode for reachability-changing work;
4. adapt interface names, addresses, MTU, and security policy;
5. verify against the current [official RouterOS manual](https://manual.mikrotik.com/).

## Quick validation

Run the repository checks before proposing changes:

```bash
./scripts/check-docs.sh
```

## Contributions

Examples use documentation-only private addresses and private ASNs. Never paste production secrets, public customer prefixes, certificates, or unredacted exports into an issue. Contributions should preserve the concept/example/explanation/verification format and cite primary MikroTik documentation for version-sensitive behavior.
