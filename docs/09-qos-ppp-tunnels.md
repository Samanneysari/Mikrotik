# 09 — QoS, PPP, PPPoE and Tunnels

## Part A — Queuing and QoS

### 1. What a queue can and cannot do

A queue controls packets at a point where RouterOS can delay/drop them. It cannot create bandwidth. Congestion must occur at, or be shaped slightly below, the queue's controllable egress; otherwise an upstream device drops packets before RouterOS can schedule them.

Terms:

- **bandwidth**: capacity in bits per second;
- **latency**: time for delivery;
- **jitter**: variation in latency;
- **loss**: packets not delivered;
- **shaping**: delay packets to enforce a rate;
- **policing**: drop/remark traffic exceeding policy;
- **classification**: decide which traffic belongs to which class;
- **scheduling**: decide which queued packet goes next.

### 2. Simple Queue

Limit one client to 20 Mbps down and 5 Mbps up:

```routeros
/queue simple add name="client-20" target=192.168.10.20/32 \
    max-limit=5M/20M comment="upload/download cap"
```

In Simple Queue, the paired rates are upload/download from the target's perspective. Verify with real bidirectional traffic and queue counters rather than assuming orientation.

```routeros
/queue simple print stats detail where name="client-20"
```

- `target`: address/interface whose traffic is classified;
- `max-limit`: maximum rate the queue may deliver;
- `limit-at`: committed rate RouterOS tries to provide when parent capacity exists;
- `priority`: scheduling preference among queues that can compete under a parent; it is not a magic bandwidth reservation;
- `burst-*`: temporary rate behavior calculated over time, requiring all parameters to be internally consistent.

### 3. Hierarchical example

Assume a measured 100/100 Mbps WAN. Shape to 95/95 so RouterOS, not the modem, becomes the bottleneck:

```routeros
/queue simple
add name="TOTAL-WAN" target=192.168.10.0/24 max-limit=95M/95M
add name="VOICE" parent="TOTAL-WAN" target=192.168.10.0/28 \
    limit-at=10M/10M max-limit=30M/30M priority=1/1
add name="USERS" parent="TOTAL-WAN" target=192.168.10.16/28 \
    limit-at=20M/20M max-limit=80M/80M priority=5/5
```

The sum of guaranteed `limit-at` values should fit within the parent's real capacity. Priorities matter when children compete; when capacity is idle, a child may use up to `max-limit`.

### 4. PCQ fairness

Per Connection Queue (PCQ) hashes selected fields into substreams, commonly giving many clients a fair share without a Simple Queue per client.

```routeros
/queue type
add name=pcq-upload-kind kind=pcq pcq-classifier=src-address pcq-rate=0
add name=pcq-download-kind kind=pcq pcq-classifier=dst-address pcq-rate=0
/queue simple add name="fair-lan" target=192.168.10.0/24 max-limit=95M/95M \
    queue=pcq-upload-kind/pcq-download-kind
```

- upload separates by client source address;
- download separates by client destination address;
- `pcq-rate=0` lets active substreams share available parent capacity; a nonzero value caps each substream;
- `pcq-limit` and `pcq-total-limit` control buffers, which affect loss/latency/memory.

### 5. FastTrack interaction

FastTracked flows can bypass queue processing. If counters stay zero:

1. disable the FastTrack rule temporarily;
2. clear/restart the test connection;
3. verify queue target/parent/direction;
4. confirm traffic actually crosses the router and bottleneck.

Do not keep adding queues until you understand why the first one did not match.

## Part B — PPP model

PPP-based services reuse several objects:

| Object | Purpose |
|---|---|
| `/ppp profile` | reusable addresses, DNS, encryption/service policy, scripts, limits |
| `/ppp secret` | local username/password and profile |
| `/ppp active` | current sessions |
| `/ip pool` | reusable remote address range |
| interface client/server | transport-specific endpoint |

### Reusable remote-access pool/profile

```routeros
/ip pool add name=pool-remote ranges=10.200.10.10-10.200.10.100
/ppp profile add name=prof-remote local-address=10.200.10.1 \
    remote-address=pool-remote dns-server=10.200.10.1 only-one=yes
/ppp secret add name=student service=any profile=prof-remote password="LAB-ONLY-SECRET"
```

