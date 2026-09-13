# New Terminal, Supout, Manual and Exit

## New Terminal

**Purpose:** open RouterOS CLI for exact object discovery, commands, scripting
and output that WinBox may summarize.

The terminal tab includes prompt/context, scrollback, copy/paste and session
controls. Use `?` for valid commands/properties in the current context, Tab for
completion, `print detail` for fields and `/` to return to root. `Ctrl+X` enters
CLI Safe Mode on supported terminals.

Safe sequence before changing an object:

```routeros
/ip address print detail
/ip address print where interface=br-lan
# only after confirming the selector:
/ip address set [find where interface=br-lan] comment="LAN gateway"
```

Do not use display item numbers such as `set 0` in automation; they can change
between sessions. Do not paste unreviewed scripts or secrets into terminal
history. A command that returns without error still needs status/counter and
end-to-end verification.

## Make Supout.rif

**Purpose:** generate MikroTik's detailed diagnostic support file.

Select the menu, choose/generate a file name and wait for completion; retrieve
the `.rif` from Files. Generate while the symptom exists when safe. Supout can
contain configuration and operational data; share only through the authorized
support channel, protect locally and follow retention policy.

Equivalent CLI: `/system sup-output name=incident-id`.

## Manual

Opens the RouterOS manual in a browser. Confirm that the page is the current
manual and that its feature applies to the installed RouterOS version, package,
architecture and device. The target router's `?` and form remain authoritative
for exposed properties.

## Exit

Closes the WinBox router session. If Safe Mode is active, choose intentionally
whether to release/commit it or allow abnormal loss to roll back floating
changes. Exit does not reboot or shut down the router. Confirm no unsaved form,
active capture, destructive import or upgrade is still running.

## Reconnect and session-loss checklist

If WinBox disconnects unexpectedly:

1. wait for Safe Mode rollback before repeated edits;
2. test IP route and local MAC access separately;
3. check whether the management address/VLAN/service/firewall changed;
4. use console/RoMON/out-of-band path;
5. inspect System → History and Log after reconnect;
6. do not reset the router merely because one management method failed.
