# 15 — MTCRE Tunnels, VLAN, QinQ and Routed Design

The official MTCRE outline groups VPNs, VLANs, QinQ, and switch-chip concepts. The unifying skill is choosing the correct boundary: route when you can; extend Layer 2 only when a real requirement demands it.

## 1. Site requirements before protocol choice

Ask:

1. Must the sites share one broadcast domain, or only exchange IP prefixes?
2. Is confidentiality/integrity required on the underlay?
3. Are endpoints behind NAT or dynamically addressed?
4. Which vendors must interoperate?
5. What MTU and throughput must be supported?
6. How will routing reconverge and how will a tunnel failure be detected?
7. What is the recovery and key-rotation plan?

Most site connections should be routed. A stretched Layer 2 domain expands failure, broadcast, and spanning-tree scope.

## 2. Routed IPIP site-to-site

Underlay endpoints:

- R1: `198.51.100.1` with LAN `192.168.10.0/24`;
- R2: `203.0.113.2` with LAN `192.168.30.0/24`.

R1:

```routeros
/interface ipip add name=to-r2 local-address=198.51.100.1 \
    remote-address=203.0.113.2 clamp-tcp-mss=yes
/ip address add address=10.255.12.1/30 interface=to-r2
/ip route add dst-address=192.168.30.0/24 gateway=10.255.12.2
```

R2 reverses endpoints, uses `10.255.12.2/30`, and adds the return route. Permit IP protocol 4 on underlay firewalls. IPIP provides encapsulation, not encryption; use an appropriate IPsec design or an encrypted tunnel for untrusted networks.

## 3. EoIP bridge with loop protection

EoIP is MikroTik's Ethernet-over-IP tunnel. Example endpoint:

```routeros
/interface eoip add name=eoip-site2 local-address=198.51.100.1 \
    remote-address=203.0.113.2 tunnel-id=200 clamp-tcp-mss=yes
/interface bridge port add bridge=br-stretched interface=eoip-site2 horizon=200
```

Use the same tunnel ID at both ends of that tunnel and unique IDs where required. `horizon` can prevent forwarding between ports in the same split-horizon group, useful in hub/spoke VPLS/EoIP designs. It is not a substitute for a complete loop/STP design.

Failure domain cost:

- broadcasts/unknown unicast cross WAN;
- a loop or DHCP mistake affects both sites;
- MTU overhead can create silent application failures;
- encryption is absent unless added separately.

## 4. PPP tunnel family

L2TP, SSTP, legacy PPTP, and PPPoE share PPP profile/secret/AAA and active-session concepts. They differ in transport, NAT behavior, encryption, overhead, and interoperability.

- L2TP should be paired with a current IPsec configuration when confidentiality is required.
- SSTP uses TLS; validate the server certificate and trust chain.
- PPTP is legacy/insecure and included only for objective recognition.
- PPPoE is an access method, not an encrypted Internet VPN.

Verify at two levels: the PPP session must be up, and then routes/firewall/DNS across it must work.

```routeros
/ppp active print detail
/interface print where type~"ppp|l2tp|sstp|pptp|pppoe"
/log print where topics~"ppp"
/ip route print where dynamic
```

## 5. WireGuard as the modern routed alternative

Site R1:

```routeros
/interface wireguard add name=wg-r1-r2 listen-port=13232
/ip address add address=10.255.12.1/30 interface=wg-r1-r2
/interface wireguard peers add interface=wg-r1-r2 \
    public-key="R2_PUBLIC_KEY" endpoint-address=203.0.113.2 endpoint-port=13232 \
    allowed-address=10.255.12.2/32,192.168.30.0/24 persistent-keepalive=25s
/ip route add dst-address=192.168.30.0/24 gateway=wg-r1-r2
```

R2 uses the reciprocal peer and prefixes. `allowed-address` must be unique enough to select the correct peer and accept valid source prefixes. `persistent-keepalive` is mainly useful for maintaining NAT state; do not set it everywhere without need.

## 6. VLAN routing through a managed switch

A router-on-a-stick trunk carries VLANs to one router interface:

```routeros
/interface vlan
add name=vlan10 interface=ether2 vlan-id=10
add name=vlan20 interface=ether2 vlan-id=20
/ip address
add address=192.168.10.1/24 interface=vlan10
add address=192.168.20.1/24 interface=vlan20
```

The external managed switch must tag VLAN 10/20 on the router port and make client ports untagged/PVID in the correct VLAN. Inter-VLAN traffic crosses RouterOS Layer 3 and can be filtered.

Contrast with bridge VLAN filtering: router-on-a-stick places the trunk on one physical interface; a VLAN-aware bridge can also switch access/trunk ports locally and may offload them.

## 7. QinQ service transport

Provider network transports customer VLAN 10 inside service VLAN 200:

```routeros
/interface vlan add name=svlan200 interface=ether1 vlan-id=200 use-service-tag=yes
/interface vlan add name=cvlan10 interface=svlan200 vlan-id=10
```

At every hop verify:

- outer EtherType/tag handling;
- inner tag preservation;
- L2MTU for two tags plus any tunnel/MPLS headers;
- switch-chip offload capability;
- separation between customers with overlapping C-VLAN IDs.

QinQ provides segmentation, not encryption.

## 8. MTU calculation example

Start with an underlay IP MTU of 1500. Add tunnel headers. If the overlay attempts 1500 unchanged, the outer packet may exceed underlay MTU. Options include:

- increase physical L2MTU/underlay MTU end to end where supported;
- lower tunnel/overlay MTU;
- clamp TCP MSS for TCP (does not solve non-TCP payloads);
- preserve working ICMP/ICMPv6 Path MTU Discovery.

Test both directions with increasing packet sizes and DF, then transfer real TCP and UDP payloads.

## 9. Tunnel troubleshooting matrix

| Layer | Evidence | Frequent failure |
|---|---|---|
| Underlay | ping/traceroute endpoints | no route/NAT/firewall/provider block |
| Negotiation | logs, PPP/WG/IPsec state | key/cert/auth/profile mismatch |
| Tunnel interface | running flag, counters | endpoint/tunnel ID/keepalive mismatch |
| Overlay L3 | address/route/ARP where applicable | missing return route, overlapping prefix |
| Policy | filter/NAT/mangle counters | FastTrack, NAT before IPsec, blocked protocol |
| MTU | DF ping/capture | overhead exceeds path |
| Application | socket/TLS/log | network works; service does not |

## MTCRE tunnel checkpoint

Build and compare IPIP, EoIP, PPPoE, and WireGuard labs. For each, record carried layer, encryption, overhead, state/verification menu, failure domain, and preferred production use. Demonstrate QinQ tag capture and one MTU failure.
