# Interfaces Menu

Covered paths: **Interfaces → VLAN**, **Interfaces → Bonding**,
**Interfaces → VRRP**, **Interfaces → WireGuard**, and
**Interfaces → Tunnel interfaces**.

**Purpose:** create and operate physical and logical packet ingress/egress
objects. An interface can be running without having an IP address, and can
carry Layer 2 traffic while showing no routed traffic.

## Interface List window

Open **Interfaces**. The list normally exposes name, type, actual/default MTU,
L2MTU, MAC, Tx/Rx rate and packet/error counters. Useful flags include `R`
running, `X` disabled, `S` slave/member and context-specific offload state.

Double-click an interface. Common tabs are:

- **General** — name, MTU, MAC/ARP and type-specific parent/endpoints;
- **Status** — running/link/negotiated or tunnel-session state;
- **Traffic** — live Tx/Rx graph;
- **Statistics** — bytes, packets, drops and errors;
- type-specific tabs such as **Ethernet**, **SFP**, **PoE**, **Dial Out**,
  **WireGuard** or **VLAN**.

## Ethernet

**Path:** Interfaces → Ethernet row → double-click.

**Purpose:** operate a physical copper/SFP Ethernet port.

**Important fields:** `Name` is the administrative name; `Default Name`
identifies the hardware port; `MTU` is the Layer 3 payload limit; `L2MTU`
indicates larger frame capability; `Auto Negotiation` and advertised rates
control link negotiation; flow control, loop protection, bandwidth, MAC,
PoE-out and SFP fields appear only where supported.

**Procedure:** rename by role, add a comment, leave autonegotiation at both ends
unless a documented peer requires otherwise, Apply, then inspect Status and
Statistics. A green/running link with FCS errors, wrong rate or half duplex is
not healthy.

CLI: `/interface ethernet print detail`, `monitor ether1 once`, `print stats`.

## Interface List and members

**Path:** Interfaces → Interface List and Interface List Members tabs (or the
corresponding button/menu depending on WinBox build).

**Purpose:** assign role labels such as `WAN`, `LAN` and `MGMT` so firewall,
discovery and services follow roles instead of physical names.

Create the list first with **+**, `Name`, optional include/exclude and comment.
Then open Members → **+**, select `List` and `Interface`. Dynamic include/exclude
membership and explicit membership must be understood before using a list in a
drop rule.

CLI: `/interface list` and `/interface list member`.

## VLAN interface

**Path:** Interfaces → **+** → VLAN.

**Purpose:** terminate or originate one 802.1Q/802.1ad VLAN on a parent
interface. It does not configure the peer switch or an access port.

The New Interface form contains `Name`, `VLAN ID` (1–4094), `Interface`
(physical, bridge, bonding or stacked VLAN), `Use Service Tag`, MTU and comment.
Choose the parent according to design: for bridge VLAN filtering, use the
bridge CPU-facing parent; for router-on-a-stick, use the trunk interface.

After Apply, add Layer 3 addressing separately under IP/IPv6. Verify running
state, parent link, bridge VLAN membership, tags in a capture and counters.

## Bonding

**Path:** Interfaces → **+** → Bonding.

**Purpose:** combine member links for redundancy and/or load distribution.

The form includes `Name`, `Slaves`, `Mode`, transmit-hash policy, link
monitoring (`mii`/ARP as supported), monitoring interval, primary link and LACP
rate/system properties. `802.3ad` requires compatible LACP on the peer; balance
modes do not make one flow exceed one member's capacity. Do not put member
ports separately in a bridge after bonding; use the bond.

Verify member status, aggregator/partner identity, traffic distribution and
failure/recovery. CLI: `/interface bonding print detail` and `monitor`.

## VRRP

**Path:** Interfaces → **+** → VRRP.

**Purpose:** provide a shared virtual gateway between routers.

Fields include `Interface`, version, `VRID`, priority, advertisement interval,
preemption, authentication where version supports it, sync connection tracking
options and comment. Add the shared virtual address to the VRRP interface, not
as an ordinary duplicate address on both physical parents. Both peers need
matching VRID/version/timers and permitted protocol 112.

Verify state (`MASTER`/`BACKUP`), owner/priority, advertisements, virtual MAC,
client ARP/ND and failover. CLI: `/interface vrrp print detail` and `monitor`.

## WireGuard

**Path:** Interfaces → **+** → WireGuard; peer objects appear in a Peers tab.

**Purpose:** routed encrypted point-to-point/multipoint VPN.

Interface fields include `Name`, private/public key, listen port and MTU. Keep
the private key secret. In Peers → **+**, set public key, optional preshared key,
endpoint address/port, `Allowed Address`, persistent keepalive and comment.
Allowed addresses select outbound peer routes and constrain accepted sources;
overlap between peers causes ambiguity.

Add IP addresses/routes/firewall separately. Verify last handshake, Rx/Tx,
endpoint learning, route, input rule and allowed source. A handshake does not
prove application access.

## Tunnel interface families

The **+** menu can expose 6to4, EoIP, GRE, GRE6, IPIP, IPIPv6, L2TP client,
OpenVPN client, PPPoE client, PPTP client, SSTP client, VXLAN, ZeroTier and
hardware/package-dependent types.

Every tunnel form has some combination of `Local Address`, `Remote Address`,
`Tunnel ID`/VNI, keepalive, DSCP, MTU, clamp TCP MSS, credentials/certificate,
profile and comment. Before Apply:

1. identify carried layer (Ethernet or IP);
2. calculate header overhead/MTU;
3. decide whether encryption/authentication is present;
4. permit the underlay protocol/port;
5. plan return routing and failure detection.

Use the detailed tunnel chapters for configuration. Do not treat EoIP/GRE/IPIP
as encrypted, or PPTP as secure.

## LTE, WiFi, virtual Ethernet and conditional interfaces

LTE/5G, WiFi/wireless, W60G, LoRa, Bluetooth, VETH, container and switch-chip
interfaces appear only with matching packages/hardware/device mode. They are
cataloged in [Conditional menus](14-conditional-menus.md). Their absence is not
proof of a WinBox fault: inspect System → Packages and device capabilities.
