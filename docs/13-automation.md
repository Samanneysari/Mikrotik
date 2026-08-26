# 13 — MTCNA+ CLI, Scripting, API and Configuration Discipline

Automation should make a known safe procedure repeatable. It should not make an unexplained command run faster on every router.

## 1. CLI navigation and discovery

```routeros
?                         # available commands in context
/ip firewall ?            # child menus/commands
/ip address print detail
/ip address print where interface=br-lan
/ip address get [find where comment="LAN gateway"] address
```

Use Tab completion and `?` on the actual version. Avoid scripts that depend on list item numbers such as `set 0`; item numbers are session/display artifacts. Select by unique stable properties.

Safer pattern:

```routeros
/interface ethernet set [find where default-name=ether1] comment="WAN"
```

## 2. Variables and control flow

```routeros
:local target "1.1.1.1"
:local replies [/ping $target count=3]
:if ($replies = 0) do={
    :log warning ("No ping replies from " . $target)
} else={
    :log info ("Probe OK: " . $target . " replies=" . $replies)
}
```

Explanation:

- `:local` scopes values to the script;
- command substitution returns the ping result;
- parentheses and `.` construct a log message;
- one probe is not a safe reason to disable a route in production—add hysteresis, independent targets, and rollback.

## 3. Idempotence

An idempotent script can run repeatedly without creating duplicates.

```routeros
:local ruleComment "AUTO: permit monitoring ICMP"
:if ([:len [/ip firewall filter find where comment=$ruleComment]] = 0) do={
    /ip firewall filter add chain=input action=accept protocol=icmp \
        src-address=192.0.2.50 comment=$ruleComment
}
```

This still has an ordering problem if the final drop is above the newly added rule. Production automation must verify placement, not only existence.

## 4. Export, import and review

```routeros
/export show-sensitive=no terse file=router-before
/import file-name=approved-change.rsc verbose=yes dry-run=yes
```

Where supported by the running v7 release, dry run finds syntax/runtime issues without applying the import. It does not prove policy safety, device compatibility, or end-to-end outcome. Read generated output and test on a matching lab image.

Never treat an export as a perfectly declarative desired-state file: dynamic values, device defaults, ordering, generated objects, certificates, and version differences require thought.

## 5. Scheduler

```routeros
/system script add name=log-health policy=read,test source={
    :log info ("health uptime=" . [/system resource get uptime])
}
/system scheduler add name=hourly-health interval=1h on-event=log-health \
    start-time=startup
```

Give scripts only required policies. Understand the scheduler/script owner's permission context. Avoid schedules that all run at exactly the same time across a fleet.

## 6. Netwatch versus scheduler

- Netwatch is condition/probe-driven and has a constrained execution model.
- Scheduler is time-driven.
- A central automation/monitoring system offers better inventory, secret handling, approvals, retries, and audit for fleets.

Do not create two independent automations that fight over the same route.

## 7. API and REST

RouterOS exposes API mechanisms, including REST over HTTPS on supported v7 releases. The object model follows CLI paths. Conceptual read:

```bash
curl --fail --silent --show-error \
  --user 'readonly-api:SECRET' \
  'https://192.0.2.1/rest/ip/address'
```

Do not place real credentials in shell history, source code, URLs, or CI logs. Use a secret manager/environment injection, a dedicated least-privilege account, trusted TLS, management-only reachability, request timeouts, and response validation.

Mutations must be guarded by:

1. inventory and version checks;
2. current-state precondition;
3. approved desired change;
4. backup/export;
5. bounded device batch;
6. verification;
7. rollback and stop-on-failure.

## 8. Configuration-as-code workflow

Recommended change record:

```text
Device scope:
Requirement / ticket:
Current evidence:
Proposed commands:
Risk and blast radius:
Out-of-band path:
Pre-checks:
Rollback commands:
Post-checks:
Operator / reviewer / time:
```

Sanitized exports can be versioned privately. Split reusable intent from device-specific values; validate that templates do not expose secrets or duplicate addresses/router IDs.

## 9. Example safe change script

Goal: add a static route only when gateway is locally reachable and route is absent.

```routeros
:local gw "10.0.12.2"
:local prefix "192.168.30.0/24"
:if ([/ping $gw count=3] = 0) do={
    :error ("Gateway unreachable: " . $gw)
}
:if ([:len [/ip route find where dst-address=$prefix and static=yes]] = 0) do={
    /ip route add dst-address=$prefix gateway=$gw comment="AUTO: branch route"
    :log info ("Added " . $prefix . " via " . $gw)
} else={
    :log info ("Route already exists: " . $prefix)
}
```

Limitations to explain before production:

- a pingable gateway does not prove the destination is reachable;
- an existing route may have a wrong gateway and this script leaves it untouched;
- `static=yes` selector availability/behavior should be verified on the target release;
- route policy/table and duplicate disabled routes need explicit design;
- there is no automatic rollback if later verification fails.

## 10. Automation checkpoint

Write and lab-test an idempotent script that creates an interface list and adds known interfaces, exports before/after state, refuses unknown RouterOS major versions, logs each action, and makes no change when the desired state already exists. Have another person explain every line before deployment.
