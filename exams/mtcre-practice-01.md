# MTCRE Practice Exam 01

Choose one answer unless marked **choose all that apply**.

## Questions

1. Routes for `10.0.0.0/8` distance 1 and `10.1.0.0/16` distance 110 exist. Which is used for `10.1.2.3`?
   - A. `/8` due to lower distance
   - B. `/16` due to longest-prefix match
   - C. both are always ECMP
   - D. neither

2. What creates ECMP for one prefix?
   - A. two active equally preferred next hops
   - B. any two default routes with different distance
   - C. two VLAN IDs
   - D. a DHCP pool

3. What is a floating static route?
   - A. a lower-preference backup, commonly using a higher distance
   - B. a dynamic OSPF LSA
   - C. a bridge host entry
   - D. a route without a gateway in all cases

4. Why can checking only the directly connected ISP gateway be insufficient?
   - A. the gateway can respond while upstream Internet reachability is broken
   - B. RouterOS cannot ping connected hosts
   - C. distance disables ICMP
   - D. NAT removes the gateway

5. In recursive failover, what is the purpose of a probe `/32` pinned through one ISP?
   - A. provide a resolvable path that tests beyond the local gateway
   - B. configure DNS for clients
   - C. create a bridge loop
   - D. assign an OSPF area

6. What relationship must hold for recursive gateway resolution?
   - A. the referring route's target-scope must permit the resolving route's scope
   - B. all scopes must be 255
   - C. distance must equal VLAN ID
   - D. source NAT must be disabled

7. Why qualify `192.0.2.1%ether2` as a gateway?
   - A. bind next-hop resolution to the intended interface
   - B. encrypt the gateway
   - C. create a PPP user
   - D. set BGP LOCAL_PREF

8. Before using a custom RouterOS v7 forwarding table, what must be done?
   - A. create it under `/routing table` with `fib` when forwarding is required
   - B. enable PPTP
   - C. delete main
   - D. add it to DNS

9. What is the difference between routing-rule actions `lookup` and `lookup-only-in-table`?
   - A. `lookup` may fall back; `lookup-only-in-table` does not
   - B. only the latter supports IPv4
   - C. `lookup` is a firewall drop
   - D. no difference

10. A mangle rule marks LAN traffic into an ISP table and router management becomes unreachable. Most likely cause?
    - A. it also marked destinations owned by the router
    - B. ARP became BGP
    - C. DHCP lease is too long
    - D. LDP PHP

11. What is a valid use for `/31` addressing?
    - A. a two-node point-to-point link where both ends support it
    - B. a LAN with 200 clients
    - C. an OSPF area ID list
    - D. Wi-Fi channel selection

12. Which tunnel carries Ethernet frames and can extend a broadcast domain?
    - A. EoIP
    - B. IPIP
    - C. WireGuard only as Ethernet
    - D. BGP

13. Which statement about IPIP is correct?
    - A. it carries Layer 3 but does not encrypt by itself
    - B. it is always TLS encrypted
    - C. it carries only DHCP leases
    - D. it prevents MTU overhead

14. Why prefer routed site-to-site connectivity over EoIP when possible? **Choose all that apply.**
    - A. smaller broadcast/loop failure domain
    - B. simpler route policy and scaling
    - C. EoIP automatically encrypts everything
    - D. avoids stretching STP/DHCP mistakes between sites

15. What does QinQ add?
    - A. an outer service VLAN tag around customer-tagged traffic
    - B. an OSPF type-5 LSA
    - C. TCP reliability to UDP
    - D. encryption

16. Two VLAN tags add how much header overhead?
    - A. 2 bytes
    - B. 4 bytes
    - C. 8 bytes
    - D. 32 bytes

17. What is OSPF's fundamental routing model?
    - A. link-state with LSDB flooding and SPF calculation
    - B. path-vector between only external ASes
    - C. pure static forwarding
    - D. DNS-based routing

18. Which OSPF state confirms bidirectional Hello communication?
    - A. Down
    - B. Init
    - C. 2-Way
    - D. Loading only

19. Neighbors on a broadcast LAN are 2-Way with each other but Full with DR/BDR. What does this usually indicate?
    - A. expected adjacency optimization
    - B. certain total failure
    - C. duplicate DHCP pools
    - D. wrong NAT action

20. OSPF is stuck in ExStart/Exchange. Which is a leading suspect?
    - A. MTU mismatch
    - B. DNS TTL
    - C. Simple Queue name
    - D. source NAT port

21. Which LSA does every OSPFv2 router originate to describe its links inside an area?
    - A. Type 1 Router LSA
    - B. Type 5 only
    - C. Type 7 only
    - D. BGP UPDATE

22. Which OSPF router connects areas?
    - A. ABR
    - B. DHCP relay
    - C. LER only
    - D. DNS resolver

23. Which area permits an internal ASBR to originate Type 7 external LSAs?
    - A. NSSA
    - B. ordinary stub
    - C. totally stubby only
    - D. no OSPF area

24. What is the difference between OSPF external metric Type 1 and Type 2?
    - A. Type 1 includes internal cost to ASBR; Type 2 primarily uses external metric
    - B. Type 1 is IPv4 and Type 2 is IPv6
    - C. Type 2 is encrypted
    - D. no difference

25. Why can an OSPF input route filter not create arbitrary different topologies for routers in the same area?
    - A. routers need a consistent area LSDB; rejecting local RIB installation does not selectively erase the LSA
    - B. OSPF uses TCP 179
    - C. filters only work on DHCP
    - D. Router IDs are VLAN tags

## Answer key and explanations

1. **B.** Specificity wins before distance across different prefix lengths.
2. **A.** Equal eligible paths for the same prefix can be installed as ECMP.
3. **A.** Higher distance keeps it inactive until preferred route fails.
4. **A.** Local gateway health is not end-to-end provider health.
5. **A.** It pins a remote test target to one underlay and resolves the logical default gateway.
6. **A.** Scope/target-scope controls recursive eligibility.
7. **A.** Useful when identical/link-local resolution contexts require interface qualification.
8. **A.** v7 tables are explicit; `fib` is needed for forwarding installation.
9. **A.** Choose behavior based on whether policy is strict or may fall back.
10. **A.** Exclude `dst-address-type=local` or deliberately change policy ordering.
11. **A.** `/31` provides exactly two addresses without broadcast semantics for supported P2P use.
12. **A.** EoIP is a Layer 2 pseudowire-like tunnel; IPIP is Layer 3.
13. **A.** Add IPsec or use an encrypted tunnel when needed.
14. **A, B, D.** EoIP does not inherently encrypt; routing limits failure scope.
15. **A.** The S-tag transports a customer C-tag; it is segmentation, not encryption.
16. **C.** Each 802.1Q/802.1ad tag is 4 bytes.
17. **A.** OSPF floods link state and runs SPF.
18. **C.** 2-Way means each Hello lists the other router.
19. **A.** DROthers do not need Full adjacency with each other on broadcast networks.
20. **A.** Also check duplicate IDs, type/auth/options and link stability.
21. **A.** Type 1 describes each router's local area links.
22. **A.** An ABR has area-boundary responsibility and backbone connectivity design.
23. **A.** NSSA translates Type 7 toward Type 5 at an appropriate ABR.
24. **A.** Type 1 accumulates internal cost; Type 2 external metric dominates.
25. **A.** OSPF's consistent LSDB is essential; use areas/summaries/redistribution policy.
