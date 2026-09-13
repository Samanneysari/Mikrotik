# IP Menu — Addressing, Neighbors, DHCP, DNS and Routes

Nested paths include **IP → DHCP Server → Option Sets**,
**IP → DHCP Server → Vendor Classes**, **IP → DNS → Cache**,
**IP → DNS → Static**, and **IP → DNS → Adlist**.

The **IP** family configures IPv4 addressing, local IP services, firewall/NAT,
VPN security and several application gateways. An IP submenu can affect packets
to the router (`input`), through it (`forward`) or originated by it (`output`).

## IP → Addresses

**Purpose:** assign IPv4 prefixes to Layer 3 interfaces. Each usable address
normally creates a connected route when its interface is operational.

**What opens:** a list with Address, Network, Interface and comment plus flags
for dynamic/invalid state. Double-click opens **General** and **Status**-style
content depending on WinBox version.

**Add an address:**

1. Open **IP → Addresses** and click **+ / New**.
2. In `Address`, enter host address **and prefix**, for example
   `192.168.10.1/24`. `/24` is the subnet prefix; omitting or choosing it
   incorrectly changes which neighbors RouterOS treats as local.
3. Leave `Network` automatic unless a specific point-to-point/legacy design
   requires an override.
4. Select the Layer 3 `Interface`: bridge for an untagged bridged LAN, VLAN
   interface for a VLAN, tunnel/VRRP/loopback where that object owns the address.
5. Add a purpose comment, click **Apply**, then inspect the generated connected
   route and ARP behavior before **OK**.

**What VRF means here:** a VRF is a separate routing/forwarding context. In
RouterOS v7, interfaces are assigned under **IP → VRF**; the address follows its
interface into that VRF. Do not expect an Address form to repair a missing VRF
route. The same prefix may exist in different VRFs, but tools/services must use
the intended VRF and return path.

**Common mistakes:** putting the same subnet on several member ports; assigning
the gateway to a physical bridge member instead of the bridge/VLAN; using `.0`
or `.255` as an ordinary `/24` host; overlapping prefixes; forgetting the
remote return route; assuming a configured address is active while interface is
down.

Verify with Addresses flags, **IP → Routes**, **IP → ARP**, Ping with source and
`/ip address print detail`.

## IP → ARP

**Purpose:** map local-link IPv4 next hops to MAC addresses.

The list shows address, MAC, interface, status and dynamic/complete/failed flags.
Dynamic rows are learned; a static row is created with **+** by selecting
Address, MAC and Interface. Removing a dynamic row only forces relearning.

Interface ARP mode is configured on the interface: `enabled`, `disabled`,
`reply-only`, `proxy-arp` or `local-proxy-arp`. `reply-only` requires correct
static/DHCP-created entries. An incomplete/failed row points first to subnet,
VLAN, link or peer ownership—not Internet NAT.

## IP → Neighbors

**Purpose:** display MNDP/CDP/LLDP-discovered devices with identity, address,
MAC, interface, platform, version and uptime where advertised. It is discovery,
not authentication or inventory truth.

The **Discovery Settings** window restricts discovery by interface list and
protocol options. Limit it to management/trusted interfaces. A neighbor can be
visible but unreachable by IP; discovery is local-control traffic.

## IP → Pools

**Purpose:** define reusable IPv4 address ranges for DHCP, PPP, HotSpot and VPN.

Click **+**, set a unique Name and one or more non-overlapping Ranges such as
`192.168.10.100-192.168.10.199`. The **Used Addresses** view identifies which
service consumed each address. A pool does not create an interface address,
route or DHCP server. Exclude gateways, statics and infrastructure reservations.

## IP → DHCP Client

**Purpose:** obtain address, gateway, DNS/NTP and optionally a default route
from an upstream server.

New Client fields include Interface, use/add peer DNS/NTP, add default route,
default-route distance, route table/options, hostname/client ID and comment.
The Status pane shows bound/searching/stopped, address, gateway, server, lease
time and expiry.

Use only one intended client per broadcast interface. `Use Peer DNS` can change
router resolver behavior; equal-distance defaults can create unintended ECMP.

## IP → DHCP Server → DHCP

**Purpose:** bind a DHCPv4 server instance to one client-facing Layer 2
interface and pool.

