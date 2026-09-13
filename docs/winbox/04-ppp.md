# PPP Menu

Server/diagnostic paths covered here: **PPP → L2TP Server**,
**PPP → PPTP Server**, **PPP → SSTP Server**, **PPP → OVPN Server**,
**PPP → PPPoE Servers**, and **PPP → PPPoE Scan**.

**Purpose:** centralize PPP authentication, reusable session policy, address
assignment, accounting and active state for PPPoE, L2TP, SSTP, PPTP, OVPN and
other PPP-backed interfaces.

## PPP → Interface

Lists configured PPP client/server/dynamic session interfaces. Columns show
name, type, running, actual MTU, user, caller/service and comment. **+** offers
installed PPP interface types. Double-click a client to see General and Dial
Out/status fields; dynamic server sessions are normally read-only children.

## PPP → Profiles

**Purpose:** reusable settings applied after authentication.

The New Profile form groups:

- **General:** name, local address, remote address/pool, bridge, bridge horizon,
  DNS, use compression/encryption, only-one, change TCP MSS and address lists;
- **Protocols:** IPv6 prefix/pool and protocol-specific choices where present;
- **Limits:** rate limit, session/idle timeouts and queue behavior;
- **Scripts:** on-up/on-down automation.

An address may be literal or a Pool object. Avoid overlapping pools and broad
scripts. Profile defaults can be overridden by a Secret or RADIUS result.

## PPP → Secrets

**Purpose:** local PPP user database.

Click **+** and set `Name`, `Password`, allowed `Service`, caller ID restriction,
`Profile`, optional fixed local/remote address, routes and limit bytes. Use a
specific service instead of `any` when practical. Passwords are secrets; do not
publish screenshots or sensitive exports. Large environments should use AAA.

## PPP → Active Connections

Read-only session state: name/user, service, caller ID, address, uptime,
encoding, session ID and Rx/Tx. Removing an active row disconnects the session;
it does not delete its Secret. A successful login does not prove routed access.

## PPP → L2TP/PPTP/SSTP/OVPN server buttons

Each server window enables a listener and selects default profile,
authentication methods, MTU/MRU, keepalive, certificate/TLS/IPsec properties
and session limit as applicable.

- L2TP without IPsec is not confidential on an untrusted underlay.
- PPTP is obsolete and must not be presented as secure.
- SSTP/OVPN trust depends on certificate validation and current algorithms.
- Permit only required ports/protocols in input firewall and test MTU.

## PPP → AAA

Controls whether PPP consults RADIUS, interim accounting interval and accounting
behavior. Enabling `Use RADIUS` does not create a server entry: configure the
RADIUS menu, shared secret, source address and firewall separately. Test reject,
timeout and local-fallback behavior deliberately.

## PPPoE Servers / Scan

The PPPoE Servers window binds an access concentrator to an Ethernet/VLAN/
bridge-facing interface and sets service name, default profile, authentication,
one-session-per-host, max sessions, MTU/MRU and keepalive. PPPoE Scan is a
diagnostic client-side discovery view that lists concentrators/service names on
the selected Layer 2 interface; it does not authenticate or create a permanent
client by itself.

## Verification order

1. Underlying interface/VLAN and discovery transport.
2. Listener/client enabled and correct service/profile.
3. Authentication result and Active Connections row.
4. Assigned local/remote address and dynamic route.
5. Input/forward/NAT policy and return route.
6. MTU/MRU/MSS with large packets.
7. RADIUS accounting and disconnect behavior if used.

CLI: `/ppp profile`, `/ppp secret`, `/ppp active`, `/ppp aaa`, and the relevant
`/interface ... client|server` family.
