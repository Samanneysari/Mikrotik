# System Menu

Combined headings below cover these individual paths: **System → NTP Client**,
**System → NTP Server**, **System → User Groups**, **System → LCD**,
**System → Console**, **System → GPS**, **System → PTP**, **System → Disks**,
and **System → Shutdown**.

The System family controls the router itself: identity, software, time, users,
logging, automation, storage/recovery and hardware health. Many changes here
can reboot, erase, expose or permanently lock a device.

## System → Resources

Read-only inventory: uptime, RouterOS version/build time, free/total memory,
CPU model/count/frequency/load, free/total storage, architecture, board/platform
and bad blocks/write statistics where available. High CPU is a symptom; open
Tools → Profile before guessing. Low disk can break updates, captures and logs.

## System → Resource → CPU, IRQ, PCI and USB

CPU shows per-core load; IRQ associates interrupt load with hardware; PCI/USB
lists detected devices and properties. These are diagnostic views, not general
performance tuning controls. Hardware availability varies.

## System → Packages

Lists installed package, version, build time, scheduled enable/disable/uninstall
and update status. Use **Check For Updates**, select channel, Download, then
schedule reboot after compatibility/backups. Extra package files must match the
exact version and architecture. RouterOS update and RouterBOOT firmware are
separate steps.

## System → RouterBOARD

Physical-device board model, serial, factory/current/upgrade firmware and
settings. **Upgrade** writes matching RouterBOOT for the installed RouterOS;
reboot is required. Do not automate fleet firmware upgrades without model tests
and recovery. CHR/x86 may not expose this window.

## System → Identity

Sets the router name shown in WinBox title, discovery and logs. Use a unique
site-role identifier; do not put credentials or sensitive customer data in it.

## System → Clock and NTP Client/Server

Clock sets time, date and IANA timezone. NTP Client configures enabled mode,
servers, VRF/source and authentication where supported; Status shows selected
server, stratum, offset and synchronization. NTP Server enables service/modes
for clients. Correct time is required for logs, certificates and troubleshooting.

## System → Users

**Users:** click **+**, set Name, Group, password, allowed Address and comment.
Use named accounts and independent credentials. Disable built-in `admin` only
after another privileged login works.

**Groups:** define policy permissions and optional skin. Built-in `full`,
`write` and `read` are broad; create least-privilege groups for automation and
monitoring. Policy names such as read/write/policy/test/sensitive/reboot/API have
real security impact.

**SSH Keys:** import a user's public key and bind it to the correct account.
Never upload the user's private key. Active Users/Sessions shows current logins;
terminate only after identifying the operator/change.

## System → Certificates

Certificate list shows name, subject/issuer, key type/size, serial, validity,
key-usage, trusted/revoked/expired flags and private-key presence. **+** creates
a certificate template; **Sign** self-signs or uses a CA; Import/Export handles
certificate/key files and passphrases.

Set CN/SAN, validity and key usage for the actual service. A certificate is not
trusted merely because encryption works. Protect private-key rows/files, verify
time, and bind the certificate in the target service separately.

## System → Logging

**Rules:** topics, prefix and Action. Topics can include info/error/warning/
critical plus firewall, routing protocols, DHCP, wireless and debug. Use exact
topic combinations and avoid unbounded packet logging.

**Actions:** memory, disk, echo or remote target; configure file count/lines,
remote address/port, BSD syslog format/facility/source and VRF where supported.
Verify collector receipt and synchronized time. Plain syslog is not confidential.

## System → Scripts

List fields include Name, Owner, Policies, Last Started, Run Count and invalid
state. New Script contains Name, Policy permissions, Source and comment. Use
**Run Script** only after reviewing every line. The owner/policies define what it
can do. Select objects by stable unique properties, not display row numbers;
make repeated automation idempotent and log decisions without secrets.

## System → Scheduler

