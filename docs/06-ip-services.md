# 06 — IP Addressing, ARP, DHCP and DNS

## 1. Address objects create connected routes

```routeros
/ip address add address=192.168.40.1/24 interface=br-lan comment="VLAN40 gateway"
/ip address print detail
/ip route print where dst-address=192.168.40.0/24
```

RouterOS creates an active connected route when the bound interface is operational. If the address is present but the interface is not usable, the route may not be active.

Common address mistakes:

- assigning the network (`.0` in a normal `/24`) or broadcast (`.255`) as a host;
- using the wrong prefix length so neighbors disagree about what is local;
- putting the gateway address on a bridge member rather than the bridge/VLAN interface;
- overlapping subnets on multiple interfaces;
- forgetting a return route on the remote router.

## 2. ARP behavior and diagnosis

```routeros
/ip arp print detail where interface=br-lan
/ip arp remove [find where interface=br-lan and dynamic=yes]
/tool sniffer quick interface=br-lan ip-protocol=arp
```

If ARP stays incomplete, verify the peer is in the same subnet/VLAN, link is up, and the peer is actually using that address. Firewall IP filter rules usually are not the first explanation for an unanswered ARP broadcast.

### `reply-only` with DHCP-created ARP

```routeros
/interface bridge set br-lan arp=reply-only
/ip dhcp-server set dhcp-lan add-arp=yes
```

This can constrain normal clients to known lease-created bindings. It also breaks statically addressed hosts unless you add correct ARP entries and has operational caveats. Test lease renewal, failover, and recovery before using it.

## 3. DHCP server built manually

Scenario: VLAN 40 is `192.168.40.0/24`; dynamic clients use `.100–.220`; infrastructure stays outside the pool.

```routeros
/ip pool add name=pool-v40 ranges=192.168.40.100-192.168.40.220
/ip dhcp-server add name=dhcp-v40 interface=vlan40 address-pool=pool-v40 \
    lease-time=8h authoritative=yes disabled=no
/ip dhcp-server network add address=192.168.40.0/24 gateway=192.168.40.1 \
    dns-server=192.168.40.1 domain=corp.example ntp-server=192.168.40.1
```

The three object types have distinct jobs:

- pool: which addresses may be allocated;
- server: which interface listens and which pool it uses;
- network: options for a matching client subnet.

Verify:

```routeros
/ip dhcp-server print detail
/ip dhcp-server network print detail
/ip pool used print
/ip dhcp-server lease print detail
/log print where topics~"dhcp"
```

### Static lease

```routeros
/ip dhcp-server lease add server=dhcp-v40 address=192.168.40.50 \
    mac-address=02:00:00:00:40:50 comment="lab printer"
```

The client still needs to use DHCP. A reservation is not the same as manually configuring the host.

### DHCP client

```routeros
/ip dhcp-client add interface=ether1 add-default-route=yes default-route-distance=1 \
    use-peer-dns=no use-peer-ntp=no disabled=no
/ip dhcp-client print detail
```

Inspect the dynamic address, gateway, route, and status. If two WAN DHCP clients both add a default route with equal distance, you may accidentally create ECMP.

### DHCP relay

A relay is used when clients and the DHCP server are separated by a router. The relay forwards requests and identifies the client-facing network. Do not run both an unintended local server and relay on the same segment.

```routeros
/ip dhcp-relay add name=relay-v50 interface=vlan50 dhcp-server=10.10.10.10 \
    local-address=192.168.50.1 disabled=no
```

The central server must have a scope/network definition for VLAN 50 and a return route to the relay. Firewalls must permit DHCP relay traffic.

## 4. RouterOS DNS cache

```routeros
/ip dns set servers=9.9.9.9,1.1.1.1 allow-remote-requests=yes cache-size=4096KiB
/ip dns static add name=router.lab.example address=192.168.40.1 ttl=1h
/resolve router.lab.example
/ip dns cache print where name~"example"
```

If `allow-remote-requests=yes`, protect DNS in the input chain so only intended clients can query the router. An open resolver can be abused in reflection/amplification attacks.

DNS troubleshooting sequence:

```routeros
/ping 9.9.9.9
/resolve example.com server=9.9.9.9
/resolve example.com
/ip dns cache flush
```

- remote IP fails: solve routing/firewall first;
- explicit server works but normal resolve fails: check configured resolver/cache;
- router resolves but client does not: check DHCP option, client setting, and input firewall.

## 5. IPv6 address and neighbor basics

```routeros
/ipv6 address add address=2001:db8:40::1/64 interface=vlan40 advertise=yes
/ipv6 address print detail
/ipv6 neighbor print detail
/ipv6 route print detail
```

Router Advertisements can tell hosts a prefix and default-router information. DHCPv6 is not an IPv4 DHCP clone: depending on design it may provide stateful addresses, other options, or delegated prefixes. Always build `/ipv6 firewall filter` rules; IPv4 filter rules do not protect IPv6.

## 6. Multi-service failure scenario

Symptom: a client has `169.254.12.5`, cannot ping gateway, and no DHCP lease appears.

Reasoning:

1. `169.254.0.0/16` indicates the client self-assigned after DHCP failure.
2. No lease means the failure is before normal routed Internet access.
3. Check client link, VLAN/access port, bridge port, DHCP server status/interface, pool exhaustion, and packet capture of UDP 67/68.
4. Do not start by adding NAT rules; NAT occurs later and cannot make DHCP Discover reach the correct Layer 2 domain.

## Checkpoint

Build two VLAN interfaces, each with a unique `/24`, pool, DHCP server, network options, and protected DNS service. Inject these faults one at a time:

- wrong DHCP server interface;
- empty pool;
- wrong gateway option;
- missing VLAN on trunk;
- DNS input drop.

For each, record the first piece of evidence that proves the failing layer.
