# Configuration Samples

These `.rsc` files are intentionally small building blocks for clean CHR labs. Read every line before importing. They assume RouterOS v7, no default configuration, console access, and interface names matching the Chapter 2 topology.

- `r1-static.rsc`, `r2-static.rsc`, `r3-static.rsc`: three-router static baseline.
- `r1-ospf.rsc`, `r2-ospf.rsc`, `r3-ospf.rsc`: OSPF replacement baseline.

Passwords, WAN Internet access, production firewall policy, Wi-Fi, and public addressing are deliberately excluded. Import with version-supported dry run first:

```routeros
/import file-name=r1-static.rsc verbose=yes dry-run=yes
```
