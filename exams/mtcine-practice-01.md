# MTCINE Practice Exam 01

Choose one answer unless marked **choose all that apply**.

## Questions

1. BGP is best described as:
   - A. a path-vector inter-AS routing protocol
   - B. a Layer 2 spanning-tree protocol
   - C. a DHCP transport
   - D. a DNS cache

2. Which transport does BGP use?
   - A. UDP 179
   - B. TCP 179
   - C. IP protocol 89
   - D. GRE 47

3. What does an AS_PATH provide? **Choose all that apply.**
   - A. sequence of traversed ASNs
   - B. loop prevention when local AS appears
   - C. a path-length policy input
   - D. Ethernet FCS

4. A BGP session is Established, but no route is advertised. Which are valid checks? **Choose all that apply.**
   - A. exact active route exists for `output.network`
   - B. output filter accepts it
   - C. remote input filter accepts it
   - D. RSTP elected a DHCP server

5. Which attribute is local to one RouterOS router and highest is preferred first in current best-path selection?
   - A. WEIGHT
   - B. MED
   - C. ORIGIN
   - D. cluster list

6. Which attribute is normally used inside an AS to select the preferred exit, with higher values preferred?
   - A. LOCAL_PREF
   - B. MED
   - C. VLAN PVID
   - D. MPLS TTL

7. Which attribute commonly suggests an entry point to a neighboring AS, with lower values preferred under comparison rules?
   - A. MED
   - B. LOCAL_PREF
   - C. router identity name
   - D. DHCP lease time

8. Why is AS-path prepending not a guaranteed inbound-traffic control?
   - A. remote policies such as LOCAL_PREF can override path length
   - B. BGP ignores AS_PATH
   - C. it encrypts updates
   - D. only OSPF sees it

9. Why does iBGP require a full mesh without another mechanism?
   - A. iBGP-learned routes are not advertised to ordinary iBGP peers
   - B. TCP supports only two routers
   - C. every iBGP peer needs a different AS
   - D. MPLS labels expire

10. What breaks the iBGP full-mesh scaling requirement?
    - A. route reflector
    - B. NAT masquerade
    - C. DHCP relay
    - D. RSTP edge port

11. Which attributes prevent route-reflection loops?
    - A. ORIGINATOR_ID and CLUSTER_LIST
    - B. PVID and L2MTU
    - C. DNS and NTP
    - D. SRC-NAT and DST-NAT

12. An eBGP session targets loopback addresses multiple routed hops apart. What is required?
    - A. underlay reachability plus multihop configuration
    - B. a bridge loop
    - C. PPTP
    - D. removal of all filters

13. A BGP route is received but NEXT_HOP is unreachable. What happens?
    - A. route is not a valid forwarding candidate
    - B. distance automatically creates the next hop
    - C. the prefix becomes connected
    - D. NAT repairs it

14. What MPLS operation does a transit LSR normally perform?
    - A. swap the top label
    - B. resolve DNS
    - C. assign DHCP
    - D. elect DR

15. How large is one MPLS shim label entry?
    - A. 2 bytes
    - B. 4 bytes
    - C. 8 bytes
    - D. 20 bytes

16. Before enabling LDP, what must work end to end?
    - A. provider IP/IGP reachability, especially loopbacks
    - B. VPLS customer MAC learning
    - C. BGP full Internet table
    - D. PPTP encryption

17. What is Penultimate-Hop Popping?
    - A. router before egress removes the transport label after implicit-null signaling
    - B. first router adds two labels
    - C. BGP removes private AS
    - D. bridge drops broadcasts

18. An LDP-signaled VPLS customer frame commonly crosses the core with:
    - A. transport label plus pseudowire/service label
    - B. no labels
    - C. only an IPsec SPI
    - D. an OSPF area ID as Ethernet type

19. What is bridge split horizon used for in hub/spoke VPLS?
    - A. prevent forwarding between ports in the same horizon group
    - B. increase DNS TTL
    - C. select BGP LOCAL_PREF
    - D. assign MPLS labels

20. What can the VPLS control word support in RouterOS?
    - A. pseudowire fragmentation/reassembly and control metadata
    - B. BGP TCP authentication
    - C. DHCP DORA
    - D. Wi-Fi channel selection

21. What is the main purpose of a VRF?
    - A. separate routing/forwarding contexts, including overlapping customer prefixes
    - B. encrypt all frames
    - C. replace Ethernet
    - D. provide NTP

22. Which statement distinguishes RD and RT correctly?
    - A. RD makes VPN prefixes unique; RT controls import/export membership
    - B. RT makes prefixes unique; RD encrypts them
    - C. both are OSPF timers
    - D. both are VLAN tags

23. A wrong import route target is configured on Customer B's VRF. What is the greatest risk?
    - A. routes from another customer can leak into Customer B
    - B. Ethernet auto-negotiation fails
    - C. RouterBOOT upgrades
    - D. DHCP lease becomes static

24. How does RSVP-TE differ from ordinary LDP shortest-path transport?
    - A. it can signal explicit/constraint-based LSPs and reserve resources
    - B. it is a DNS protocol
    - C. it cannot use labels
    - D. it always encrypts traffic

25. A TE tunnel reserves 50 Mbps. Does that alone police customer traffic to 50 Mbps?
    - A. yes, reservation and shaping are identical
    - B. no, reservation/admission and rate enforcement are separate; queue/limit policy is needed
    - C. only if BGP is disabled
    - D. only on DHCP traffic

## Answer key and explanations

1. **A.** BGP exchanges reachability/attributes across administrative domains.
2. **B.** TCP port 179 carries the BGP session.
3. **A, B, C.** It is not an Ethernet integrity field.
4. **A, B, C.** Established proves session transport, not route origination/acceptance.
5. **A.** WEIGHT is local and not advertised; highest is preferred.
6. **A.** LOCAL_PREF coordinates outbound choice inside an AS.
7. **A.** MED is a neighbor-facing entry hint with limited comparison scope.
8. **A.** The remote AS controls its own policy and can ignore your intended influence.
9. **A.** iBGP split horizon prevents ordinary re-advertisement.
10. **A.** RR reflects routes and uses loop-prevention attributes.
11. **A.** They replace AS_PATH-based protection that iBGP reflection cannot use.
12. **A.** Loopbacks are not directly connected eBGP endpoints; route and TTL behavior must support them.
13. **A.** BGP validity requires reachable NEXT_HOP.
14. **A.** Ingress pushes, transit swaps, egress/penultimate path pops as designed.
15. **B.** Label/TC/S/TTL total 32 bits.
16. **A.** LDP follows active IGP reachability; build bottom-up.
17. **A.** PHP reduces egress transport-label work.
18. **A.** Outer reaches PE; inner selects pseudowire.
19. **A.** It prevents spoke-to-spoke bridging through the same horizon group where intended.
20. **A.** It adds overhead and has ordering/performance caveats; correct MTU is preferable.
21. **A.** VRFs isolate FIB/RIB contexts and overlapping space.
22. **A.** RD is uniqueness; RT is VPN membership policy.
23. **A.** This is a customer-isolation/security incident.
24. **A.** RSVP-TE adds signaling, constraints, priorities, and reservation.
25. **B.** Reservation influences path/admission; policing/shaping is separate.
