# 01 — Networking from Absolute Zero

MTCNA officially assumes that you already understand TCP/IP and subnetting. This chapter supplies that missing floor. Do not rush it: routing, firewall, NAT, OSPF, BGP, and MPLS are different ways of acting on the same packet-delivery fundamentals.

## 1. A network is a delivery system

A host sends information in chunks. Each layer adds the information needed by a different delivery scope:

| TCP/IP layer | Common unit | Identifier | Typical devices/functions |
|---|---|---|---|
| Application | data | names, URLs | DNS, HTTP, SSH |
| Transport | segment/datagram | TCP/UDP port | connection state, firewall |
| Internet | packet | IP address | router, route table |
| Link | frame | MAC address | NIC, bridge, switch |
| Physical | bits/signals | none | cable, radio, optic |

An Ethernet frame is useful on one Layer 2 domain. An IP packet can cross routers. A TCP connection gives applications an ordered, reliable byte stream. These units are nested, not competing alternatives.

### Worked walk-through: opening a website

PC `192.168.10.20/24` has gateway `192.168.10.1`. It opens `https://example.net` at `203.0.113.80`.

1. The PC asks DNS for `example.net` and learns `203.0.113.80`.
2. It compares the destination to its own `/24`. The destination is not local.
3. It needs the gateway's MAC address, so it checks ARP and, if necessary, broadcasts “Who has 192.168.10.1?”
4. It creates an Ethernet frame addressed to the router's MAC. Inside is an IP packet addressed to `203.0.113.80`; inside that is a TCP segment addressed to destination port 443.
5. The router removes the incoming Ethernet header, checks firewall/routing policy, selects a next hop, decrements IP TTL, and builds a new Layer 2 frame for the next link.
6. If the private source must cross the public Internet, source NAT changes the source IP/port while connection tracking remembers the reverse translation.

Critical distinction: the destination IP normally remains the remote server end to end, while the source and destination MAC addresses change at every routed hop. NAT is an explicit exception that modifies an IP/port field.

## 2. Bits, bytes and binary

A bit is `0` or `1`; eight bits form a byte (octet). IPv4 contains 32 bits shown as four decimal octets.

| Bit value | 128 | 64 | 32 | 16 | 8 | 4 | 2 | 1 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Example | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |

`11000000` equals `128 + 64 = 192`. You do not need to convert every address manually forever, but binary explains masks and prefix boundaries.

## 3. MAC addresses, Ethernet and broadcast domains

A MAC address is normally a 48-bit Layer 2 identifier such as `D4:01:C3:AA:10:20`. An Ethernet switch learns the source MAC seen on each port and forwards known unicast frames toward the learned port. Unknown unicast and broadcast traffic is flooded within the VLAN.

A **collision domain** is effectively one full-duplex Ethernet link in modern switched networks. A **broadcast domain** is the set of ports allowed to receive the same Layer 2 broadcast; routers and VLAN boundaries separate it.

### ARP: connecting IPv4 to Ethernet

ARP maps an IPv4 address to a MAC address on the local link:

```routeros
/ip arp print detail
```

RouterOS ARP modes:

- `enabled`: normal dynamic ARP and static entries;
- `disabled`: do not use ARP on the interface;
- `reply-only`: reply only for matching entries already in the ARP table; often paired carefully with DHCP `add-arp=yes`;
- `proxy-arp`: answer on behalf of reachable hosts on another interface;
- `local-proxy-arp`: proxy between hosts on the same interface.

`reply-only` is not a magical security switch. A wrong or missing static/DHCP-created entry simply breaks reachability.

## 4. IPv4 addresses and prefixes

An IPv4 address has a **network part** and a **host part**. The prefix length tells how many leftmost bits are network bits.

`192.168.10.34/24` means:

- mask: `255.255.255.0`;
- network: `192.168.10.0`;
- usable hosts: `192.168.10.1` through `192.168.10.254` under ordinary subnetting;
- broadcast: `192.168.10.255`;
- addresses in block: `2^(32-24) = 256`.

### The block-size method

For an interesting octet, block size is `256 - mask_octet`.

Example: `172.16.35.77/27`.

- `/27` mask is `255.255.255.224`.
- Block size is `256 - 224 = 32`.
- Fourth-octet blocks begin at 0, 32, 64, 96, ...
- `77` lies in 64–95.
- Network is `172.16.35.64`; broadcast is `.95`; ordinary usable range is `.65–.94`.

### Must-know prefix table

| Prefix | Mask | Total addresses | Common use |
|---:|---|---:|---|
| /24 | 255.255.255.0 | 256 | small LAN |
| /25 | 255.255.255.128 | 128 | half a /24 |
| /26 | 255.255.255.192 | 64 | medium VLAN |
| /27 | 255.255.255.224 | 32 | small VLAN |
| /28 | 255.255.255.240 | 16 | infrastructure/services |
| /29 | 255.255.255.248 | 8 | small transit/public block |
| /30 | 255.255.255.252 | 4 | traditional point-to-point |
| /31 | 255.255.255.254 | 2 | RFC 3021 point-to-point where supported |
| /32 | 255.255.255.255 | 1 | host/loopback route |

### Subnetting example: four departments

