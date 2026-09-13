# IP Menu — Firewall, Security and Application Services

IPsec windows covered: **IP → IPsec → Profiles**, **IP → IPsec → Proposals**,
**IP → IPsec → Peers**, **IP → IPsec → Identities**,
**IP → IPsec → Policies**, **IP → IPsec → Policy Groups**,
**IP → IPsec → Mode Config**, **IP → IPsec → Installed SAs**, and
**IP → IPsec → Active Peers**.

HotSpot windows covered: **IP → Hotspot → Servers**,
**IP → Hotspot → Server Profiles**, **IP → Hotspot → Users**,
**IP → Hotspot → User Profiles**, **IP → Hotspot → Active**,
**IP → Hotspot → Hosts**, **IP → Hotspot → IP Bindings**,
**IP → Hotspot → Walled Garden**, and **IP → Hotspot → Cookies**.

Legacy path covered: **IP → IP Packing**.

## IP → Firewall → Filter Rules

**Purpose:** accept, drop, reject, log, jump or otherwise control IPv4 packets.
Rules are ordered; the first terminating match decides.

Click **+**. The form normally contains:

- **General:** Chain (`input`, `forward`, `output` or custom), source/destination
  address, protocol, ports, interfaces/interface lists and address type;
- **Advanced:** connection state/NAT state, source/destination address lists,
  packet/connection/routing marks, layer-7, content/TLS/DSCP/TCP flags and limits
  as supported;
- **Extra:** time, packet size, random/nth/PSD, hotspot/IPsec and other uncommon
  selectors;
- **Action:** accept/drop/reject, fasttrack, log, jump/return, add to address
  list, mark or passthrough behavior and action-specific parameters;
- **Statistics:** bytes/packets and rate for the rule.

Use `input` for packets to the router, `forward` through it and `output` from a
router process. Build established/related, invalid handling and explicit allows
before a final drop. Reset counters only during a controlled test. Disable a
rule for a reversible comparison; moving it changes behavior immediately.

## IP → Firewall → NAT

**Purpose:** translate addresses/ports, normally on the first packet of a
tracked connection.

The form uses General/Advanced/Extra/Action/Statistics tabs. Choose `srcnat` for
egress source translation and `dstnat` for inbound/policy destination
translation. `masquerade` suits changing interface addresses; `src-nat` names a
fixed translated address. `dst-nat` specifies `To Addresses/Ports`; `redirect`
sends traffic to a router-local service.

After editing NAT, existing connection tracking can retain the old decision.
Clear only the relevant test connection. A matching dst-NAT rule still needs
forward policy, server gateway/firewall/listener and correct return path.

## IP → Firewall → Mangle

**Purpose:** mark connections/packets/routing, adjust DSCP/TTL/MSS and support
QoS/policy-routing decisions.

Forms share the filter match tabs plus actions such as mark connection, mark
packet, mark routing, change MSS/DSCP/TTL, route and passthrough. Connection
marks identify a flow; packet marks identify selected packets; routing marks
select a table. Exclude local router destinations from Internet-only routing
marks. Coordinate with FastTrack, NAT and reverse-path symmetry.

## IP → Firewall → Raw

**Purpose:** act before normal connection tracking in prerouting/output.
Common actions drop traffic early or apply `notrack`. Notrack changes later
stateful firewall and NAT behavior; use only with an explicit packet-flow plan.

## IP → Firewall → Address Lists

**Purpose:** give reusable names to hosts/prefixes and dynamic detections.

Click **+**, choose List name, Address, optional Timeout and Comment. With no
timeout the row is persistent; dynamic firewall actions may add temporary rows.
An address list has no effect until a rule references it. Avoid automatic block
logic that an attacker can trigger against legitimate sources.

## IP → Firewall → Connections

Read-only/live connection tracking: protocol, addresses/ports, reply direction,
state, timeout, marks, NAT, FastTrack and bytes/packets. Removing a row resets
that flow and may interrupt users. Use it to prove NAT/mark/state, not as a
permanent fix.

## IP → Firewall → Service Ports

Connection-tracking helpers for protocols that embed addressing or negotiate
related flows. Disable unused helpers only after understanding application
impact; helpers are not the same as IP → Services listeners.

## IP → Firewall → Layer7 Protocols

Defines regex patterns used by Layer7 match. It is CPU-expensive, limited to
visible payload and ineffective against most encrypted application content.
Prefer address/port/TLS metadata or application-aware controls where possible.

## IP → IPsec

**Purpose:** IKE peer authentication and encrypted IP policies/tunnels.

- **Profiles:** IKE hash/encryption, DH group, lifetime, NAT traversal and DPD.
- **Proposals:** ESP authentication/encryption, PFS and lifetime.
- **Peers:** endpoint/passive/listen, exchange mode, profile and send-initial.
- **Identities:** authentication method, IDs, certificates, secrets and mode
  config/policy template group.
