# 03 — RouterOS, RouterBOARD and First Access

## RouterOS versus RouterBOARD

**RouterOS** is MikroTik's network operating system. **RouterBOARD** refers to MikroTik hardware platforms. CHR is RouterOS packaged for virtual infrastructure. A router's available menus and performance depend on RouterOS version, architecture, packages, license, and hardware features.

Start every unfamiliar device with an inventory:

```routeros
/system resource print
/system package print
/system license print
/system routerboard print
/interface print detail
/ip address print detail
/ip route print detail
/export show-sensitive=no
```

Do not reset first. The existing configuration may contain the only management path, provider parameters, or device-specific defaults.

## Physical first contact

For a typical small device with factory defaults:

1. Read its Quick Guide; port defaults vary.
2. Connect the ISP to the documented WAN port, commonly `ether1`.
3. Connect your PC to a documented LAN port.
4. Disable the PC's Wi-Fi/VPN temporarily if route selection is confusing.
5. Obtain an address by DHCP and check the gateway.
6. Open WinBox and inspect **Neighbors**.

Many devices use `192.168.88.1` on the LAN by default, but never assume it without checking the model's documentation or neighbor discovery.

## IP access versus MAC access

WinBox can connect by IP or, on a local Layer 2 path, by MAC address.

- Prefer IP for normal administration: it is routable, observable, and more reliable.
- MAC-WinBox is valuable before IP configuration or after an IP mistake.
- MAC access depends on Layer 2 discovery/broadcast behavior and should not be exposed on untrusted ports.
- RoMON can provide RouterOS overlay management reachability through another RouterOS device; secure and scope it deliberately.

Inspect and restrict MAC services and discovery:

```routeros
/interface list add name=MGMT
/interface list member add list=MGMT interface=ether2
/tool mac-server set allowed-interface-list=MGMT
/tool mac-server mac-winbox set allowed-interface-list=MGMT
/ip neighbor discovery-settings set discover-interface-list=MGMT
```

This example permits discovery/MAC tools only on interfaces in `MGMT`. Do not add an Internet-facing interface to that list.

## Management choices

| Method | Use | Security/operational note |
|---|---|---|
| WinBox | full GUI | prefer IP; keep client current |
| WebFig | browser GUI | enable HTTPS with a trusted plan; restrict source |
| SSH | CLI and automation | use modern crypto/key auth where possible; restrict source |
| Serial/console | recovery/out-of-band | physical or hypervisor access |
| API/REST | automation | dedicated least-privilege account and TLS/network restriction |
| Telnet/FTP/HTTP | legacy | disable unless an isolated, justified use exists |

Quick Set is useful for supported simple scenarios but can create or replace multiple related objects. Do not mix repeated Quick Set changes with a carefully hand-built production design unless you understand the generated configuration.

## The default configuration decision

When WinBox offers to keep or remove defaults:

- a beginner with a home/small-office device should normally inspect and keep the secure baseline;
- an engineer building a controlled design may start clean, but must add management protection before exposing WAN;
- exporting first records what the device-specific defaults did.

On an isolated lab only:

```routeros
/system reset-configuration no-defaults=yes skip-backup=yes
```

On production, schedule this as a destructive rebuild with local recovery—not an exploratory command.

## First clean Internet configuration

Scenario:

- `ether1` receives WAN configuration by DHCP;
- `ether2`–`ether5` form the LAN;
- LAN is `192.168.10.0/24`;
- router is `.1` and leases `.100–.199`;
- clients share the changing WAN address.

### 1. Create interface roles

```routeros
/interface list
add name=WAN comment="untrusted uplinks"
add name=LAN comment="trusted client-facing interfaces"
```

Interface lists make policy follow roles rather than fragile port names.

### 2. Build the LAN bridge

```routeros
/interface bridge add name=br-lan protocol-mode=rstp comment="main LAN bridge"
/interface bridge port
add bridge=br-lan interface=ether2
add bridge=br-lan interface=ether3
add bridge=br-lan interface=ether4
add bridge=br-lan interface=ether5
/interface list member
add list=WAN interface=ether1
add list=LAN interface=br-lan
```

The IP address belongs on `br-lan`, not separately on each member port. The bridge is the Layer 3 attachment for the combined Layer 2 LAN.

### 3. Obtain WAN configuration

```routeros
/ip dhcp-client add interface=ether1 add-default-route=yes use-peer-dns=no disabled=no
```

`use-peer-dns=no` prevents an unknown upstream DNS assignment from silently replacing your resolver plan. In a simple lab you may choose `yes`; know the implication.

### 4. Address the LAN and provide DHCP

```routeros
/ip address add address=192.168.10.1/24 interface=br-lan comment="LAN gateway"
/ip pool add name=pool-lan ranges=192.168.10.100-192.168.10.199
/ip dhcp-server add name=dhcp-lan interface=br-lan address-pool=pool-lan lease-time=8h disabled=no
/ip dhcp-server network add address=192.168.10.0/24 gateway=192.168.10.1 \
    dns-server=192.168.10.1 domain=lab.example
/ip dns set allow-remote-requests=yes servers=1.1.1.1,9.9.9.9
```

