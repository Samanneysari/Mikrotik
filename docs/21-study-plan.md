# 21 — Four-Week Intensive Review and Competency Checklists

This four-week plan is for someone who already understands basic networking and wants an intensive review. A true beginner should use the same order but advance only after passing each checkpoint; “zero to MTCINE” is not honestly guaranteed by a calendar.

Daily pattern (2–4 focused hours):

- 45 minutes concept review;
- 90 minutes build and verification;
- 30 minutes deliberately broken scenario;
- 20 minutes closed-notes recall/quiz;
- 10 minutes incident journal.

## Week 1 — Foundations and MTCNA core

| Day | Focus | Deliverable |
|---:|---|---|
| 1 | binary, subnetting, Ethernet, ARP, TCP/UDP | subnet 20 prefixes; explain website packet hop |
| 2 | CHR, first access, CLI/WinBox, Safe Mode | three-router lab and rollback proof |
| 3 | bridge, RSTP, Wi-Fi concepts | L2 topology with one blocked redundant link |
| 4 | IP, DHCP, DNS, IPv6 | two serviced VLANs; inject 3 failures |
| 5 | routes/default/return path | R1–R2–R3 static network |
| 6 | packet flow, filter, NAT | three-zone least-privilege policy |
| 7 | timed MTCNA practice + rebuild | exam review and blank-router rebuild |

## Week 2 — MTCNA+ production skills

| Day | Focus | Deliverable |
|---:|---|---|
| 8 | Simple Queue, PCQ, FastTrack | rate/fairness evidence |
| 9 | PPPoE and tunnel taxonomy | working PPPoE + MTU diagnosis |
| 10 | VLAN filtering | trunk/access/CPU design with recovery |
| 11 | management hardening | exposure matrix from every zone |
| 12 | WireGuard and IPsec model | least-privilege admin VPN |
| 13 | monitoring/tools | incident evidence pack |
| 14 | scripts/API/change control | idempotent lab change + rollback |

## Week 3 — MTCRE

| Day | Focus | Deliverable |
|---:|---|---|
| 15 | longest match, ECMP, distance | route-choice predictions/proofs |
| 16 | recursion and policy tables | dual-WAN failover + policy |
| 17 | IPIP/EoIP/L2TP/SSTP/PPTP awareness | comparison and two safe builds |
| 18 | VLAN/QinQ/switch hardware | double-tag capture and MTU plan |
| 19 | OSPF adjacency/LSDB/SPF | single-area convergence lab |
| 20 | areas/stub/NSSA/summary/filter | four-router multi-area lab |
| 21 | MTCRE timed practice/incident | repair five injected failures |

## Week 4 — MTCINE

| Day | Focus | Deliverable |
|---:|---|---|
| 22 | BGP sessions/origination/filter | strict eBGP lab |
| 23 | attributes/best path | LOCAL_PREF/MED/prepend evidence |
| 24 | iBGP/RR/confederation concept | RR replaces full mesh |
| 25 | MPLS/LDP/PHP/MTU | PE–P–P–PE label walk |
| 26 | VPLS/control word/split horizon | L2 pseudowire and fault |
| 27 | VRF/RD/RT/L3VPN/CE-PE | two isolated customers |
| 28 | RSVP-TE + full practice/incident | path reservation and final report |

## MTCNA competency gate

You must be able to:

- safely access/reset/upgrade/back up/recover a router;
- navigate WinBox and reproduce changes in CLI;
- subnet and explain ARP/DHCP/DNS;
- configure bridge, IP, DHCP, static/default route;
- explain input versus forward and build stateful filter/NAT;
- configure Simple Queue/PCQ and basic PPPoE/tunnel;
- use ping, traceroute, Torch, sniffer, logs, profile, SNMP concepts;
- find an unseen small-network fault within 30 minutes.

## Junior production gate (MTCNA+)

You must additionally:

- build/recover bridge VLAN filtering;
- harden IPv4/IPv6 management exposure;
- implement a modern routed VPN;
- recognize FastTrack/MTU/hardware-offload side effects;
- make an idempotent, reviewed change with rollback;
- produce a clear incident note and sanitized evidence bundle.

## MTCRE gate

You must be able to explain and prove:

- ECMP, distance, recursion, scopes and policy tables;
- routed versus Layer 2 tunnels and their MTU/security trade-offs;
- VLAN/QinQ data plane;
- OSPF neighbor states, LSAs, areas/router types, DR/BDR, metric, external types, stub/NSSA, summaries, virtual links, and filter limitations.

## MTCINE gate

You must be able to:

- build filtered eBGP/iBGP and explain each best-path decision;
- use attributes without promising they override remote policy;
- design a route reflector and explain confederations;
- trace MPLS push/swap/pop and PHP through LFIB evidence;
- build/troubleshoot VPLS, control word, split horizon and L2MTU;
- distinguish RD from RT and prove VRF/L3VPN isolation;
- explain RSVP-TE reservation versus bandwidth enforcement.

## Final interview test

Draw and explain, without notes, a small ISP/customer topology containing:

- VLAN access/trunks and inter-VLAN firewall;
- dual WAN with recursive failover;
- OSPF core;
- customer eBGP and internal RR;
- MPLS/LDP transport;
- VPLS for one customer and L3VPN for another;
- management VPN, monitoring, backup, and recovery.

For every arrow, name the carried frame/packet/label, routing/bridge table consulted, failure evidence, and rollback. If you cannot explain an arrow, that is your next study topic.
