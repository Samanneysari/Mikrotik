# 10 — Operations, Monitoring and Basic Troubleshooting

A tool is useful only when you know what question it answers. Start with a hypothesis; select the least intrusive observation that can prove or disprove it.

## 1. The evidence ladder

1. **Scope:** one user, one VLAN, one site, or the whole network?
2. **Change:** what changed, when, and by whom?
3. **Layer 1:** link, rate/duplex, errors, optic/radio health.
4. **Layer 2:** bridge port, STP, VLAN, MAC learning.
5. **Layer 3:** address/mask, ARP/ND, route, return route.
6. **Policy:** raw/mangle/filter/NAT, IPsec, routing rule, queue.
7. **Service:** DHCP, DNS, PPP, OSPF/BGP/LDP state.
8. **Application:** socket/listener, TLS, credentials, server health.

## 2. Ping

```routeros
/ping 10.0.12.2 count=5 interval=500ms src-address=10.0.12.1
/ping 2001:db8:12::2 count=5
/ping 198.51.100.2 size=1472 do-not-fragment count=3
```

Choose source/VRF/interface deliberately in multi-address designs. A successful router-originated ping does not prove a forwarded client flow: it uses `output`, a router source address, and possibly a different policy path.

## 3. Traceroute

```routeros
/tool traceroute 203.0.113.80 src-address=192.0.2.1
```

Traceroute reveals responding hop boundaries through TTL expiration. Missing hops can mean filtering/rate limiting, not necessarily forwarding failure. The return path for ICMP responses also affects results.

## 4. Torch

```routeros
/tool torch interface=ether1 src-address=192.168.10.0/24
```

Torch summarizes live traffic by addresses, ports, protocol, VLAN, and rates. Use it to answer “does this traffic cross this interface, and at what rate?” It is not a full packet decoder. Running heavy monitoring on a busy router consumes resources.

## 5. Packet Sniffer

```routeros
/tool sniffer set filter-interface=ether2 filter-ip-address=192.168.10.20/32 \
    file-name=incident-001.pcap file-limit=20MiB
/tool sniffer start
# reproduce briefly
/tool sniffer stop
```

Capture near both sides of a suspected boundary. If the SYN appears on ingress but not egress, inspect RouterOS path/policy. If it leaves but no reply returns, investigate downstream/return path. Redact sensitive payloads before sharing captures.

## 6. Interface monitors and Traffic Monitor

```routeros
/interface monitor-traffic ether1 once
/interface ethernet monitor ether1 once
/interface ethernet print stats
```

`/tool traffic-monitor` can trigger scripts when traffic crosses thresholds. It is simple threshold automation, not a full telemetry platform; avoid flapping actions without hysteresis/cooldown.

## 7. CPU, memory, storage and health

```routeros
/system resource print
/tool profile cpu=all duration=10
/system health print
/file print
```

High CPU is a symptom. Profile identifies processes/features consuming time. Full storage can prevent logs, updates, captures, backups, or database writes. Temperature/voltage sensors and thresholds vary by device.

## 8. Logging

```routeros
/system logging print
/log print follow where topics~"firewall|ospf|bgp|dhcp"
```

Add targeted persistent/remote actions:

```routeros
/system logging action add name=remote-syslog target=remote remote=192.0.2.50 \
    remote-port=514
/system logging add topics=critical,error,warning action=remote-syslog
```

Use synchronized NTP so device and collector timestamps correlate. Plain syslog can expose data and be spoofed/lost; isolate/protect transport appropriate to your environment.

## 9. SNMP and graphs

SNMP exposes counters/status to a manager. Prefer SNMPv3 with authentication/privacy where supported by your monitoring stack. Restrict source and firewall access; never leave a default community on WAN.

```routeros
/snmp print
/tool graphing print
```

RouterOS graphing is convenient for small labs but adds storage/HTTP exposure. A central monitoring platform gives better retention, alerting, and correlation.

## 10. Netwatch

Netwatch observes a target and can run up/down/test scripts:

```routeros
/tool netwatch add name=branch-probe host=192.0.2.2 interval=30s timeout=2s \
    down-script=":log warning \"branch probe down\"" \
    up-script=":log info \"branch probe recovered\""
```

One failed ping does not prove a site is down. Select probes, test types, intervals, timeouts, and actions to avoid false remediation. Script permissions are deliberately constrained; test under the actual execution context.

## 11. E-mail

RouterOS can send mail for simple notifications after SMTP/TLS configuration. Treat SMTP credentials as secrets and prefer a monitored alerting platform for critical systems. Validate DNS, time, certificate trust, firewall, and server policy separately.

## 12. The Dude

The Dude is MikroTik's network monitoring/mapping system. Know its role: device discovery, maps, probes, status, charts, and notifications. Discovery is a starting point, not an approved inventory; broad scans can be intrusive. The server package/platform and feature availability must match current MikroTik guidance.

## 13. Support output and readable configuration

```routeros
/system sup-output name=incident-001
/export show-sensitive=no file=incident-001
/log print file=incident-001-log
```

Add comments to interfaces, routes, firewall rules, queues, and peers. Keep an external diagram and address plan. `supout.rif` is for deep support analysis and may contain sensitive operational context.

## 14. Incident mini-example

Symptom: “Internet is slow.”

Bad response: reboot immediately.

Evidence-driven response:

1. define affected users/time/application;
2. check interface errors/rate and CPU/profile;
3. compare latency/loss to gateway, provider next hop, and remote IP;
4. inspect Torch for saturation/top talkers;
5. inspect queue drops/rates and FastTrack;
6. check DNS separately;
7. capture only if needed;
8. change one variable with rollback;
9. verify user outcome and record root cause.

## MTCNA operations checkpoint

Given an unknown failure, produce an evidence bundle containing:

- topology and scope;
- resource/interface status;
- relevant addresses/routes/ARP;
- firewall/NAT/queue counters;
- service/protocol state and logs;
- a focused capture if necessary;
- root cause, fix, verification, and rollback.
