# Tools Menu

Combined sections below include **Tools → SSH**, **Tools → MAC Server**,
**Tools → Traffic Generator**, and **Tools → Ping Speed**.

Tools answer diagnostic or operational questions. Select source interface,
address and VRF deliberately; router-originated results do not automatically
prove a forwarded client flow.

## Tools → Ping

**Purpose:** test IP reachability, delay and loss.

The window includes target Address, Count, Interval, Packet Size, TTL, timeout,
DF/do-not-fragment, Interface, Source Address, routing table/VRF and protocol
options. **Start/Stop** controls the test; result rows show sequence, host, size,
TTL, time and loss summary.

Start with next hop, then remote IP; set source to the affected subnet. Increase
size with DF for MTU diagnosis. A successful router ping uses output policy and
does not prove client forwarding/input policy.

## Tools → Traceroute

**Purpose:** identify responding routed hop boundaries using TTL/hop limit.

Fields include Address, protocol (ICMP/UDP as supported), port, source,
interface, routing table/VRF, packet size, timeout, count and maximum hops.
Rows show hop address, loss and latency samples. A blank hop can be ICMP
filter/rate limiting; it is not automatic proof the hop dropped transit traffic.

## Tools → IP Scan

**Purpose:** actively scan an IPv4 prefix/range on a selected interface and list
responding hosts. Use it to discover lab/owned-network hosts, verify address use
or locate a device when its exact address is unknown.

**What opens:**

- `Interface` — Layer 2/routed interface from which discovery traffic is sent;
- `Address Range` — target IPv4 range/prefix, for example
  `192.168.88.1-192.168.88.254` or a supported prefix form;
- optional source/timeout controls depending on RouterOS/WinBox build;
- **Start** and **Stop**;
- result table containing Address, MAC Address, DNS/NetBIOS/SNMP-derived name or
  related identity fields where a target exposes them.

**How to use it safely:**

1. Confirm written authorization and the exact subnet; a scan is active traffic.
2. Select the interface attached to or routing toward that subnet.
3. Enter the smallest required range—not `0.0.0.0/0`.
4. Click **Start** and allow one pass; stop when the required host is found.
5. Correlate results with **IP → ARP**, DHCP Leases, Bridge Hosts and approved
   inventory. No response does not prove an address is unused; a host/firewall
   may ignore probes.

CLI equivalent: `/tool ip-scan interface=br-lan address-range=192.168.88.0/24`.
Scanning networks you do not own/administer may violate policy or law.

## Tools → MAC Scan

Scans MikroTik MAC-layer responses on a local interface. Select Interface and
Start; results show MAC and identity where available. It does not cross routers
and should be restricted by MAC-server/interface-list policy.

## Tools → Neighbor Discovery

Displays local discovery information and relates to IP → Neighbors. Select the
proper interface/list and protocol. Discovery advertisements can expose device
identity/version; restrict them to management networks.

## Tools → Torch

**Purpose:** summarize live traffic crossing one interface.

Select Interface and optional source/destination address, MAC, VLAN, protocol,
port and DSCP filters; Start/Stop. Results group Tx/Rx rates, packets, addresses,
ports and protocol. Torch is excellent for “does this flow cross here and at
what rate?” but is not a full packet decoder and can add CPU load.

## Tools → Packet Sniffer

**Settings** choose Interface, direction, memory/file streaming, file name/limit,
packet limit/size, filter MAC/IP/protocol/ports/VLAN and streaming server.
**Start/Stop/Packets** control capture and inspection; save PCAP for Wireshark.

Capture briefly on both sides of a boundary. Check free storage. PCAP payloads
may contain credentials/customer data; sanitize and protect them.

## Tools → Packet Sniffer → Quick

Starts an immediate filtered live capture table. Set the narrowest interface/
protocol/address/port filter before running on a busy router. It is volatile
observation; use file/stream capture for offline decoding.

## Tools → Bandwidth Test

Generates traffic to a RouterOS bandwidth-test server. Fields include target,
protocol TCP/UDP, direction, user/password, local/remote Tx size, random data,
connection count and bandwidth limit. Results show Tx/Rx throughput, loss and
CPU.

This is intrusive and can saturate links/CPU; test only during an approved
window between owned endpoints. It measures generated path capacity, not normal
application quality. Configure/secure **Bandwidth Server** separately.

## Tools → Bandwidth Server

Enables the server, authentication and session limits. Restrict it by input
firewall and disable when unused. Never expose an unauthenticated traffic
generator to WAN.

## Tools → Profile

