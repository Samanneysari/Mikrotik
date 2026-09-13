# Files, Log and RADIUS Menus

## Files

**Purpose:** manage files stored on router flash/disk/RAM: exports, backups,
certificates, packages, PCAPs, logs, hotspot assets, scripts and support output.

The list shows Name, Type, Size, Creation Time and storage/free-space context.
Open text-compatible files to inspect content; **Upload**, drag-and-drop or paste
adds files; right-click **Download** retrieves; Remove deletes. A directory row
organizes supported storage.

Check free space before capture/update/backup. `.backup`, certificates/keys,
sensitive exports and `supout.rif` may contain secrets. Download to controlled
storage and remove only after verifying retention. Uploading a package does not
apply it until compatible reboot/package processing.

## Log

**Purpose:** display RouterOS in-memory/persistent/remote-generated event rows.

Columns contain Time, Topics and Message. Toolbar search/filter only changes the
view. **Follow** streams new rows; filter exact topics such as firewall, dhcp,
ospf, bgp, ppp, system, critical or debug. Repeated messages may be rate-limited
or collapsed.

Log rules/actions are configured in System → Logging. Correct NTP/timezone is
required for correlation. Do not enable broad debug or per-packet logging on a
busy router without CPU/storage limits. Logs are evidence, not proof of packet
forwarding by themselves.

## RADIUS

**Purpose:** configure RouterOS as an AAA client for PPP, login, HotSpot,
wireless, DHCP or other supported services.

Click **+** and configure:

- `Service` consumers;
- server `Address`, authentication/accounting ports;
- shared `Secret` (never publish it);
- Source Address and VRF;
- protocol/timeouts/retries;
- certificate/TLS properties where RadSec is supported;
- realm/routing behavior and comment.

Order/failover across multiple servers and service selection matter. Permit the
traffic, ensure the server returns the expected attributes and test accept,
reject and timeout. A timeout should not silently grant more privilege.

### RADIUS → Incoming

Enables authenticated Disconnect/CoA requests and selects port/source controls.
This lets a server modify active sessions; expose it only to exact AAA servers
with a protected secret/firewall.

### RADIUS → Active/Status

Where exposed, status shows pending requests, accepts/rejects/timeouts and
server health. Combine with Log and active PPP/HotSpot/users. A reachable UDP
port does not prove the secret, service or returned policy is correct.
