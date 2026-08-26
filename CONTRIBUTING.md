# Contributing

Contributions are welcome when they improve accuracy, teaching clarity, or lab reproducibility.

## Required structure for a technical addition

1. State the requirement and RouterOS/version/hardware assumptions.
2. Explain the concept before commands.
3. Use documentation/private IP space and private ASNs.
4. Explain every non-obvious command/property.
5. Add verification commands and expected logic.
6. Add at least one failure mode and rollback.
7. Cite current primary MikroTik documentation for version-sensitive behavior.
8. Run `./scripts/check-docs.sh`.

Do not submit:

- certification dumps or remembered live exam questions;
- real customer addresses, exports, PCAP payloads, keys, passwords, certificates, or support files;
- commands tested only on an unrelated RouterOS major version without labeling;
- broad firewall/BGP/MPLS policies whose safety cannot be explained.

Use **MikroTik**, **RouterOS**, **RouterBOARD**, **WinBox**, and official certification names consistently.
