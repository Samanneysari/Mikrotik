# 07 — Routing Fundamentals and Static Routes

## 1. A route is a forwarding candidate

A route expresses “for destination prefix X, use next hop/interface Y, under these conditions.” RouterOS keeps routing information (RIB) and installs eligible best routes into a forwarding table (FIB).

Inspect both concise and detailed views:

```routeros
/ip route print
/ip route print detail
/routing route print detail
```

Typical flags include active, dynamic, connected, static, DHCP, OSPF, BGP, ECMP, blackhole, unreachable, and hardware-offload eligibility. Read the legend printed by your version.

## 2. Route selection mental model

For ordinary IPv4 forwarding, reason in this order:

1. Which routing table/policy applies?
2. Which routes match the destination?
3. Longest prefix wins.
4. Among candidates for that prefix, prefer the selected/eligible source and lower distance/metric according to protocol rules.
5. Resolve the gateway recursively until an immediate next hop/interface is reachable.
6. Install an active route in the FIB.

Distance does not beat prefix length. A distance-1 default route cannot override a distance-110 `/24` route for a destination inside that `/24`.

## 3. Connected and default routes

```routeros
/ip address add address=10.0.12.1/30 interface=ether2
/ip route print where dst-address=10.0.12.0/30
```

The connected route is created automatically. A default route matches any IPv4 destination not matched more specifically:

```routeros
/ip route add dst-address=0.0.0.0/0 gateway=10.0.12.2 distance=1 \
    comment="default via R2"
```

Verify next-hop reachability before blaming the route:

```routeros
/ping 10.0.12.2 src-address=10.0.12.1
/ip arp print where address=10.0.12.2
/ip route check 203.0.113.80
```

## 4. Two-router static routing example

R1 LAN is `192.168.10.0/24`; R2 LAN is `192.168.30.0/24`; transit is `10.0.12.0/30`.

R1:

```routeros
/ip address
add address=10.0.12.1/30 interface=ether2 comment="R1-R2"
add address=192.168.10.1/24 interface=br-lan
/ip route add dst-address=192.168.30.0/24 gateway=10.0.12.2 comment="branch via R2"
```

R2:

```routeros
/ip address
add address=10.0.12.2/30 interface=ether2 comment="R2-R1"
add address=192.168.30.1/24 interface=br-lan
/ip route add dst-address=192.168.10.0/24 gateway=10.0.12.1 comment="HQ via R1"
```

Both routes are required. An echo request may reach R2 while the echo reply is dropped or misrouted if R2 lacks the return route. “The forward path works” is not end-to-end connectivity.

Verification:

```routeros
/ping 192.168.30.1 src-address=192.168.10.1
/tool traceroute 192.168.30.1 src-address=192.168.10.1
/ip route print detail where dst-address=192.168.30.0/24
```

If router-to-router source tests work but clients fail, check client gateway, forwarding firewall, and routes back to client prefixes.

## 5. More-specific and summary routes

R1 has a summary route `10.20.0.0/16` via A and an exception `10.20.30.0/24` via B. Traffic to `10.20.30.44` uses B. Traffic to `10.20.40.44` uses A.

Summaries reduce route count but can attract traffic for nonexistent component networks. A matching blackhole route at the summarizing router prevents loops toward a default route:

```routeros
/ip route add dst-address=10.20.0.0/16 blackhole distance=254 \
    comment="discard uncovered space in advertised summary"
```

The high-distance blackhole becomes useful only when no more specific reachable component route exists.

## 6. Floating static route

```routeros
/ip route
add dst-address=0.0.0.0/0 gateway=198.51.100.1 distance=1 comment="primary ISP"
add dst-address=0.0.0.0/0 gateway=203.0.113.1 distance=10 comment="backup ISP"
```

This backs up gateway reachability, not necessarily Internet reachability beyond it. Chapter 14 builds recursive monitoring to test a remote probe through each provider.

## 7. Interface gateway caveat

Specifying only an Ethernet interface as a gateway can cause RouterOS to ARP for many destination addresses as if they were directly connected. It is appropriate for true point-to-point interfaces in certain designs, but on broadcast Ethernet prefer a reachable next-hop IP (or a scoped `gateway%interface` where required).

## 8. Dynamic routes

DHCP, PPP, OSPF, BGP, and other services can create dynamic routes. Do not try to remove a dynamic route directly; change the parent client/session/protocol. Use comments and filters to distinguish intent.

## 9. Route troubleshooting workflow

For destination `D`:

1. `/routing rule print` — which policy may select a table?
2. `/routing table print` — does the table exist and participate in FIB?
3. `/routing route print detail where dst-address~"..."` — what candidates exist?
4. Is the intended route active? What is its immediate gateway?
5. Can the router resolve/ping that next hop from the correct source/interface?
6. Does firewall raw/mangle/filter alter or drop the packet?
7. Does the remote side have a return route?
8. Use traceroute/sniffer to identify the last proven point.

## Checkpoint lab

Build the R1–R2–R3 topology from Chapter 2 using only connected and static routes. Then:

- add a more-specific route and predict which path wins;
- create a backup default route and fail the primary link;
- delete only R3's return route and explain asymmetric symptoms;
- add a blackhole summary and prove its counter/behavior with traceroute;
- document every active route's origin and immediate gateway.
