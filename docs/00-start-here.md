# 00 — Start Here

## The destination

At the end of this book, you should not merely recognize RouterOS menu names. Given a blank router and a written requirement, you should be able to:

- turn requirements into an address, VLAN, routing, firewall, and monitoring plan;
- configure the plan in WinBox or CLI without locking yourself out;
- predict which packet-flow stages a packet will cross;
- prove that forwarding, routing policy, OSPF, BGP, or MPLS is working;
- isolate a fault to physical, Layer 2, Layer 3, policy, service, or application scope;
- recover from a broken change using Safe Mode, export, backup, serial access, or Netinstall;
- explain *why* every configuration line exists.

Passing an exam and operating a network overlap, but they are not identical. The certification asks whether you understand defined objectives. Operations asks whether you can handle incomplete information and avoid making an outage worse. This book trains both.

## Correct certification names

MikroTik currently lists this progression:

| Level | Official course | Meaning | Official prerequisite |
|---|---|---|---|
| Basic | MTCNA | MikroTik Certified Network Associate | TCP/IP and subnetting knowledge |
| Advanced | MTCRE | MikroTik Certified Routing Engineer | An MTCNA certificate |
| Extended | MTCINE | MikroTik Certified Inter-Networking Engineer | MTCNA and MTCRE certificates |

`MTCNA+` in this repository is not a MikroTik certificate. It is a practical bridge containing VLAN filtering, production hardening, WireGuard/IPsec choices, automation, change control, and recovery—skills a junior engineer needs even when they fall outside an old exam outline.

## The learning loop

For each topic, use this five-step loop:

1. **Predict** — Before typing, say what routes, ARP entries, firewall counters, or neighbor states you expect.
2. **Build** — Configure the smallest working version.
3. **Observe** — Use `print detail`, counters, logs, Torch, Packet Sniffer, or protocol status.
4. **Break** — Introduce one deliberate fault: wrong mask, missing bridge port, bad area, wrong AS, blocked protocol.
5. **Repair and explain** — Fix it and write one sentence naming the evidence that located the fault.

If you only copy commands, you are rehearsing typing. If you predict and verify, you are learning networking.

## How RouterOS configuration should be read

RouterOS is organized as a tree of menus. Consider:

```routeros
/ip address add address=192.0.2.1/30 interface=ether2 comment="R1-to-R2"
```

Read it from left to right:

- `/ip address` — the menu containing IPv4 address objects;
- `add` — create a new object;
- `address=192.0.2.1/30` — assign an IPv4 address and prefix length;
- `interface=ether2` — bind the address to that interface;
- `comment="R1-to-R2"` — record intent.

The WinBox equivalent is **IP → Addresses → +**. WinBox is not a separate operating system: it edits the same object. After making a GUI change, `/system history print detail` can show the CLI action RouterOS recorded.

## Safety rules from the first lab onward

> [!WARNING]
> A router configuration can interrupt connectivity, leak routes, expose management services, or create a Layer 2 loop. Use an isolated lab before production.

- Never run an unknown script on a production device.
- Enter Safe Mode before changing management IPs, bridges, VLAN filtering, routes, or firewall input rules.
- Keep an independent recovery path: serial console, out-of-band port, hypervisor console, or a person on site.
- Use `/export show-sensitive=no` for review and version control. Encrypted binary backups are for restoration, not readable auditing.
- Put an explicit comment on every non-obvious rule.
- Add deny rules only after the necessary accept rules and test counters first.
- Do not use public addresses in labs. This book uses RFC 5737 documentation ranges, RFC 1918 private ranges, and private ASNs.
- Do not treat PPTP as secure. It appears because the old official outline names it; use WireGuard, IKEv2/IPsec, or SSTP with a proper trust model for modern deployments.

## Checkpoint: are you ready for Chapter 1?

Answer these aloud:

1. Why does this book include material outside official course outlines?
2. What is the difference between a binary backup and a text export?
3. What evidence would prove a NAT rule is matching?
4. Why should you deliberately break a working lab?
5. What recovery path remains if your management IP stops responding?

If any answer is vague, reread the relevant paragraph. Precision now prevents confusion in advanced chapters.
