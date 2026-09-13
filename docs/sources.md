# Sources, Baseline and Update Policy

## Primary sources

This project favors MikroTik's own current manual, automatically generated CLI reference, product changelog, and official training outlines.

- [Official training programs and certification FAQ](https://mikrotik.com/training/about)
- [MTCNA official outline PDF](https://i.mt.lv/cdn/training_pdf/mtcna_outline_2019181161836.pdf)
- [MTCRE official outline PDF](https://i.mt.lv/cdn/training_pdf/mtcre_outline_2019181161836.pdf)
- [MTCINE official outline PDF](https://i.mt.lv/cdn/training_pdf/mtcine_outline_2020154114220.pdf)
- [Current RouterOS manual](https://manual.mikrotik.com/)
- [Machine-readable manual index](https://manual.mikrotik.com/llms.txt)
- [Current CLI reference](https://manual.mikrotik.com/docs/cli-reference/)
- [RouterOS changelogs](https://mikrotik.com/download/changelogs)
- [WinBox manual](https://manual.mikrotik.com/docs/management-tools/winbox/)
- [Packet flow](https://manual.mikrotik.com/docs/firewall-and-quality-of-service/packet-flow-in-routeros/)
- [Routing and networking protocols](https://manual.mikrotik.com/docs/user-guides/routing-and-networking-protocols/)
- [BGP](https://manual.mikrotik.com/docs/user-guides/routing-and-networking-protocols/unicast/bgp/)
- [OSPF](https://manual.mikrotik.com/docs/user-guides/routing-and-networking-protocols/unicast/ospf/)
- [MPLS, LDP, TE and VPLS](https://manual.mikrotik.com/docs/user-guides/routing-and-networking-protocols/mpls/)

## Version baseline

The initial edition was audited on **2026-08-26**. RouterOS **7.22.3 stable**, published 2026-05-08, was the latest stable release visible in MikroTik's official changelog query used during the audit. Examples target RouterOS v7 and avoid depending on a patch-only behavior unless stated.

Do not assume “newer” always means “safe for this network.” Operators should:

1. read the changelog for every release between the deployed and target versions;
2. check architecture, package, bootloader, and storage constraints;
3. test on representative hardware or CHR;
4. export and back up first;
5. schedule rollback and out-of-band access.

The menu-by-menu GUI manual targets **WinBox v4**. WinBox is a client view of
the connected RouterOS object model: visible menus and fields still depend on
the router version, installed packages, device hardware, device mode, license
and user permissions. Conditional fields are labeled instead of being promised
on every device.

## Source hierarchy when information conflicts

1. The current device's generated CLI (`?`, `print detail`, export) for what that exact build exposes.
2. Current official CLI reference for types and properties.
3. Current official user guide for behavior and examples.
4. Official changelog for version-specific additions and fixes.
5. Official course outline for certification scope.
6. This book for teaching order, worked examples, and operational context.

The old course outlines define scope but do not override current software behavior.

## How to update a version-sensitive example

When a command changes:

- update the example and its expected verification output;
- state the minimum RouterOS version if known;
- retain old syntax only in a clearly labeled migration note;
- add or update the primary-source link;
- run `./scripts/check-docs.sh`;
- test the lab on a clean CHR before merging.

## Exam integrity

The questions under `exams/` are original practice items. Do not contribute memorized live exam questions, screenshots, dumps, or material that violates an exam agreement. The goal is transferable understanding.
