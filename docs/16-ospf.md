# 16 — MTCRE OSPF from First Adjacency to Multi-Area Design

OSPF is a link-state Interior Gateway Protocol. Routers form adjacencies, flood Link-State Advertisements (LSAs), build a synchronized Link-State Database (LSDB) per area, run Dijkstra's Shortest Path First calculation, and install eligible routes.

## 1. OSPF vocabulary

| Term | Meaning |
|---|---|
| Router ID | unique 32-bit identifier, usually represented like IPv4 |
| Area 0 | backbone connecting other OSPF areas |
| Cost | additive interface metric; lower path cost wins |
| Hello/Dead | neighbor discovery/liveness timers that must be compatible |
| DR/BDR | elected representatives on multi-access networks |
| ABR | router attached to multiple areas, including backbone design role |
| ASBR | router injecting external routes |
| LSDB | topology information used for SPF |

OSPFv2 carries IPv4 and uses IP protocol 89, commonly multicast `224.0.0.5`/`224.0.0.6`. OSPFv3 supports IPv6 and uses link-local operation/multicast equivalents. NAT should not modify OSPF packets between neighbors.

## 2. Neighbor states

Memorize the purpose, not only the order:

1. Down — no recent Hello.
2. Init — received peer Hello but peer has not listed us.
3. 2-Way — bidirectional Hello confirmed; on broadcast networks not every pair becomes fully adjacent.
4. ExStart — master/slave and initial sequence negotiation.
5. Exchange — database description packets summarize LSDB.
6. Loading — request missing/newer LSAs.
7. Full — required databases synchronized.

Stuck ExStart/Exchange often points to MTU mismatch or duplicate router ID/packet negotiation issues. Stuck Init points toward one-way communication, multicast, firewall, or subnet problems.

## 3. DR and BDR

On broadcast Ethernet, DR/BDR reduce adjacency/flooding complexity. Election considers OSPF priority, then router ID. Priority 0 prevents eligibility. Election is non-preemptive: a newly arrived higher-priority router does not automatically replace the existing DR.

Point-to-point network type has no DR/BDR election and is appropriate for a two-router link.

## 4. LSA types for the official objective

| OSPFv2 type | Name | Generated/used for |
|---:|---|---|
| 1 | Router | each router's links within an area |
| 2 | Network | DR describes a multi-access segment |
| 3 | Summary | ABR advertises inter-area prefixes/defaults |
| 4 | ASBR Summary | path to an ASBR in another area |
| 5 | AS External | external routes throughout normal areas |
| 7 | NSSA External | external route inside NSSA; translated at boundary |

RouterOS may display friendly LSA names. OSPFv3 LSA numbering/structure differs; do not assume every v2 field maps directly.

## 5. Single-area RouterOS v7 lab

R1–R2 transit `10.0.12.0/30`; loopbacks `10.255.0.1/32` and `.2/32`; R1 LAN `192.168.10.0/24`; R2 LAN `192.168.20.0/24`.

R1:

```routeros
/interface bridge add name=lo protocol-mode=none
/ip address
add address=10.255.0.1/32 interface=lo
add address=10.0.12.1/30 interface=ether2
add address=192.168.10.1/24 interface=br-lan
/routing ospf instance add name=ospf-v2 version=2 router-id=10.255.0.1
/routing ospf area add name=backbone area-id=0.0.0.0 instance=ospf-v2
/routing ospf interface-template
add area=backbone networks=10.0.12.0/30 type=ptp
add area=backbone networks=10.255.0.1/32 passive=yes
add area=backbone networks=192.168.10.0/24 passive=yes
```

R2 uses router ID `10.255.0.2`, matching transit, and its own passive LAN/loopback. `passive=yes` advertises the connected prefix without sending Hellos or accepting neighbors there.

Verify:

```routeros
/routing ospf neighbor print detail
/routing ospf interface print detail
/routing ospf lsa print detail
/routing route print where ospf
/routing stats process print interval=1
```

Do not stop at `Full`: prove each LAN route, next hop, cost, and end-to-end return path.

## 6. Multi-area design

Area 0 is the backbone. Other areas should connect to it through ABRs. Example on an ABR:

