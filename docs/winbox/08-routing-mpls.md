# Routing and MPLS Menus

Conditional protocol/service paths include **Routing → IS-IS**,
**Routing → RPKI**, **Routing → PIM**, **Interfaces → VPLS**, and
**Routing → BGP → VPN**.

## Routing → Tables

Creates named routing tables. Click **+**, enter Name and enable `FIB` when the
table must forward packets. A table by itself is empty; add routes/protocol
instances and a selection rule/mark. Gateway recursion often uses `@main`.

## Routing → Rules

Ordered policy selecting a table by source/destination, interfaces and routing
mark. Actions are normally `lookup`, `lookup-only-in-table`, `drop` or
`unreachable`. `lookup` may fall back; `lookup-only` enforces isolation. Verify
router-local and forwarded traffic separately.

## Routing → Routes

Protocol-rich RIB view. Expose destination, gateway/immediate gateway, table,
distance, scope/target-scope, protocol, attributes, selected/best/active and
hardware-offload state. Filters change display only. Double-click a dynamic row
to inspect attributes/source; edit its parent protocol, not the row.

## Routing → Nexthops

Shows recursive gateway-resolution objects, immediate gateway, interface,
labels, check-gateway state and refcounts. Use it when a configured route is
inactive or resolves through the wrong ISP/table.

## Routing → Filters → Rules

Ordered RouterOS v7 routing-policy chains. New Rule selects Chain, textual Rule
expression, disabled state and comment. Rules match prefix/protocol/attributes
and accept, reject or mutate attributes. Unmatched behavior must be understood;
use explicit terminal accept/reject and test with a lab prefix. Filter effects
can be visible in filtered routes while underlying protocol state remains up.

## Routing → OSPF

- **Instances:** version, router ID, VRF, redistribution, default origination,
  domain/tag and calculation settings.
- **Areas:** instance, area ID, default/stub/NSSA type, default cost and ranges.
- **Interface Templates:** area plus interfaces/networks, network type, passive,
  cost, priority, timers, authentication and BFD.
- **Interfaces:** resolved dynamic operational interfaces and DR/BDR/state.
- **Neighbors:** router ID/address, interface, state, priority, DR/BDR and
  state-change time.
- **LSA:** LSDB entries by area/type/origin/sequence/age.
- **Routes/Statistics:** protocol candidates and process/SPF behavior as exposed.

Create instance → area → interface templates. Use unique stable router IDs and
passive LANs. Diagnose adjacency in link/IP → area/type/timers/auth → firewall
protocol 89 → MTU → LSDB/route order.

## Routing → BGP

- **Instances:** ASN, router ID, VRF and global behavior.
- **Templates:** reusable local/remote role, AS, address families, timers,
  multihop, BFD, capabilities and filter settings.
- **Connections:** peer endpoint/listen range, local address/role, remote AS,
  template inheritance, input/output policy and network origination.
- **Sessions:** live state, uptime, negotiated AS/ID/capabilities, messages,
  prefixes and errors.
- **Advertisements/Routes:** received/selected/filtered and retained sent state,
  depending on resource-saving settings.
- **VPN:** VRF, RD, import/export RT and redistribution for L3VPN.

Build underlay first, then connection/session, exact origin candidates, output
filter, remote input policy, next-hop validity and FIB. An Established session
does not prove any prefix is exchanged. Default-allow Internet policy is unsafe.

## Routing → BFD

Fast failure detection sessions/configuration. Interfaces/templates select
minimum transmit/receive interval, multiplier, addresses and authentication as
available. The Sessions view shows local/remote discriminator and Up/Down state.
BFD must be enabled by the parent routing protocol and peer; aggressive timers
can create CPU load and false failures.

## Routing → RIP, IS-IS, RPKI and PIM/IGMP

These appear with current feature/package support:

- **RIP:** instance, interface template, neighbor and route state; configure
  version/authentication, redistribution and filters deliberately.
- **IS-IS:** instances, areas/interfaces, adjacencies and LSDB; validate NET,
  level, network type, MTU and CLNS transport.
- **RPKI:** cache/group/validator state and routing-filter validation results;
  stale/unavailable validation must have an explicit fail policy.
- **PIM-SM/IGMP Proxy:** instances/interfaces, neighbors, joins, groups, RP and
  multicast route state. Multicast forwarding is not ordinary unicast routing.

## MPLS → Interfaces

Selects interfaces eligible for MPLS forwarding and their MPLS MTU. Every label
adds four bytes; validate primary and backup path L2MTU. Do not enable MPLS on
customer-facing interfaces without a defined service design.

## MPLS → Forwarding Table

Read-only LFIB: local label, outgoing label/action, FEC/destination, nexthop and
interface. It proves push/swap/pop behavior. A route in IP FIB without a usable
label path is not an MPLS service.

## MPLS → LDP

- **Instances:** LSR ID, transport address, VRF and address family;
- **Interfaces:** where LDP discovery runs, hello timers and transport choices;
- **Neighbors:** discovery/session state and peer transport address;
- **Local/Remote Mappings:** FEC-to-label bindings and selected mapping;
- **Accept/Advertise Filters:** restrict bindings where current RouterOS exposes
  them.

Prove IGP loopback reachability before LDP. Then verify neighbor, mappings and
LFIB, not merely interface enabled state.

## MPLS → Traffic Engineering

RSVP-TE interface/path/tunnel views contain bandwidth, affinities/resource
classes, CSPF/static path hops, setup/holding priority, primary/secondary paths,
record route and operational state. A bandwidth reservation influences path
admission; it does not police customer traffic. Configure queues separately.

## MPLS/VPLS and L3VPN related windows

VPLS interfaces are commonly created under Interfaces and show peer, VPLS ID,
local/remote label, control word, MTU and running state. BGP-signaled VPLS and
VPNv4/v6 state also depends on Routing → BGP. VRFs live under IP → VRF. Follow
the control path: IGP → LDP/transport label → MP-BGP/service label → VRF/bridge.
