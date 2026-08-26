# MTCNA Practice Exam 01

Choose one answer unless the question says **choose all that apply**.

## Questions

1. What is the network address of `172.16.8.77/27`?
   - A. `172.16.8.32`
   - B. `172.16.8.64`
   - C. `172.16.8.77`
   - D. `172.16.8.96`

2. A PC sends an IP packet to a server across three routers. Which value normally changes at every routed Ethernet hop?
   - A. destination TCP port
   - B. destination IP address
   - C. source and destination MAC addresses
   - D. application URL

3. When is MAC-WinBox most useful?
   - A. managing a router across the public Internet
   - B. initial local access when no usable IP configuration exists
   - C. replacing all routed management permanently
   - D. encrypting user traffic

4. What is Safe Mode designed to do?
   - A. encrypt a binary backup
   - B. block all configuration changes
   - C. roll back floating changes if the management session terminates abnormally
   - D. validate a firewall against the official outline

5. Which statement about export and backup is correct?
   - A. an export is a readable configuration; a binary backup is mainly for restoration
   - B. they are byte-for-byte identical
   - C. a binary backup never contains sensitive state
   - D. an export always contains every private key

6. What is the normal DHCPv4 message order?
   - A. Request, Discover, Acknowledge, Offer
   - B. Discover, Offer, Request, Acknowledge
   - C. Offer, Acknowledge, Discover, Request
   - D. Discover, Request, Offer, Acknowledge

7. Which RouterOS DHCP object defines the dynamic address range?
   - A. `/ip dhcp-server network`
   - B. `/ip pool`
   - C. `/ip arp`
   - D. `/ip dns static`

8. `ether2`–`ether5` are members of `br-lan`. Where should the single LAN gateway address normally be assigned?
   - A. all four physical ports
   - B. only the lowest-numbered port
   - C. `br-lan`
   - D. the WAN interface

9. What problem does RSTP primarily address?
   - A. IP exhaustion
   - B. Layer 2 loops
   - C. DNS recursion
   - D. BGP policy

10. A VLAN interface with `vlan-id=20` on `ether2` does what by itself?
    - A. terminates VLAN 20 tags at RouterOS on that parent
    - B. configures every connected switch automatically
    - C. makes all bridge ports VLAN 20 access ports
    - D. encrypts VLAN 20

11. Routes exist for `0.0.0.0/0`, `10.0.0.0/8`, and `10.20.30.0/24`. Which matches `10.20.30.44`?
    - A. default because it has distance 1
    - B. `/8` because it was added first
    - C. `/24` because it is most specific
    - D. all are ignored

12. R1 has a route to R2's LAN, but R2 has no route back to R1's LAN. What is the most likely symptom?
    - A. ARP on R1's local LAN stops existing
    - B. request can arrive, but the reply cannot return correctly
    - C. RouterOS automatically creates the missing route
    - D. DNS changes both route tables

13. Which filter chain handles a new SSH connection addressed to the router itself?
    - A. `input`
    - B. `forward`
    - C. `srcnat`
    - D. `postrouting`

14. Which connection states are commonly accepted early to permit return traffic? **Choose all that apply.**
    - A. established
    - B. related
    - C. invalid
    - D. untracked when intentionally used

15. When is `action=masquerade` usually preferred over a fixed `src-nat` address?
    - A. when the egress address changes dynamically
    - B. when no connection tracking exists
    - C. for OSPF Hellos
    - D. to create a VLAN

16. A WAN HTTPS packet is dst-NATed to `192.168.20.50`. Which filter chain normally decides whether it may cross to the server?
    - A. input
    - B. forward
    - C. output only
    - D. ARP

17. Why can FastTrack surprise a QoS lab?
    - A. it converts TCP to UDP
    - B. eligible flows can bypass parts of normal queue/processing paths
    - C. it disables Ethernet auto-negotiation
    - D. it changes the DHCP pool

18. In a Simple Queue targeting a client, what does `max-limit` express?
    - A. guaranteed minimum storage
    - B. maximum allowed rate in the configured directions
    - C. OSPF cost
    - D. lease time

19. For PCQ fairness among clients, which classifiers are commonly used?
    - A. source address for upload and destination address for download
    - B. TTL only
    - C. source MAC for all routed Internet paths
    - D. BGP AS path

20. What selects reusable local/remote address and service settings for a PPP user?
    - A. bridge host table
    - B. PPP profile referenced by the secret/AAA result
    - C. DNS cache
    - D. VLAN PVID

21. Why does PPPoE commonly require MTU attention?
    - A. PPPoE adds encapsulation overhead
    - B. PPPoE removes IP headers
    - C. PPPoE always requires jumbo frames
    - D. PPPoE is an OSPF area

22. Which statement about PPTP is correct today?
    - A. it is the preferred secure modern VPN
    - B. it is legacy/insecure; know it for outline awareness but do not deploy it as secure
    - C. it is identical to WireGuard
    - D. it is a VLAN protocol

23. Why must the Wi-Fi country/regulatory setting match the real location?
    - A. it controls legal channel/power behavior
    - B. it chooses the BGP ASN
    - C. it replaces WPA authentication
    - D. it increases Ethernet L2MTU

24. Which tool best summarizes live conversations/rates crossing one interface without decoding every packet?
    - A. Torch
    - B. Netinstall
    - C. binary backup
    - D. RouterBOOT upgrade

25. A DHCP client has `169.254.20.9`; no lease exists; its Discover is visible on the access port but not on the VLAN interface. Where should you investigate first?
    - A. BGP LOCAL_PREF
    - B. Layer 2 VLAN/bridge membership and PVID
    - C. Internet source NAT
    - D. remote website TLS

## Answer key and explanations

1. **B.** `/27` blocks are 32; 77 lies in 64–95.
2. **C.** Routers rebuild Layer 2 headers; IP endpoints normally remain unless NAT acts.
3. **B.** It is local Layer 2 recovery/initial access, not a routable management strategy.
4. **C.** Abnormal session loss rolls floating changes back; release Safe Mode to commit.
5. **A.** Exports are reviewable text; backups are protected restore artifacts.
6. **B.** Discover, Offer, Request, Acknowledge (DORA).
7. **B.** Pool defines ranges; network objects define options; server binds service/interface.
8. **C.** The bridge is the Layer 3 attachment for its combined ports.
9. **B.** RSTP blocks redundant Layer 2 paths while retaining failover.
10. **A.** Other switch/bridge membership remains a separate configuration.
11. **C.** Longest-prefix match precedes distance comparison among same-prefix candidates.
12. **B.** End-to-end communication requires a valid return path.
13. **A.** Destination is a local router process.
14. **A, B, D.** Invalid is normally dropped; deliberate untracked traffic needs explicit handling.
15. **A.** Masquerade tracks changing egress addresses/link events; fixed src-nat is clearer for stable addresses.
16. **B.** After dst-NAT/routing, traffic crossing the router traverses forward.
17. **B.** Disable/exclude FastTrack when the design requires queue/mark/accounting paths.
18. **B.** It caps service rate; `limit-at` is the committed-rate concept.
19. **A.** Those fields normally separate each target client in the two directions.
20. **B.** The profile centralizes PPP session properties.
21. **A.** Encapsulation reduces available payload MTU unless the lower layer accommodates it.
22. **B.** PPTP is maintained here only as legacy objective knowledge.
23. **A.** Spectrum use is regulated; more power is not automatically better or legal.
24. **A.** Torch is the live flow/rate summarizer; Sniffer is for packet detail.
25. **B.** DHCP broadcast delivery fails before Layer 3/NAT; fix the first broken boundary.