The router uses `local-address`; the client receives an address from `remote-address`. The secret selects the profile. Use RADIUS/AAA for scalable identity instead of copying shared local accounts.

## Part C — PPPoE

PPPoE carries PPP sessions over Ethernet and is common in access networks. It adds overhead, typically reducing IP MTU from 1500 to 1492 unless the path supports larger frames.

### PPPoE client

```routeros
/interface pppoe-client add name=pppoe-wan interface=ether1 user="LABUSER" \
    password="LABPASS" add-default-route=yes default-route-distance=1 \
    use-peer-dns=no disabled=no
/interface pppoe-client monitor pppoe-wan once
```

The underlying Ethernet port should not simultaneously have an unintended DHCP client. Verify session status, assigned address, negotiated MTU/MRU, route, and logs.

### PPPoE access concentrator lab

```routeros
/ip pool add name=pool-pppoe ranges=10.50.0.10-10.50.0.200
/ppp profile add name=prof-pppoe local-address=10.50.0.1 remote-address=pool-pppoe \
    dns-server=10.50.0.1 rate-limit=10M/20M
/ppp secret add name=cpe01 service=pppoe profile=prof-pppoe password="LABPASS"
/interface pppoe-server server add interface=ether2 service-name=LAB-AC \
    default-profile=prof-pppoe authentication=pap,chap,mschap1,mschap2 disabled=no
```

For real deployments, choose authentication and encryption policies deliberately, integrate AAA/accounting, limit discovery scope, plan MTU, and protect the service from abuse.

## Part D — Tunnel taxonomy

| Tunnel | Carries | Encryption by itself? | Typical note |
|---|---|---:|---|
| IPIP/GRE | Layer 3 | No | simple site transport; often protected with IPsec |
| EoIP | Layer 2 Ethernet | No | MikroTik-specific; extends broadcast domain |
| VLAN/QinQ | Layer 2 tags | No | segmentation/transport, not secrecy |
| L2TP | PPP over IP | Not sufficient alone | commonly paired with IPsec |
| SSTP | PPP over TLS | Yes when trust is correct | TCP-over-TCP trade-offs |
| PPTP | PPP/GRE | Cryptographically obsolete | exam awareness only; do not deploy |
| WireGuard | Layer 3 | Yes | modern, small operational surface |
| IPsec/IKEv2 | Layer 3 policy/tunnel | Yes | powerful interoperable suite |

Encapsulation adds headers. Calculate path MTU and MSS behavior rather than hoping applications adapt.

### IPIP lab

Public/underlay endpoints: R1 `198.51.100.1`, R2 `198.51.100.2`.

R1:

```routeros
/interface ipip add name=ipip-r1-r2 local-address=198.51.100.1 \
    remote-address=198.51.100.2 clamp-tcp-mss=yes
/ip address add address=10.99.12.1/30 interface=ipip-r1-r2
/ip route add dst-address=192.168.30.0/24 gateway=10.99.12.2
```

R2 uses reversed endpoints and `10.99.12.2/30`, plus a return route. This provides no confidentiality or peer authentication. Protect the underlay with IPsec or choose an encrypted tunnel.

### EoIP warning

EoIP can bridge two remote Ethernet domains, but it also transports broadcasts, loops, and failures. Use unique tunnel IDs, plan MTU, apply split horizon/STP, and prefer routed boundaries when Layer 2 extension is not truly required.

### PPTP and SSTP exam context

The official MTCNA/MTCRE outlines name PPTP and SSTP. Know their client/server/profile/pool model and status views. PPTP's security is obsolete; do not recommend it. SSTP security depends on certificate validation and a sound TLS/AAA design—not merely enabling a server checkbox.

## Checkpoint lab

1. Apply Simple Queue and PCQ policies and prove rate/fairness with counters.
2. Demonstrate that FastTrack changes queue observation.
3. Build a PPPoE client/server pair and inspect active sessions/routes/MTU.
4. Build IPIP between two routers, route one LAN each way, then reduce underlay MTU and diagnose a large-packet failure.
5. Explain why EoIP and PPTP would not be your default modern site-to-site choices.