Click **+**, set Name, Start Date/Time (or startup), Interval, On Event script/
source, Policy and comment. Status shows next run, last start and run count.
Scheduler is time-driven; Netwatch is probe-driven. Avoid simultaneous fleet
runs and two automations controlling the same object.

## System → History

Shows undoable actions, time, user, policy and CLI action. **Undo/Redo** affects
eligible recent changes; Safe Mode groups floating changes. History is valuable
for GUI-to-CLI learning but is not a complete external audit/backup.

## System → Backup

The Backup dialog creates an encrypted binary `.backup` with Name, Password and
encryption setting. Restore replaces operational state and normally reboots.
Binary backups suit same-device disaster recovery and may contain secrets; test
restore in a lab. For review/migration use New Terminal → `/export
show-sensitive=no`.

## System → Reset Configuration

Destructive rebuild fields include no-defaults, keep-users, skip-backup and run-
after-reset script. Confirm exact target and console/out-of-band access. A reset
does not preserve a remote management path unless the default/custom script
creates it.

## System → Auto Upgrade

Can use another RouterOS device/package source for coordinated updates. Configure
manager/source, schedule and credentials only in a controlled fleet. Modern
package-update mechanisms may replace or hide this feature by version.

## System → Device Mode

Displays and requests permitted feature groups such as scheduler, container,
traffic generation, partitions, hotspot or proxy depending on release. Enabling
risky features may require physical confirmation/power cycle. Device mode is a
security boundary; do not weaken it only to make a copied command work.

## System → Health

Read-only sensors: temperature, voltage, current, fan speed, PoE and PSU state
where hardware supports them. Sensor names and thresholds are model-specific.
Correlate sustained abnormal values with environment and official limits.

## System → LEDs and LCD

LED rules map hardware LEDs to interface/activity/signal/script functions. LCD
controls touchscreen/pages/backlight/PIN where present. A misconfigured indicator
does not change forwarding, but can mislead field operators. Hardware-only.

## System → Ports and Console

Ports configures serial/USB serial channel baud/data/parity/flow control. Console
maps terminal service to a port/channel. Preserve a known recovery console when
changing IP access; wrong serial parameters look like a dead router.

## System → Router Settings

Global router behavior can include IPv4/IPv6 forwarding, route-cache/multipath,
ICMP redirects, RP filter, TCP syncookies and connection settings depending on
version (some live under IP/IPv6 Settings). Treat each as global and verify
multi-WAN/asymmetric-routing impact before enabling strict reverse-path checks.

## System → SNTP/NTP, GPS and Precision Time Protocol

Time-source menus vary by package/hardware. GPS exposes port/channel/location/
time state; PTP defines profile/domain/transport/interfaces and clock state.
Verify grandmaster/source selection and offset, not only enabled state.

## System → UPS

Configures a supported USB/serial UPS: port, polling, low-battery runtime and
shutdown behavior. Monitor status, battery charge/voltage/runtime and test a
controlled power event. Hardware/driver dependent.

## System → Watchdog

Can reboot on hang, no-ping target or kernel failure and send support output.
Fields include watchdog timer, ping address/timeout, automatic supout and e-mail.
A single unreliable ping target can create a reboot loop; use an appropriate
design and out-of-band recovery.

## System → Note

Stores a login/system note and display-at-login option. Use it for ownership,
change window and emergency contact—not passwords or customer secrets.

## System → License

Shows software ID/system ID, license level/features, next renewal and key/import
controls for CHR/x86 licensing. License does not add unsupported hardware
capability. Protect account/key material.

## System → Partitions, Disks and Stores

Hardware/storage-dependent menus create/resize/format/mount partitions/disks and
select package/backup/container stores. Formatting, repartitioning and restore
are destructive. Resolve the exact device, preserve backups externally and
confirm filesystem/architecture support before changes.

## System → Reboot and Shutdown

Reboot restarts RouterOS; Shutdown halts supported systems. Check active users,
Safe Mode, config writes, upgrade/firmware state, redundancy and maintenance
approval. Loss of the session is expected; verify boot, interfaces, routes and
services afterward.
