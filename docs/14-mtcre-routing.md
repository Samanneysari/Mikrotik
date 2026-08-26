# 14 — MTCRE Advanced Static Routing and Policy

MTCRE turns “add a route” into design: multiple candidates, failure detection, recursive next hops, policy tables, symmetry, and predictable rollback.

## 1. More-specific routes and exceptions

```routeros
/ip route
add dst-address=10.0.0.0/8 gateway=10.0.12.2 comment="corporate summary"
add dst-address=10.20.30.0/24 gateway=10.0.13.2 comment="DC exception"
```

Traffic for `10.20.30.44` uses the `/24`. Distance would matter only between eligible candidates for the same `/24`. This principle is the foundation of aggregation, traffic engineering exceptions, and route leaks.

## 2. ECMP

Equal-Cost Multi-Path exists when multiple equally preferred active next hops serve the same prefix:

```routeros
/ip route
add dst-address=192.168.50.0/24 gateway=10.0.12.2 distance=1 comment="path A"
add dst-address=192.168.50.0/24 gateway=10.0.13.2 distance=1 comment="path B"
```

Verify the `+` ECMP indication and nexthops:

```routeros
/routing route print detail where dst-address=192.168.50.0/24
/routing nexthop print detail
```

RouterOS generally keeps packets from one flow on a consistent path using a hash rather than alternating every packet. ECMP does not guarantee equal byte usage: a few large flows can be uneven. Stateful firewall/NAT/provider paths require symmetry or deliberate connection marking.

## 3. Distance and floating routes

```routeros
/ip route
add dst-address=192.168.50.0/24 gateway=10.0.12.2 distance=1 comment="primary"
add dst-address=192.168.50.0/24 gateway=10.0.13.2 distance=10 comment="floating backup"
```

The backup is present but not selected while the primary route is eligible. A reachable directly connected gateway may remain “up” while everything beyond it is broken, so basic next-hop checks can provide false health.

## 4. Gateway through a specific interface

When identical gateway IPs can be resolved on multiple interfaces, qualify the gateway:

```routeros
/ip route add dst-address=203.0.113.0/24 gateway=192.0.2.1%ether2
```

Do not use a bare broadcast Ethernet interface as a multi-hop gateway. It can make RouterOS ARP for remote destinations. Interface-only gateways are appropriate for true point-to-point semantics; on Ethernet, use an IP next hop and scope it where needed.

## 5. Recursive next-hop failover

Requirement: use ISP1 unless a remote probe through it fails, then ISP2.

```routeros
/ip route
add dst-address=1.1.1.1/32 gateway=198.51.100.1 scope=10 \
    comment="probe resolved only through ISP1"
add dst-address=9.9.9.9/32 gateway=203.0.113.1 scope=10 \
    comment="probe resolved only through ISP2"
add dst-address=0.0.0.0/0 gateway=1.1.1.1 target-scope=11 \
    check-gateway=ping distance=1 comment="recursive primary"
add dst-address=0.0.0.0/0 gateway=9.9.9.9 target-scope=11 \
    check-gateway=ping distance=2 comment="recursive backup"
```

How it works:

1. The `/32` host route pins each probe to one physical ISP gateway.
2. Each default route names a probe address as its logical gateway.
3. `target-scope=11` permits it to resolve through the scope-10 host route.
4. `check-gateway=ping` monitors the recursively resolved gateway object.
5. Distance selects ISP1 while it is active, then ISP2.

Use probes you are authorized to monitor and that reliably answer. A single remote host can fail independently; production designs may use multiple probes and more carefully defined success logic. Adjust global gateway-check interval/count only after understanding fleet impact:

```routeros
/routing settings print
/routing nexthop print detail
```

## 6. Scope and target-scope intuition

- `scope` describes how other routes may use this route for recursive resolution.
- `target-scope` limits which scope values are acceptable to resolve this route's gateway.

Connected routes commonly have scope 10; IGP routes 20; static routes 30 by default. Changing scope casually can create a route that appears configured but is inactive. Inspect `immediate-gw`, `scope`, `target-scope`, and `/routing nexthop` rather than copying numbers without a resolution graph.

## 7. Policy routing with routing rules

Requirement: server VLAN 20 should use ISP2, while other traffic uses main/ISP1.

```routeros
/routing table add name=to-isp2 fib
/ip route add dst-address=0.0.0.0/0 gateway=203.0.113.1@main \
    routing-table=to-isp2 comment="ISP2 policy default"
/routing rule add src-address=192.168.20.0/24 action=lookup-only-in-table \
    table=to-isp2 comment="servers must use ISP2"
```

- custom table must be created before use;
- `fib` makes it a forwarding table;
- `@main` tells the custom route to resolve its gateway using main;
- `lookup-only-in-table` does not fall back to main if ISP2 has no route;
- use `action=lookup` if deliberate fallback is required.

Main must be able to resolve the relevant destination/gateway. Test router-local and forwarded traffic separately.

## 8. Mangle-based policy

Mangle can mark a connection and then its packets for more complex multi-WAN symmetry. It also executes with high policy priority by default. Never mark traffic addressed to the router into an Internet-only table:

```routeros
/ip firewall mangle add chain=prerouting in-interface=vlan20-servers \
    dst-address-type=!local action=mark-routing new-routing-mark=to-isp2 \
    passthrough=no comment="server policy route"
```

Do not combine routing rules and mangle marks casually; if marked traffic resolves in its table, user routing rules may never see it. NAT return symmetry, FastTrack exclusions, connection marks, and failure fallback must be designed together.

## 9. Point-to-point addressing

Traditional IPv4 point-to-point links use `/30`; RFC 3021 `/31` conserves addresses when both ends support it. A tunnel/PPP interface can also use explicit local/remote endpoint semantics without a broadcast LAN.

```routeros
/ip address add address=10.0.12.0/31 interface=ether2 comment="R1 side of P2P"
```

R2 uses `10.0.12.1/31`. Verify neighbor/route behavior on the exact devices and avoid `/31` on a segment with multiple nodes.

## 10. Advanced route incident

Symptom: ISP1 interface is up and its gateway pings, but clients cannot reach remote Internet; ISP2 never activates.

Root cause: basic floating static only tested connected gateway eligibility. Corrective design: recursive defaults test a remote probe pinned through each ISP. Verification must include:

```routeros
/routing route print detail where dst-address=0.0.0.0/0
/routing nexthop print detail
/ping 1.1.1.1 interface=ether1
/tool traceroute 1.1.1.1
```

Do not conflate provider DNS reachability with all Internet services; probe selection defines exactly what failover detects.

## MTCRE routing checkpoint

Build two ISP paths and demonstrate:

- longest-prefix exception over a summary;
- ECMP with multiple flows;
- floating route by distance;
- recursive failover beyond the local gateway;
- policy table with `lookup-only-in-table` and `lookup` difference;
- a failure caused by wrong target-scope;
- correct NAT/connection symmetry after failover.
