# WinBox Menu-by-Menu Field Manual

This manual is the exhaustive GUI companion to the concept-first chapters in
this repository. It answers the same questions for every WinBox family:

1. **Where is it?** — exact sidebar path and CLI object family.
2. **Why does it exist?** — the operational purpose and packet/control-plane role.
3. **What opens?** — list columns, toolbar actions, tabs, status panes and flags.
4. **How do I create or change an object?** — a safe click path and required fields.
5. **How do I prove it worked?** — GUI evidence and equivalent CLI inspection.
6. **How does it fail?** — common mistakes, dependencies and recovery.

## Version and completeness contract

The baseline is **RouterOS 7.22.3 stable with WinBox v4**. MikroTik explicitly
states that WinBox mirrors console functions and that the sidebar changes with
installed packages, device hardware, architecture, license, permissions and
device-mode restrictions. Consequently, “every menu” means:

- every baseline sidebar family and its normal RouterOS v7 child windows;
- every package/hardware-dependent family identified in the
  [conditional menu catalog](14-conditional-menus.md);
- every stable field group needed to understand and safely operate an object;
- an explicit **conditional/version-sensitive** marker where a field cannot be
  promised on every router.

If a target router disagrees with this book, its own WinBox form, `?`,
`print detail`, installed package list and current official CLI reference win.
The [coverage manifest](menu-manifest.tsv) is machine checked so a documented
menu cannot silently disappear from future editions.

## How to read an object window

Most WinBox configuration windows use the same model:

| UI element | Meaning | Safe use |
|---|---|---|
| `+` / **New** | Create a static object | Identify required fields and dependencies first |
| `-` / **Remove** | Delete selected static objects | Do not delete dynamic children; change their parent service |
| check mark / **Enable** | Activate selected objects | Verify policy order and reachability afterward |
| `X` / **Disable** | Keep but stop an object | Preferred reversible test for a rule/service |
| **Comment** | Record intent | Include ticket, peer, circuit or role—not a password |
| **Copy** | Clone as a new object | Change every unique identity/address before saving |
| **Sort/Filter** | Change only the displayed rows | Clear filters before concluding an object is absent |
| **Columns** | Expose status or configuration properties | Add counters, state, interface/table and comment columns |
| double-click | Open configuration and status tabs | Dynamic rows may be read-only |
| **Apply** | Save without closing | Verify while the form remains open |
| **OK** | Save and close | Use after Apply/verification |
| **Cancel** | Close without unsaved form changes | It does not undo an earlier Apply |

Flags such as `X`, `I`, `D`, `R`, `A`, `H`, `S`, `C`, `o`, `b`, and `+` are
context-specific. Read the legend in the current window; do not transfer the
meaning of a flag blindly between Interfaces, Routes and Bridge Hosts.

## Complete sidebar map

| # | Sidebar family | Detailed reference |
|---:|---|---|
| 1 | Quick Set | [Client shell, Quick Set and session controls](01-client-and-quick-set.md) |
| 2 | Interfaces | [Interfaces](02-interfaces.md) |
| 3 | Bridge | [Bridge and switching](03-bridge-switch-mesh.md) |
| 4 | PPP | [PPP and tunnel interfaces](04-ppp.md) |
| 5 | Switch | [Bridge and switching](03-bridge-switch-mesh.md) |
| 6 | Mesh | [Bridge and switching](03-bridge-switch-mesh.md) |
| 7 | IP | [IP core](05-ip-core.md) and [IP policy/services](06-ip-policy-services.md) |
| 8 | IPv6 | [IPv6](07-ipv6.md) |
| 9 | MPLS | [Routing and MPLS](08-routing-mpls.md) |
| 10 | Routing | [Routing and MPLS](08-routing-mpls.md) |
| 11 | System | [System](09-system.md) |
| 12 | Queues | [Queues](10-queues.md) |
| 13 | Files | [Files, Log and RADIUS](11-files-log-radius.md) |
| 14 | Log | [Files, Log and RADIUS](11-files-log-radius.md) |
| 15 | RADIUS | [Files, Log and RADIUS](11-files-log-radius.md) |
| 16 | Tools | [Tools](12-tools.md) |
| 17 | New Terminal | [Terminal, Manual, Supout and Exit](13-terminal-support.md) |
| 18 | Make Supout.rif | [Terminal, Manual, Supout and Exit](13-terminal-support.md) |
| 19 | Manual | [Terminal, Manual, Supout and Exit](13-terminal-support.md) |
| 20 | Exit | [Terminal, Manual, Supout and Exit](13-terminal-support.md) |
| — | Conditional/package menus | [WiFi, CAPsMAN, Container, Dude, LTE, LoRa, IoT and hardware catalog](14-conditional-menus.md) |

## The required learning pattern

For each submenu, do not stop after finding the window. On an isolated router:

1. predict which object, dynamic state, route, counter or log should appear;
2. open the submenu and expose the useful columns;
3. create the smallest object with **Apply** while in Safe Mode if reachability can change;
4. inspect status/counters and the matching CLI `print detail`;
5. inject one reversible fault;
6. identify the first decisive field/counter;
7. repair, document and export with `show-sensitive=no`.

## Primary references

- [Current WinBox manual](https://manual.mikrotik.com/docs/management-tools/winbox/)
- [Current RouterOS CLI reference](https://manual.mikrotik.com/docs/cli-reference/)
- [Machine-readable manual index](https://manual.mikrotik.com/llms.txt)
- [Repository version/source policy](../sources.md)