**Purpose:** attribute CPU time to RouterOS process groups.

Select CPU (`all` or a core) and Start/Stop; rows show process and percentage.
Use during the symptom and correlate firewall, networking, management, queueing
or encryption load. Profile itself adds observation overhead; process names are
functional groups, not individual rules.

## Tools → Netwatch

Click **+** and configure Name, Host, Type (simple/ICMP/TCP/HTTP/HTTPS/DNS as
available), Interval, Timeout, source/VRF and type-specific thresholds. Script
tabs contain Up, Down and Test scripts; Status shows state, since, loss/RTT and
last test.

One probe is not universal service health. Add hysteresis/cooldown and constrained
script permissions; avoid two Netwatch entries fighting over a route.

## Tools → Traffic Monitor

Creates threshold triggers for traffic rate on an interface/direction. Fields
include Interface, Traffic direction, Trigger (`above`/`below`), Threshold,
On Event and comment. It is simple threshold automation, not historical
telemetry; design cooldown to prevent flapping scripts.

## Tools → Graphing

**Interface Rules**, **Queue Rules** and **Resource Rules** select what RouterOS
stores/serves, allowed client addresses and collection interval. Graphing adds
storage/HTTP exposure and limited retention; central monitoring is preferable
for production. Restrict access and verify time/disk usage.

## Tools → Netwatch, SNMP and Dude relationships

Netwatch performs local probes/actions; SNMP exports state; The Dude discovers,
maps and polls networks. They solve different problems. Do not use discovery as
approved inventory or a reboot script as the first alert response.

## Tools → Fetch

Transfers HTTP/HTTPS/FTP/SFTP resources or sends HTTP requests. Fields include
URL/address, mode/method, source/VRF, destination/file, headers/body, user/
password, certificate checking, timeout and output mode. Treat downloaded scripts
as untrusted, verify TLS and never put secrets in URLs/logged commands.

## Tools → E-mail

Global settings define SMTP Server/Port, TLS mode, From, User/Password and VRF.
The Send form sets To/CC, Subject, Body and attachment. Verify DNS, time, CA
trust, firewall and provider authentication. Store credentials as secrets and
use a monitored alert platform for critical delivery.

## Tools → SMS

On supported modem/serial hardware, Send SMS selects port/channel, destination,
message and encoding; Inbox/Status may show received messages. Phone/SMS is not
a trusted command channel without explicit sender/content controls. Hardware
and package dependent.

## Tools → Telnet and SSH

Router-originated terminal clients take Address, Port, User, source/VRF and
protocol settings. Use SSH with host-key verification where available; Telnet
is clear text and suitable only for an isolated legacy test. Do not paste
credentials into captured/logged sessions.

## Tools → MAC Telnet and MAC Server

MAC Telnet is local-Layer-2 management. MAC Server settings choose allowed
interface list for MAC Telnet and MAC WinBox, plus ping response. Restrict to
MGMT; it bypasses routed segmentation expectations and does not cross routers.

## Tools → RoMON

Enables Router Management Overlay Network and configures ID, secret, enabled
state and Ports (interface, forbid, cost, secret). The discovery/route view
shows overlay neighbors/paths. Restrict participating ports, use secrets and do
not treat RoMON as encryption or authorization replacement.

## Tools → Wake on LAN

Sends a magic packet to MAC Address through Interface. It works only when the
target NIC/power/network supports WOL and the Layer 2 path carries the frame.
It does not prove the OS or application booted.

## Tools → Flood Ping and Traffic Generator

High-rate diagnostics generate aggressive traffic and may be restricted by
device mode. Set exact target, size/rate/count/interface and run only in an
isolated authorized lab. They can cause denial of service and are not ordinary
reachability tests.

## Tools → Speed Test and Ping Speed

Where present, Speed Test combines ping/jitter/loss with bandwidth tests against
a compatible server; Ping Speed sends repeated probes to estimate response rate.
Define target/source/VRF/direction and cap test bandwidth. Results are bounded by
endpoint CPU and test protocol, not only link capacity.

## Tools → Cable Test

On supported Ethernet PHYs, select an interface and run Cable Test to estimate
pair status/distance (open/short) and link state. Results are approximate and
model-dependent; disconnect/maintenance may be required. It cannot certify a
cabling installation.

## Tools → Spectral Scan / Snooper / Frequency Usage

Wireless-package/hardware-dependent RF observation. Select radio, band/range,
duration and channel width. Results show energy/utilization or observed networks;
running a scan can interrupt service on that radio. Configure the truthful
regulatory country and use during an approved window.
