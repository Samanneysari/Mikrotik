# Hands-On Lab Workbook

Use isolated CHR/RouterBOARD equipment. Every lab requires prediction, evidence, one injected fault, recovery, and a sanitized export. The [Chapter 2 topology](../docs/02-lab-environment.md) is the base unless noted.

## Lab index

| # | Level | Lab | Completion proof |
|---:|---|---|---|
| 01 | Zero | CHR, console, WinBox IP/MAC | inventory + Safe Mode rollback |
| 02 | MTCNA | Blank router to Internet | client DHCP/DNS/HTTPS + counters |
| 03 | MTCNA | Upgrade, export, backup, reset, recovery | restored clean configuration |
| 04 | MTCNA | DHCP/ARP/DNS | DORA capture + static lease + DNS tests |
| 05 | MTCNA | Bridge/RSTP/VLAN basics | MAC table + blocked redundant port |
| 06 | MTCNA | AP/station concept | registration evidence + VLAN path |
| 07 | MTCNA | Three-router static routing | end-to-end/return path/traceroute |
| 08 | MTCNA | Stateful firewall and NAT | positive/negative test matrix |
| 09 | MTCNA | Simple Queue and PCQ | measured caps/fairness |
| 10 | MTCNA | PPPoE and IPIP | active session/tunnel/MTU evidence |
| 11 | MTCNA | Tools and monitoring | focused PCAP/log/profile bundle |
| 12 | MTCNA | Netinstall/recovery drill | device rebuilt from documented process |
| 13 | MTCRE | ECMP, recursion, policy routing | failover/policy/route evidence |
| 14 | MTCRE | EoIP, VLAN and QinQ | tag/tunnel capture and loop guard |
| 15 | MTCRE | Multi-area OSPF | LSDB/routes + five repaired faults |
| 16 | MTCINE | eBGP policy | exact advertisements and filters |
| 17 | MTCINE | iBGP/RR/best path | RR + attribute decision proof |
| 18 | MTCINE | MPLS/LDP | label push/swap/PHP walk |
| 19 | MTCINE | VPLS | pseudowire labels + MAC learning |
| 20 | MTCINE | VRF/L3VPN | overlapping prefixes isolated |
| 21 | MTCINE | RSVP-TE | active path/reservation/failure/reoptimize |

## Common evidence commands

```routeros
/export show-sensitive=no terse
/system history print detail
/interface print detail
/interface bridge port print detail
/interface bridge vlan print detail
/routing route print detail
/ip firewall filter print stats
/ip firewall nat print stats
/routing ospf neighbor print detail
/routing bgp session print detail
/mpls ldp neighbor print detail
/mpls forwarding-table print detail
/interface vpls monitor [find] once
/log print
```

## Fault cards

Randomly select one fault after the lab works:

1. wrong `/27` mask on one endpoint;
2. access PVID changed;
3. trunk VLAN removed;
4. DHCP pool exhausted;
5. DNS input rule moved below drop;
6. return route removed;
7. NAT egress changed from PPPoE to physical port;
8. FastTrack left on during queue/policy test;
9. tunnel MTU too high;
10. OSPF area mismatch;
11. duplicate OSPF/BGP router ID;
12. OSPF Hello timer mismatch;
13. BGP output filter rejects all;
14. BGP NEXT_HOP removed from IGP;
15. LDP disabled on one core link;
16. VPLS ID mismatch;
17. bridge horizon incorrectly groups customer port;
18. wrong L3VPN import RT;

## Lab report template

```markdown
# Lab NN — Name

## Requirement and topology
## Address/VLAN/ASN plan
## Prediction
## Configuration and line-by-line rationale
## Verification output
## Injected fault and symptoms
## Hypotheses in order
## First decisive evidence
## Root cause and minimal fix
## Negative tests
## Rollback/restoration
## What I would change for production
```

## Capstone

Build six routers: two customer CEs, two PEs, two P routers. Add one dual-homed Internet/customer edge. Requirements:

- management VLAN and WireGuard admin access;
- OSPF provider core with loopbacks;
- LDP transport;
- Customer A L3VPN with overlapping prefix from Customer B;
- Customer B two-site VPLS;
- eBGP customer/provider filtering;
- recursive dual-WAN management reachability;
- remote logs/SNMP design;
- backups and a written rollback.

Pass only when another person can inject any three fault cards and you locate each root cause from evidence without resetting the topology.
