# 05 — Ethernet, Bridges, VLAN Foundations and Wireless

## 1. Interface state before configuration

```routeros
/interface ethernet print detail
/interface ethernet monitor ether2 once
/interface ethernet print stats
```

Check `running`, negotiated rate/duplex, errors, drops, MTU/L2MTU, SFP diagnostics, and whether a port is already a bridge/bond member. A cable problem cannot be fixed by a route.

## 2. What a bridge does

A RouterOS bridge is a software-defined Layer 2 switch. On supported hardware, some bridge forwarding can be offloaded to a switch chip. The `H` flag on bridge ports is evidence of active hardware offload; do not assume it from the product name.

Worked LAN bridge:

```routeros
/interface bridge add name=br-office protocol-mode=rstp comment="office Layer 2 domain"
/interface bridge port
add bridge=br-office interface=ether2
add bridge=br-office interface=ether3
add bridge=br-office interface=ether4
/ip address add address=192.168.20.1/24 interface=br-office
```

Why the IP is on the bridge: the router's own Layer 3 endpoint belongs to the combined Layer 2 domain. Putting the same subnet on member ports creates ambiguous/broken design.

Verify:

```routeros
/interface bridge print detail
/interface bridge port print detail
/interface bridge host print
```

The host table proves which source MACs have been learned on which ports. If no MAC appears, inspect physical/virtual link state and traffic generation.

## 3. Loops and spanning tree

Two active Layer 2 paths can circulate broadcasts and unknown unicast indefinitely. Ethernet has no native TTL. RSTP prevents loops by calculating a tree and blocking redundant paths.

Key terms:

- root bridge: bridge with lowest bridge ID;
- root port: best path from a non-root bridge toward root;
- designated port: forwarding port for a segment;
- alternate port: backup, normally discarding;
- path cost: preference derived from link speed or set by design.

Check:

```routeros
/interface bridge monitor br-office
/interface bridge port print detail
```

Choose the root intentionally in managed networks. Do not “solve” a blocked port by disabling STP unless you have proven the topology cannot loop.

## 4. VLAN concept

A VLAN tags an Ethernet frame with an identifier (VID) so one physical system can carry several separate broadcast domains.

- **Access port**: endpoints send/receive untagged frames; switch assigns a PVID internally.
- **Trunk port**: carries tagged frames for multiple VLANs.
- **Native/untagged VLAN**: a VLAN transported untagged on a trunk; avoid casual use because mismatches are dangerous.
- **CPU/bridge port**: the router itself; it must be tagged/untagged correctly if RouterOS provides Layer 3 service in a VLAN.

VLAN is Layer 2 segmentation. An IP subnet is Layer 3 addressing. They are commonly mapped one-to-one so the router can control traffic between them.

Chapter 11 builds the complete bridge VLAN filtering design. For now, create one VLAN interface over a known trunk:

```routeros
/interface vlan add name=vlan10-users interface=ether2 vlan-id=10
/ip address add address=192.168.10.1/24 interface=vlan10-users
```

This makes the router terminate VLAN 10 tags arriving on `ether2`. It does not configure the other switch, permit VLAN 10 in a bridge VLAN table, or make an access port. Those are separate requirements.

## 5. Hardware offload and switch chips

MikroTik models differ significantly:

- some have one switch chip, some multiple chips, some none;
- certain bridge features keep forwarding in hardware; others send traffic through CPU;
- VLAN, ACL, bonding, and Layer 3 offload capabilities vary;
- L2MTU and port grouping matter for tags/MPLS.

Before a production VLAN design:

1. read the exact model block diagram;
2. confirm supported offload features for the RouterOS version;
3. observe `H` flags and CPU profile under load;
4. test failover and forbidden VLANs, not only permitted traffic.

## 6. Wireless foundations

### Radio terms

- frequency/band: spectrum region (for example 2.4, 5, or 6 GHz subject to device/regulation);
- channel width: wider can raise capacity but consumes more spectrum and may increase interference;
- data rate: PHY signaling rate, not application throughput;
- chain: radio spatial stream path; multiple chains enable MIMO behavior;
- transmit power and receive sensitivity: link-budget inputs, not a “set both to maximum” recipe;
- SNR: signal above noise; often more informative than signal alone;
- country/regulatory domain: controls legal channels/power; configure truthfully.

Capacity is shared airtime. A client at a poor rate can consume disproportionate airtime. AP placement, channel reuse, interference, client capabilities, and wired backhaul matter more than a maximum-rate label.

### RouterOS wireless menu generations

Modern Wi-Fi-capable devices commonly use the `wifi` package and `/interface wifi`. Older devices may use the legacy `wireless` package and `/interface wireless`. Names and available properties are not interchangeable. Determine the device/package first:

```routeros
/system package print
/interface print
```

### Modern AP example (adapt to device and regulation)

```routeros
/interface wifi security add name=sec-office authentication-types=wpa2-psk,wpa3-psk \
    passphrase="REPLACE-WITH-LAB-SECRET"
/interface wifi configuration add name=cfg-office ssid="Office-Lab" country="Germany" \
    security=sec-office
/interface wifi set [find default-name=wifi1] configuration=cfg-office disabled=no
```

Explanation:

- security and radio/network configuration are reusable objects;
- country must match the actual deployment;
- WPA3 support depends on client/device/package; mixed WPA2/WPA3 can aid transition;
- verify the exact CLI with `?` because properties evolve across packages/releases.

Add the Wi-Fi interface to the correct bridge/VLAN according to the design; enabling an SSID alone does not give it IP service.

### AP and station roles

An AP advertises a network and accepts stations. A station scans/selects and associates. A transparent Layer 2 station bridge requires compatible modes/protocol behavior; ordinary 802.11 client mode does not automatically transport arbitrary downstream MAC addresses like an Ethernet cable.

### Access/connect lists

Access lists influence which stations an AP accepts; connect lists influence station selection. MAC lists are operational controls, not strong authentication—MAC addresses can be observed/spoofed. Use modern cryptographic authentication.

### Wireless verification

Depending on package:

```routeros
/interface wifi print detail
/interface wifi registration-table print detail
/interface wifi scan wifi1 duration=10s
```

Legacy counterparts live under `/interface wireless`. Inspect registration signal, rate, uptime, authentication, channel, retransmissions, and log topics. A “connected” station may still fail due to VLAN, DHCP, firewall, or DNS.

## 7. Layer 2 troubleshooting ladder

1. physical power/cable/radio and link state;
2. negotiated rate/duplex and errors;
3. interface enabled and correct bridge membership;
4. STP role/state;
5. VLAN tag/PVID/frame-types/ingress-filtering symmetry;
6. learned MAC location;
7. ARP/ND resolution;
8. only then IP routes and firewall.

## Checkpoint lab

Build two VLANs across two CHRs acting as switches. Put two clients in VLAN 10 and one in VLAN 20. Prove:

- same-VLAN clients exchange frames without routing;
- cross-VLAN traffic fails until a router interface and route exist;
- removing a trunk VLAN breaks only that VLAN;
- a redundant link is blocked by RSTP;
- bridge host and packet-capture evidence identify each behavior.
