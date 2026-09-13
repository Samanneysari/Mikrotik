# WinBox Client Shell and Quick Set

## Login window

The login window exists before RouterOS authentication and contains two areas.
**Quick Connect** accepts `Connect To` (IP, IPv6 in brackets, DNS name or MAC),
optional custom port, `Login` and `Password`. Prefer an IP connection; MAC
WinBox is local-Layer-2 recovery access and depends on discovery/MAC-server
policy. `Keep Password` stores the credential in the managed entry and should
not be used on an unmanaged workstation. `Open in New Window` keeps the loader
available.

The device-list area contains:

- **Saved/Managed** — saved address, login, encrypted credential, group and note;
- **Neighbors** — MNDP/CDP/LLDP discoveries; discovery does not prove the device
  is approved or reachable by IP;
- **RoMON** — routers reachable through a selected RoMON agent.

Click the IP column to connect by IP and the MAC column to connect by MAC. A
blank IP value, stale neighbor row, wrong Windows firewall profile or disabled
`/tool mac-server mac-winbox` are different failures.

## Router session toolbar

The top toolbar exposes **Undo**, **Redo**, **Safe Mode**, workspace, encryption
and traffic indicators. Right-click to add resource fields such as CPU and
memory. WinBox v4 opens child windows as tabs. Search, filtering, columns,
detail mode and categories change presentation only—not RouterOS state.

Safe Mode makes subsequent changes floating. If the session dies abnormally,
RouterOS rolls them back; leaving Safe Mode normally commits them. Canceling an
object dialog does not undo a change already saved with Apply.

## Quick Set

**Purpose:** generate a coordinated basic configuration for supported device
roles such as home AP, CPE, point-to-point or simple router. The exact profiles
and fields are hardware/package dependent.

**What opens:** a template selector plus grouped Internet, Local Network,
Wireless and System fields. Common controls include configuration mode,
Internet interface/address acquisition, LAN IP/netmask, DHCP server, NAT,
wireless SSID/security and administrator password.

**Safe workflow:**

1. Export the existing configuration.
2. Select the device role only on a supported simple deployment.
3. Set WAN mode and confirm which interface will become untrusted.
4. Define LAN address/prefix; enable DHCP/NAT only if required.
5. Set wireless country, SSID and strong credential where present.
6. Apply from console or Safe Mode, then verify address, route, DHCP, firewall,
   NAT and Wi-Fi objects separately.
7. Export again and compare.

Quick Set writes multiple menus and may replace assumptions from earlier Quick
Set or manual configuration. It is not a harmless status dashboard. Avoid it
after building a production design by hand.

## Settings, shortcuts and workspaces

- **Settings** controls client-side appearance, update and behavior—not router
  forwarding.
- **Shortcuts** lists platform-specific navigation and action keys.
- **About** shows WinBox version and licenses.
- **Workspace** preserves groups of connections and open tabs. Export/import a
  workspace as client state; do not confuse it with a router backup.
- **New session** opens another WinBox instance/session.

Verification: confirm the title bar identifies the expected user, address,
RouterOS version, board/platform and identity before changing anything.