```routeros
/routing ospf area
add name=area10 area-id=0.0.0.10 type=default instance=ospf-v2
/routing ospf interface-template
add area=area10 networks=10.0.23.0/30 type=ptp
add area=area10 networks=192.168.30.0/24 passive=yes
```

Use a consistent area configuration at both ends of a link. An area mismatch prevents adjacency.

## 7. Stub, totally stubby and NSSA

- Stub: blocks type-5 external LSAs; uses a default from ABR; no internal ASBR and no virtual-link transit.
- Totally stubby: also suppresses most inter-area summaries; retains intra-area plus default behavior.
- NSSA: permits an ASBR inside the area to generate type-7 externals, translated toward normal areas.

```routeros
/routing ospf area add name=branch area-id=0.0.0.20 type=stub \
    default-cost=10 instance=ospf-v2
```

All routers in the area must agree on compatible area type. `default-cost` controls the ABR-originated default metric.

NSSA form:

```routeros
/routing ospf area add name=nssa30 area-id=0.0.0.30 type=nssa instance=ospf-v2
```

Virtual links cannot transit stub/NSSA areas.

## 8. External route distribution

On an ASBR:

```routeros
/routing ospf instance set ospf-v2 redistribute=static
/routing ospf instance set ospf-v2 originate-default=if-installed
```

Redistribution is a route-leak boundary. Filter exactly which static routes are eligible and set metrics/tags/types deliberately. Do not redistribute connected/static broadly merely to make a lab ping.

External metric types:

- type 1: external metric plus internal OSPF cost to ASBR;
- type 2: external metric dominates; internal cost breaks ties. RouterOS/official behavior details should be verified for the target release.

## 9. SPF, cost and path selection

OSPF builds a graph rooted at the calculating router and sums outgoing interface costs along candidate paths. Lower total cost wins; equal costs may install ECMP. Set costs according to design capacity/latency/failure preference, not arbitrary device numbering.

```routeros
/routing ospf interface-template set [find where interfaces=ether2] cost=10
```

If a template matches by `networks` rather than `interfaces`, select it using its actual properties. Always print before `set [find ...]` to ensure one intended match.

## 10. NBMA, point-to-multipoint and multicast

- broadcast: automatic discovery and DR/BDR;
- point-to-point: two routers, no DR/BDR;
- point-to-multipoint: treats neighbors as P2P relationships over a shared medium;
- NBMA: may require static neighbor configuration because broadcast/multicast discovery is unavailable.

Choose network type consistently. A mismatch can form partial/unstable adjacency or produce unexpected timers/election behavior.

## 11. Area ranges and virtual links

ABRs can aggregate contiguous inter-area prefixes, reducing LSDB/routing size and hiding instability. A summary must match real component design and should be backed by discard behavior as appropriate to prevent default-route loops.

Virtual links logically connect a disconnected area/backbone through a normal transit area. They are a repair tool, not permission for a permanently broken area design; they cannot transit stub/NSSA and add troubleshooting complexity.

## 12. Routing filters and limitations

OSPF is link-state: all routers in an area need a consistent LSDB. An input filter can reject installation of a route into the local RIB but cannot selectively erase the underlying LSA from that area's topology without breaking OSPF's model. Use area boundaries, summarization, stub types, and controlled redistribution for scalable policy.

## 13. Troubleshooting adjacency

Check in order:

1. link/IP/prefix and bidirectional ping;
2. unique router IDs;
3. same area ID/type and OSPF version;
4. compatible network type, Hello/dead, authentication, options;
5. firewall permits protocol 89 and required multicast;
6. no NAT changing neighbor traffic;
7. MTU if stuck ExStart/Exchange;
8. DR/BDR logic if only 2-Way on broadcast;
9. LSDB and route filters after Full;
10. return path/firewall for application traffic.

## MTCRE OSPF checkpoint

Build four routers with area 0 and one non-backbone area. Demonstrate:

- Full point-to-point adjacency;
- DR/BDR election on a broadcast segment;
- Type 1/2/3 LSAs and a passive LAN;
- stub default and NSSA external translation in separate runs;
- ECMP by equal cost;
- summarization and filtered redistribution;
- failures from area mismatch, duplicate router ID, timer mismatch, blocked protocol 89, and MTU mismatch.