Click **DHCP Setup** for a guided wizard or **+** for manual creation. The wizard
asks interface, network, gateway, pool range, DNS and lease time; inspect every
generated Pool, Network and Server object afterward.

Manual fields include Name, Interface, Address Pool, Lease Time, authoritative
mode, delay threshold, boot/support properties, conflict detection, add-ARP and
RADIUS. The server interface must own/reach the client subnet.

## IP → DHCP Server → Networks

**Purpose:** provide options for a matching client subnet.

New Network includes Address/prefix, Gateway, DNS servers, NTP, domain, WINS,
next server, boot file, DHCP options and netmask. This does not allocate ranges;
the Pool does. A wrong gateway/DNS option creates a valid lease with broken
service, which is different from no lease.

## IP → DHCP Server → Leases

Shows offered/bound/waiting/conflict leases, address, MAC/client ID, hostname,
server, status and expiry. **Make Static** converts a dynamic lease to a stable
reservation. Opening a lease exposes General, Status and advanced option/rate/
address-list fields depending on version. A reservation still requires the
client to use DHCP.

## IP → DHCP Server → Options and Option Sets

**Purpose:** define non-default encoded DHCP options and reusable groups.

Create an Option with Name, numeric Code and correctly encoded Value. An Option
Set groups options for assignment. Incorrect encoding can produce leases that
clients ignore or misinterpret; capture DORA and inspect Option fields before
production.

## IP → DHCP Server → Alerts and Vendor Classes

DHCP Alert watches an interface for unknown DHCP servers and can run a script;
it is detection, not automatic blocking. Vendor Class/Matcher views can select
address pools or options from client identifiers. Match narrowly and keep a
default path so unknown devices do not lose service accidentally.

## IP → DHCP Relay

**Purpose:** forward DHCP broadcasts between a client subnet and central DHCP
server.

Click **+**, set Name, client-facing Interface, DHCP Server address and Local
Address/relay identity. The central server needs a scope for that relay subnet
and a return route. Do not run an unintended local server and relay on the same
segment. Verify Discover on client side and relayed unicast/server response.

## IP → DNS

**Purpose:** configure upstream resolvers, cache and optional router-side DNS
service.

The main Settings form includes Servers/dynamic servers, DoH server and
certificate verification, query timeout/attempts, maximum UDP packet size,
cache size/TTL and `Allow Remote Requests`. Enabling remote requests exposes
UDP/TCP 53 on reachable interfaces; permit only intended clients in input
firewall.

### DNS → Cache

Read-only cached name/type/data/TTL entries. Flush Cache clears learned entries,
not Static records. A cached negative or stale record can explain why explicit
upstream queries and normal client queries differ.

### DNS → Static

Click **+** to add Name, Type, Address/CNAME/data, TTL, regexp/match-subdomain,
forward-to and comment as supported. Exact static names and regex rules have
different matching cost/risk; broad expressions can override more than intended.

### DNS → Adlist

Downloads domain lists and blocks/matches them through the DNS resolver. Fields
include URL, SSL verification, match count/status and file entry limits as
available. Treat the list source as configuration supply chain: verify TLS,
availability, memory impact and false-positive recovery.

## IP → Routes

**Purpose:** IPv4 route view and static-route editor. RouterOS v7 advanced
protocol and policy views also live under **Routing**.

Columns should expose Dst. Address, Gateway, Immediate Gateway, Distance,
Routing Table, Pref. Source, Scope, Target Scope, Check Gateway, protocol flags
and comment.

To add a static route: click **+**, set `Dst. Address` (for example
`192.168.30.0/24` or `0.0.0.0/0`), Gateway/blackhole-unreachable-prohibit type,
Distance, table, scope/target-scope and optional check-gateway. Apply and confirm
`A` active plus intended immediate next hop. Longest prefix wins before distance.

Tabs/status may expose Nexthops and route details. A configured inactive route
needs gateway resolution, interface and policy diagnosis; lowering distance
cannot make an unreachable gateway valid.

## IP → VRF

**Purpose:** assign interfaces to isolated routing tables so overlapping
customer/tenant address spaces can coexist.

Click **+**, set Name and Interfaces. Ordering matters: specific assignments
must precede broad/default matches. After Apply, inspect routes in the generated
table and run tools with the intended VRF/source. VRF isolation does not create
route leaking, firewall policy, NAT or service bindings automatically.
