# 11 — MTCNA+ Production VLAN Filtering and Switching

This chapter builds a single-bridge, VLAN-aware RouterOS design. It is both common and dangerous to configure remotely: one wrong CPU-port membership can remove management access.

## 1. Requirements

| VLAN | Purpose | Subnet | Ports |
|---:|---|---|---|
| 10 | Users | `192.168.10.0/24` | access `ether2`; trunk `ether1` |
| 20 | Servers | `192.168.20.0/24` | access `ether3`; trunk `ether1` |
| 99 | Management | `192.168.99.0/24` | access `ether4`; trunk `ether1` |

The router terminates all three VLANs, so the bridge CPU port must participate tagged. `ether5` is unused and disabled.

## 2. Why configuration order matters

Build while `vlan-filtering=no`, create bridge/ports/VLAN table/VLAN interfaces/IP/firewall, verify, enter Safe Mode, and enable filtering last. If filtering is already enabled on a live system, do not blindly paste the staging sequence.

## 3. Create the bridge and ports

```routeros
/interface bridge add name=br-core protocol-mode=rstp vlan-filtering=no \
    comment="VLAN-aware core bridge"

/interface bridge port
add bridge=br-core interface=ether1 ingress-filtering=yes \
    frame-types=admit-only-vlan-tagged comment="802.1Q trunk"
add bridge=br-core interface=ether2 pvid=10 ingress-filtering=yes \
    frame-types=admit-only-untagged-and-priority-tagged comment="users access"
add bridge=br-core interface=ether3 pvid=20 ingress-filtering=yes \
    frame-types=admit-only-untagged-and-priority-tagged comment="servers access"
add bridge=br-core interface=ether4 pvid=99 ingress-filtering=yes \
    frame-types=admit-only-untagged-and-priority-tagged comment="management access"
/interface disable ether5
```

- PVID assigns an incoming untagged frame to a VLAN.
- `frame-types` rejects unexpected tagged/untagged formats.
- ingress filtering rejects VLANs not allowed for that ingress port by the VLAN table.
- neither PVID nor frame type alone defines where the VLAN may exit; the VLAN table does.

## 4. Build the bridge VLAN table

```routeros
/interface bridge vlan
add bridge=br-core vlan-ids=10 tagged=br-core,ether1 untagged=ether2 \
    comment="users"
add bridge=br-core vlan-ids=20 tagged=br-core,ether1 untagged=ether3 \
    comment="servers"
add bridge=br-core vlan-ids=99 tagged=br-core,ether1 untagged=ether4 \
    comment="management"
```

`br-core` in `tagged` is the CPU/bridge port. It is required here because VLAN interfaces on the bridge deliver those tagged VLANs to RouterOS routing/services.

Avoid combining many VLAN IDs in one row with an untagged port. That can unintentionally make the same access port untagged in multiple VLANs.

## 5. Add Layer 3 interfaces

```routeros
/interface vlan
add name=vlan10-users interface=br-core vlan-id=10
add name=vlan20-servers interface=br-core vlan-id=20
add name=vlan99-mgmt interface=br-core vlan-id=99

/ip address
add address=192.168.10.1/24 interface=vlan10-users
add address=192.168.20.1/24 interface=vlan20-servers
add address=192.168.99.1/24 interface=vlan99-mgmt
```

Do not put an untagged management IP directly on `br-core` in this tagged CPU design.

## 6. Limit management policy before cutover

```routeros
/interface list add name=MGMT
/interface list member add list=MGMT interface=vlan99-mgmt
/tool mac-server set allowed-interface-list=MGMT
/tool mac-server mac-winbox set allowed-interface-list=MGMT
/ip neighbor discovery-settings set discover-interface-list=MGMT
/ip service set winbox address=192.168.99.0/24
/ip service set ssh address=192.168.99.0/24
```

Add matching input-firewall accepts before the final drop. Keep console access during the first cutover.

## 7. Enable and verify

Enter Safe Mode, then:

```routeros
/interface bridge set br-core vlan-filtering=yes
/interface bridge port print detail
/interface bridge vlan print detail
/interface bridge host print
/ip address print
/ip route print where dst-address~"192.168."
```

Tests:

- access clients receive only their VLAN's DHCP/options;
- trunk capture shows tags 10/20/99;
- access-port capture shows ordinary untagged endpoint frames;
- forbidden tags arriving on access ports are dropped;
- management succeeds through VLAN 99 and fails from unauthorized VLANs;
- inter-VLAN traffic follows Layer 3 firewall policy;
- expected ports show hardware-offload `H` when the model supports the design.

## 8. Native VLAN and bridge CPU risks

Mixing tagged and untagged management on the same trunk is error-prone. A PVID mismatch can place untagged traffic in different VLANs at opposite ends. Prefer an explicitly tagged management VLAN and make unused/native VLAN behavior intentional.

## 9. QinQ

802.1ad QinQ adds a service/provider tag around customer-tagged frames. Conceptual RouterOS termination:

```routeros
/interface vlan add name=s-vlan200 interface=ether1 vlan-id=200 use-service-tag=yes
/interface vlan add name=c-vlan10 interface=s-vlan200 vlan-id=10
/ip address add address=192.0.2.1/30 interface=c-vlan10
```

The outer S-tag identifies the service; the inner C-tag identifies the customer VLAN. Switch-chip offload, EtherType, L2MTU, filtering, and tag-stacking configuration are model/version-specific. Two tags add eight Ethernet header bytes, so verify L2MTU across the whole path.

## 10. Failure cases

| Symptom | Likely evidence/root cause |
|---|---|
| All management disappears at enable | CPU/bridge port missing from VLAN 99 or wrong trunk tag |
| One access VLAN fails | wrong PVID, untagged member, or DHCP binding |
| VLAN works through CPU but performance poor | hardware offload absent; inspect `H`, model limits, CPU profile |
| Tagged frames leak to endpoint | wrong frame types/egress membership |
| Same VLAN fails across switch | trunk missing VLAN or opposite-end mismatch |
| Inter-VLAN ping fails | routing/firewall, not bridge switching, once gateways/ARP work |

## Checkpoint

Build this design from console, capture trunk and access frames, prove segmentation, and recover from deliberately removing `br-core` from the management VLAN while Safe Mode is active.
