# 19 — Incident-Driven Troubleshooting

Troubleshooting is controlled uncertainty reduction. Do not ask “what command fixes it?” Ask “what observation separates my two most likely hypotheses?”

## 1. The incident loop

1. Stabilize safety: stop risky changes, preserve out-of-band access, enter Safe Mode if modifying.
2. Define scope and success: exact source, destination, protocol, time, expected behavior.
3. Build a minimal path: source → access/VLAN → gateway → route/policy → egress → return.
4. Collect current state and recent history.
5. Form ranked hypotheses.
6. Test the cheapest discriminating observation.
7. Change one variable with rollback.
8. Verify technically and with the user.
9. Record root cause, contributing factors, and prevention.

## 2. Minimum evidence bundle

```routeros
/system resource print
/system history print detail
/interface print detail
/interface ethernet print stats
/interface bridge port print detail
/interface bridge vlan print detail
/ip address print detail
/ip arp print detail
/routing rule print detail
/routing route print detail
/ip firewall raw print stats
/ip firewall mangle print stats
/ip firewall filter print stats
/ip firewall nat print stats
/log print
```

Add protocol-specific state only for relevant services. Avoid dumping huge Internet tables/logs into a terminal during peak load.

## Case 1 — Gateway pings; remote LAN does not

Representative R1 route output:

```text
DAc 10.0.12.0/30  ether2
As  192.168.30.0/24 10.0.12.2
```

R1 can ping `10.0.12.2`; R1's sourced ping to `192.168.30.1` works; client `192.168.10.10` fails.

Reasoning:

- forward route exists;
- router-originated source differs from client source;
- inspect R2 route back to `192.168.10.0/24` and both routers' forward chains;
- a missing return route often makes router transit-source tests work while client prefix fails.

Do not add NAT between internal routed networks as a substitute for fixing return routing unless translation is an explicit requirement.

## Case 2 — DHCP client self-assigns `169.254.x.x`

Evidence:

- link running;
- no lease on RouterOS;
- Packet Sniffer sees Discover on access port but not on bridge/VLAN interface.

Likely root cause: Layer 2 VLAN admission/membership before DHCP. Compare access PVID, bridge VLAN untagged membership, trunk tagged membership, and DHCP server interface. NAT/DNS are later and irrelevant to Discover delivery.

## Case 3 — VLAN 20 works; VLAN 10 does not

```text
/interface bridge vlan print
10  tagged=br-core         untagged=ether2
20  tagged=br-core,ether1  untagged=ether3
```

If the affected client is across `ether1`, VLAN 10 is missing from the trunk tagged list. The bridge CPU can still route locally attached `ether2` VLAN 10, which explains partial success.

## Case 4 — NAT rule counter remains zero

Rule:

```routeros
chain=srcnat out-interface=ether1 action=masquerade
```

Actual route egress is `pppoe-wan`, not `ether1`. The PPPoE logical interface is the routed egress, so the rule does not match. Use the correct logical interface or a deliberately maintained WAN interface list. Restart a test flow because existing connection tracking can retain earlier NAT decisions.

## Case 5 — Port-forward matches, application still fails

Checklist:

- dst-NAT counter increments;
- forward accept counter increments;
- sniffer sees translated SYN exit LAN;
- no SYN-ACK returns.

RouterOS is forwarding. Investigate server default gateway, host firewall, listening socket, VLAN, or asymmetric return. Adding a second dst-NAT rule cannot make a stopped web service listen.

## Case 6 — OSPF neighbors stay 2-Way

On a broadcast Ethernet segment, DROther routers normally remain 2-Way with each other while becoming Full with DR/BDR. This may be correct, not a failure. Check network type, roles and whether expected LSAs/routes exist. On a two-router point-to-point link, configure matching `type=ptp` if that is the design.

## Case 7 — OSPF stuck ExStart/Exchange

Ranked checks:

1. interface MTU mismatch;
2. duplicate router ID;
3. network-type mismatch;
4. unstable link/packet loss;
5. authentication/options mismatch.

Capture protocol 89 and compare interface template/status. “Ignore MTU” style workarounds can hide a data-plane MTU defect; correct the path where possible.

## Case 8 — BGP Established but prefix count is zero

Session transport/control plane is up. Check:

1. exact active route exists for the `output.network` prefix;
2. correct address list is referenced;
3. output filter explicitly accepts it;
4. remote input filter/prefix limit accepts it;
5. both connections belong to intended instance/address family;
6. remote route view is filtered rather than merely hidden by a WinBox display filter.

## Case 9 — BGP route received but inactive

Representative detail:

```text
dst-address=203.0.113.0/24 bgp.as-path="65020 65030"
gateway=10.255.20.1 immediate-gw="" active=no
```

NEXT_HOP is not resolvable. Fix the IGP/static route or correct next-hop policy; do not lower BGP distance. A lower distance cannot make an unreachable gateway valid.

## Case 10 — Recursive default does not activate

Check the resolution chain:

- probe `/32` is active through physical ISP gateway;
- default's logical gateway equals that probe address;
- default target-scope accepts the probe route's scope;
- gateway checking marks it reachable;
- no more-specific policy sends the probe through another ISP.

Use `/routing nexthop print detail` to inspect the actual resolver object.

## Case 11 — LDP neighbors up, VPLS down

LDP adjacency proves only adjacent label exchange. VPLS also needs:

- remote PE loopback reachable through IGP;
- transport label to remote PE;
- identical VPLS ID and reciprocal peer;
- compatible control-word/pseudowire properties;
- sufficient L2MTU;
- enabled/running interface and bridge attachment.

Use VPLS monitor to inspect local/remote labels and transport nexthop.

## Case 12 — Small packets work; large transfers stall

Suspect MTU/PMTUD after tunnels, PPPoE, VLAN/QinQ, MPLS/VPLS, or IPsec:

1. calculate encapsulation overhead;
2. DF ping increasing sizes;
3. verify ICMP “fragmentation needed”/ICMPv6 Packet Too Big is not blocked;
4. inspect physical L2MTU and all failover paths;
5. use MSS clamp only as a TCP-specific mitigation, not a universal repair.

## Case 13 — Policy routing breaks access to router

A prerouting mangle rule marks every packet from LAN, including destinations owned by the router, into an ISP-only table. Fix the match with `dst-address-type=!local` or deliberately order local lookup before mangle according to the current RouterOS policy pipeline. Verify input services and forwarded Internet separately.

## Case 14 — Queue counter zero

Possible causes:

- FastTrack bypass;
- wrong target/direction/parent;
- traffic not traversing the router;
- bottleneck is upstream;
- packet/routing mark never set;
- queue uses a path incompatible with MPLS/bridge hardware offload.

Disable FastTrack briefly in a lab, generate a new flow, use Torch, and inspect queue stats.

## Case 15 — Router becomes slow during incident

Do not reboot before evidence unless availability/safety requires it. Check CPU profile, connection count, firewall logging rate, interface pps, storage, DNS/management exposure, and loops. A broadcast loop can look like a firewall attack; a logging rule can turn a scan into CPU exhaustion.

## Troubleshooting competency test

For an unseen broken topology, you pass only if you can:

- state a falsifiable hypothesis before changing configuration;
- identify the first failing boundary with evidence;
- make a minimal reversible fix;
- test positive and negative requirements;
- explain why plausible alternatives were not the root cause;
- record prevention, not merely the command used.