Allowing remote DNS requests makes the router a resolver for reachable clients. The firewall must prevent untrusted interfaces from querying it.

### 5. Add NAT and a minimum firewall

```routeros
/ip firewall nat add chain=srcnat out-interface-list=WAN action=masquerade \
    comment="LAN Internet source NAT"

/ip firewall filter
add chain=input action=accept connection-state=established,related,untracked \
    comment="input: keep valid existing flows"
add chain=input action=drop connection-state=invalid comment="input: drop invalid"
add chain=input action=accept protocol=icmp comment="input: diagnostics"
add chain=input action=accept in-interface-list=LAN comment="input: manage/services from LAN"
add chain=input action=drop comment="input: default deny"
add chain=forward action=fasttrack-connection connection-state=established,related \
    hw-offload=yes comment="forward: FastTrack eligible established flows"
add chain=forward action=accept connection-state=established,related,untracked \
    comment="forward: keep valid existing flows"
add chain=forward action=drop connection-state=invalid comment="forward: drop invalid"
add chain=forward action=drop connection-state=new connection-nat-state=!dstnat \
    in-interface-list=WAN comment="forward: block unsolicited WAN"
add chain=forward action=accept in-interface-list=LAN out-interface-list=WAN \
    comment="forward: LAN to Internet"
add chain=forward action=drop comment="forward: default deny"
```

Rule order is behavior. The final drops deny anything not explicitly accepted. Apply in Safe Mode and keep local recovery. FastTrack bypasses parts of the normal processing path; later QoS, IPsec, policy routing, or accounting designs may require excluding or disabling it.

### 6. Verify layer by layer

```routeros
/interface print
/ip dhcp-client print detail
/ip address print
/ip route print where active
/ip dhcp-server lease print
/ip firewall filter print stats
/ip firewall nat print stats
/ping 1.1.1.1 src-address=192.168.10.1
/resolve example.com
```

Client verification order:

1. client has address, mask, gateway, DNS;
2. ping `192.168.10.1`;
3. router and client ARP tables contain each other;
4. ping a public IP;
5. resolve a DNS name;
6. open HTTPS;
7. inspect firewall/NAT counters.

## Users, identity and services

```routeros
/system identity set name=EDGE-01
/user add name=ops group=full password="REPLACE-ME"
/user disable admin
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/ip service set ssh address=192.168.10.0/24
/ip service set winbox address=192.168.10.0/24
```

Use named accounts so history and logs show who changed what. Built-in groups may grant more rights than a role needs; production designs should create least-privilege groups and use AAA where appropriate.

## Packages, RouterOS and RouterBOOT

RouterOS packages provide features. Extra packages should match the exact RouterOS version and architecture. Random or mismatched packages can prevent a feature from loading or consume scarce storage.

Upgrade workflow:

```routeros
/system package update check-for-updates
/system package update print
# after change approval and backups:
/system package update download
# inspect, then schedule reboot
```

After RouterOS boots successfully, inspect RouterBOOT:

```routeros
/system routerboard print
/system routerboard upgrade
/system reboot
```

Do not blindly automate bootloader upgrades across a fleet. Check model guidance and maintain recovery access.

## Backup versus export

```routeros
/export show-sensitive=no terse file=EDGE-01-before-change
/system backup save name=EDGE-01-before-change password="LONG-UNIQUE-SECRET"
/file print
```

| Text export `.rsc` | Binary backup `.backup` |
|---|---|
| readable, reviewable, editable | machine-oriented restore image |
| useful for migration and version control | best for same-device disaster recovery |
| order/dependencies may need adaptation | may include sensitive state |
| `show-sensitive=no` for safe review | always protect and encrypt |

Test restoration in a lab. An untested backup is only a hope.

## Reset and Netinstall

Reset removes active configuration and returns to a chosen default/scripted state. Netinstall reinstalls RouterOS from another computer and is a deeper recovery/reprovisioning method. Exact boot-button timing and Ethernet port vary by hardware; use the model manual and current Netinstall documentation.

Recovery sequence:

1. preserve export/backup/support output if possible;
2. confirm model, architecture, target RouterOS channel/version;
3. establish direct Ethernet and disable interfering host firewalls/adapters only as safely required;
4. put the device into Etherboot/Netinstall mode using its hardware instructions;
5. install selected packages;
6. boot, verify resources/interfaces/license;
7. restore carefully and retest.

## Support evidence

Before contacting support, collect:

```routeros
/system sup-output name=EDGE-01-incident
/log print file=EDGE-01-log
/export show-sensitive=no file=EDGE-01-export
```

`supout.rif` can contain detailed operational information. Share it only through an appropriate support channel and according to your organization's data policy.

## Checkpoint lab

From a blank CHR:

1. build the Internet/LAN configuration above;
2. connect by IP in WinBox;
3. create a named administrator and disable `admin`;
4. export and back up;
5. intentionally set the LAN address incorrectly while in Safe Mode, drop the session, and observe rollback;
6. prove client connectivity with route, DNS, firewall, NAT, and packet evidence—not only a browser screenshot.