- **Policies:** source/destination selectors, tunnel endpoints, action/level,
  proposal and template/dynamic state.
- **Policy Groups/Templates:** reusable dynamic policy boundaries.
- **Mode Config:** client address/DNS/split include assignments.
- **Installed SAs:** live ESP/AH SPIs, algorithms, endpoints, lifetime and byte
  counters.
- **Active Peers/Remote Peers:** IKE identity, state, uptime and DPD evidence.
- **Keys/Settings:** key objects and global behavior where supported.

Build/troubleshoot in order: underlay → Peer/Profile IKE → Identity/auth →
Proposal/child SA → Policy selector → NAT bypass/firewall → MTU. Never publish
PSKs/private keys or solve mismatch by enabling obsolete algorithms blindly.

## IP → Services

**Purpose:** configure router-local management/API listeners: telnet, FTP, WWW,
SSH, WWW-SSL, API, WinBox and API-SSL as installed.

Double-click a row to set enabled/disabled, Port, allowed Address prefixes,
certificate/TLS version where applicable and connection/session limits. Source
restriction is defense in depth; enforce an input firewall too. Disable unused
clear-text services and confirm access from an independent session before
closing the current one.

## IP → Hotspot

HotSpot provides an IPv4 captive portal. Its child windows include:

- **Servers:** interface, address pool, profile, idle/keepalive/login timeout;
- **Server Profiles:** hotspot address/name, DNS name, HTML directory, login
  methods, certificates, RADIUS, cookie and MAC behavior;
- **Users/User Profiles:** credentials, address, rate/session limits, shared
  users, scripts and advertisement settings;
- **Active/Hosts:** authenticated sessions versus observed client mappings;
- **IP Bindings:** bypass, regular or blocked static client bindings;
- **Walled Garden / IP Walled Garden:** destinations allowed before login;
- **Cookies:** remembered browser/MAC login state;
- **Setup:** wizard that creates address/pool/DHCP/DNS/NAT/HotSpot objects.

Inspect every generated object after Setup. Captive portal HTTPS behavior,
certificate trust, IPv6 bypass, shared credentials and privacy require a
deliberate production design.

## IP → Cloud

**Purpose:** MikroTik cloud functions such as DDNS, time/update assistance and
device-specific services including Back to Home or file share where available.
The form shows enabled settings, public address, DNS name and update/status.
Enabling it creates external communication; read the current service privacy and
dependency notes and do not treat DDNS as firewall access control.

## IP → Traffic Flow

Exports sampled/accounted flow records. Settings control Enabled, Interfaces,
cache/active/inactive timeouts, sampling and NAT events. **Targets** define
collector address/port, version (NetFlow/IPFIX), source and VRF. Verify export
packets and collector templates; flow export can expose sensitive metadata and
consume CPU/bandwidth.

## IP → SNMP (or top-level SNMP)

Global Settings enable SNMP, contact/location, trap target/version/community and
engine ID. **Communities** define name, allowed source, read/write and security
parameters; SNMPv3 users/security fields appear by version. Prefer authenticated
and encrypted SNMPv3, restrict source and firewall, and disable default/public
communities.

## IP → UPnP

Lets trusted clients request dynamic NAT mappings. Settings select Enabled,
allow-disable-external-interface and **Interfaces** mark internal/external roles.
UPnP increases client-controlled exposure; restrict it to an understood home/
lab trust boundary and inspect dynamic NAT state.

## IP → Web Proxy

Configures the built-in HTTP proxy: Enabled, port, source address, parent proxy,
cache path/size, maximum connections/object size and anonymous/header behavior.
**Access** rules permit/deny by source, destination, method and time; **Cache**
rules determine caching. It is not a modern HTTPS inspection system. Never leave
an open proxy reachable from WAN.

## IP → SOCKS

Enables a SOCKS proxy with port, version, connection timeout/max connections and
source controls. **Access** rules define source/destination/action. Disable when
unused; an exposed SOCKS service is an abuse relay.

## IP → SMB

Provides RouterOS file sharing where storage/package support exists. Configure
enabled interfaces/workgroup, users and shares/path/read-only behavior. Restrict
to trusted management/storage networks; protect credentials and removable media.

## IP → TFTP

The TFTP rules window maps client prefixes to file paths and permissions for
simple file transfer/boot workflows. TFTP has no confidentiality or strong
authentication; bind/filter it to an isolated provisioning network.

## IP → Kid Control

Defines child/device groups and allowed/paused schedules, rate limits and device
identity. The Devices window maps MAC/IP and usage state. It is convenient
policy automation, not a hardened identity system; MACs can change and encrypted
applications limit visibility.

## IP → Accounting and IP Packing (legacy/conditional)

Accounting records IPv4 traffic tuples and optional web access; IP Packing is a
legacy small-packet aggregation feature. These may be absent/deprecated or
blocked by device mode. Use current Traffic Flow/telemetry and modern link
design unless a documented compatibility requirement exists.