Requirement: split `192.168.50.0/24` into four equal networks.

Borrow two host bits because `2² = 4`; new prefix is `/26`. Block size is 64.

| Department | Network | Usable range | Broadcast |
|---|---|---|---|
| Users | 192.168.50.0/26 | .1–.62 | .63 |
| Voice | 192.168.50.64/26 | .65–.126 | .127 |
| Servers | 192.168.50.128/26 | .129–.190 | .191 |
| Guest | 192.168.50.192/26 | .193–.254 | .255 |

Explanation: every address still belongs to the original `/24`, but `/26` creates four distinct routing and broadcast boundaries. A VLAN is commonly paired one-to-one with one of these IP subnets, although VLAN and subnet are different layers.

## 5. Special IPv4 ranges

| Purpose | Range |
|---|---|
| Private | `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16` |
| Loopback | `127.0.0.0/8` |
| Link-local/APIPA | `169.254.0.0/16` |
| Multicast | `224.0.0.0/4` |
| Documentation | `192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24` |
| Default route | `0.0.0.0/0` |

Private addresses are not Internet-routable by convention. NAT often lets many private hosts share public space, but NAT is not the same as a firewall and is not required merely because routing exists.

## 6. Gateway, routing and longest-prefix match

A host sends local-subnet traffic directly. It sends non-local traffic to a configured gateway. A router then selects the most specific matching active route.

Given:

```text
0.0.0.0/0          via ISP-A
10.0.0.0/8         via Core
10.20.0.0/16       via Branch-20
10.20.30.0/24      via Datacenter
```

A packet for `10.20.30.44` uses `/24`, not `/16`, `/8`, or `/0`. This is **longest-prefix match**. Administrative distance compares candidate routes to the *same destination prefix*; it does not make a default route beat a more specific route.

## 7. ICMP, TCP and UDP

ICMP reports network conditions and supports tools such as ping. Blocking all ICMP damages diagnostics and can break functions such as Path MTU Discovery.

TCP:

- connection-oriented;
- uses a three-way handshake (SYN, SYN-ACK, ACK);
- provides ordering, retransmission, and flow control;
- examples: SSH 22, HTTPS 443, BGP 179.

UDP:

- connectionless at the transport layer;
- no built-in delivery guarantee or ordering;
- lower overhead and useful for request/response or real-time traffic;
- examples: DNS 53 commonly uses UDP and sometimes TCP, DHCP uses UDP 67/68, SNMP commonly uses UDP 161.

A port identifies an application endpoint, not a physical socket. A flow is commonly identified by source IP, source port, destination IP, destination port, and protocol—the five-tuple.

## 8. DNS and DHCP

DNS maps names to records. A client can have valid IP routing yet appear “offline” because DNS fails. Always separate tests:

1. ping a local gateway;
2. ping a remote IP;
3. resolve a name;
4. connect to the application port.

DHCP's simplified IPv4 exchange is DORA:

1. Discover — client broadcasts that it needs configuration.
2. Offer — server proposes an address.
3. Request — client asks for the selected offer.
4. Acknowledge — server confirms lease and options.

The offered data usually includes address/prefix, gateway, DNS servers, and lease time. A DHCP relay forwards DHCP between broadcast domains without placing a server in every VLAN.

## 9. IPv6 essentials

IPv6 uses 128-bit hexadecimal addresses. `2001:db8:10::1/64` is documentation space. A normal LAN prefix is generally `/64`. Important categories:

- `::1/128`: loopback;
- `fe80::/10`: link-local; automatically important for neighbor and router communication;
- `2000::/3`: global unicast space;
- `fc00::/7`: unique local addresses;
- `ff00::/8`: multicast.

IPv6 uses Neighbor Discovery rather than ARP. Hosts can use SLAAC, DHCPv6, or both depending on design. IPv6 is not “secure because it is not NATed”; build an IPv6 firewall policy as carefully as IPv4.

## 10. MTU and fragmentation

MTU is the largest Layer 3 packet an interface can carry without fragmentation at that layer. Ethernet commonly has an IP MTU of 1500 bytes. VLAN tags, tunnels, MPLS labels, PPPoE, and encryption add overhead. If a path cannot carry the resulting frame and discovery is broken, small pings may work while large transfers fail.

Example diagnostic:

```routeros
/ping 198.51.100.1 size=1472 do-not-fragment
```

For IPv4, 1472 bytes of ICMP payload plus 20-byte IP and 8-byte ICMP headers equals 1500. Reduce the size to discover an approximate path limit. Do not “fix” MTU problems by random values; account for every encapsulation and interface L2MTU.

## Foundation checkpoint

You are ready to continue when you can do all of the following without notes:

- find network, usable range, and broadcast for `10.44.19.173/28`;
- explain why a host ARPs for its gateway rather than the remote server;
- describe which identifiers change at a routed hop;
- explain why `10.20.30.0/24` wins over `10.0.0.0/8`;
- distinguish routing, NAT, DNS, and firewall failures;
- explain why a normal IPv6 LAN uses a `/64` and still needs firewall rules.

Answer to the subnet task: block size 16; network `10.44.19.160`, usable `.161–.174`, broadcast `.175`.
