# Conditional, Package and Hardware Menus

There is no single universal WinBox sidebar. This catalog prevents an absent or
extra menu from being mistaken for an error. A family appears only when the
matching RouterOS package, architecture, device mode, license, hardware and user
policy expose it.

## WiFi

Current `wifi-qcom`/`wifi-qcom-ac` families can expose:

- **WiFi Interfaces:** radio/interface state, configuration, channel, security,
  datapath, steering and status;
- **Configurations:** reusable SSID/mode/country/channel/security/datapath;
- **Channels:** band, frequency, width, secondary frequency, skip-DFS and power;
- **Security:** WPA2/WPA3/EAP authentication, passphrase, ciphers and management
  protection;
- **Datapaths:** bridge/VLAN/client isolation and forwarding behavior;
- **Provisioning:** match radio identity/capabilities and create dynamic APs;
- **Registration:** connected client MAC, signal, rate, uptime, security and
  VLAN/status;
- **Access List:** ordered client accept/reject/query-radius/passphrase/VLAN/
  signal/time rules;
- **Steering/Neighbor Groups:** roaming/steering policy;
- **Remote CAP/CAPsMAN:** controller discovery, managed radios and status.

Select actual country/regulatory domain. A configured SSID does not create DHCP,
routing or firewall. Legacy `/interface wireless` forms differ.

## Wireless (legacy)

Can include Interfaces, Security Profiles, Access List, Connect List,
Registration, Nstreme, NV2, WDS, Align, Snooper, Scan and CAPsMAN. Interface
forms contain Wireless, HT/VHT, WDS, Nstreme, Status and Traffic tabs. Determine
which wireless generation/package the device uses; do not mix property names.

## CAPsMAN (legacy/current controller views)

Common child windows are CAP Interface, Remote CAP, Registration Table,
Configurations, Channels, Datapaths, Security Cfg., Access List, Provisioning
and Manager. Build reusable objects first, then ordered provisioning rules. A
dynamic CAP interface should be changed through its configuration/provisioning
parent.

## LTE / 5G

Appears with supported modem/package. Interfaces expose General, Network Mode,
APN/Profile, SIM slot/PIN, band lock, roaming, passthrough and Status (operator,
cell ID, RSRP/RSRQ/SINR, registration, IP). Additional windows can include APNs,
Cell Monitor, Scan, SMS, AT Chat and firmware upgrade. Passthrough moves the
operator address to another device and changes local routing assumptions.

## LoRa, IoT, Bluetooth and GPIO

Hardware/package menus expose gateway/server/channel settings, BLE advertising/
scanning/tag data, MQTT/HTTPS integrations and GPIO pin state/rules. Treat radio
region, cloud tokens and broker credentials as sensitive. Pin voltage/direction
mistakes can damage hardware; use exact model documentation.

## Container

Requires supported architecture/storage and device mode. Windows include:

- **Containers:** image/root-dir, command/entrypoint, interface, mounts, envlist,
  logging, start-on-boot, status and resource state;
- **Config/Registry:** registry URL/credentials, temporary directory and RAM
  limits;
- **Environment Variables/Lists:** injected values (may be secrets);
- **Mounts:** source/destination mapping;
- **VETH:** virtual Ethernet address/gateway and bridge attachment.

Containers share router CPU/storage/network risk; use trusted images, pin
sources, isolate VETH with firewall and never expose the Docker registry secret.

## The Dude

With server/client support, menus manage Devices, Maps, Links, Networks,
Services, Probes, Notifications, Logs, Charts, Files and Server settings.
Discovery can generate broad traffic and untrusted inventory; scope it. A probe
status is only as accurate as its source, interval and dependency model.

## User Manager

AAA package interfaces can include Routers/NAS, Users, User Groups, Profiles,
Limitations, Sessions, Payments and Logs. Define authentication source, shared
secret, profile/limitation assignment and accounting retention. Protect the web
UI/database and test RADIUS reject/timeout, not only successful login.

## KVM/Virtualization and legacy MetaROUTER

Only on supported/legacy platforms. Guest lists expose image, memory/CPU,
interfaces/disks, autostart and console/state. These are not equivalent to CHR
licensing or modern Container support. Follow exact platform limits.

## LCD, LEDs, Beeper and touchscreen

Model-dependent display/indicator controls. They may expose pages, PIN,
backlight, read-only sensor/interface data and LED trigger rules. Avoid placing
secrets on a physical display.

## PoE, SFP, GPS, UPS, Modbus and peripherals

Often appear as tabs under Interfaces/System rather than a top-level family.
Fields and safe electrical/optical thresholds are hardware-specific. Read the
model datasheet, verify voltage/polarity/PoE mode/optic compatibility and keep a
physical recovery plan.

## OpenFlow, Traffic Generator and experimental/disabled features

Some versions/packages/device modes expose specialized or legacy features.
Their presence does not make them a current production recommendation. Record
the exact RouterOS version, enable only the smallest required device-mode
permission and use the current feature manual.

## How to audit a router whose sidebar differs

1. Record RouterOS and WinBox versions and architecture in System → Resources.
2. Record installed/enabled packages in System → Packages.
3. Record Device Mode and license.
4. Confirm the logged-in User Group policies/skin.
5. Compare the **+** lists in Interfaces and related families.
6. Run `/`, then `?` in New Terminal to enumerate exposed root menus.
7. Mark each extra/absent menu in the lab report; never guess its availability.
