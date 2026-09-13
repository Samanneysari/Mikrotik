# Queues Menu

Queues schedule/drop traffic at a controllable bottleneck. They cannot create
bandwidth, and hardware offload/FastTrack can bypass the expected software path.

## Queues → Simple Queues

**Purpose:** apply upload/download limits and hierarchy to targets with a
single object.

Click **+**. Typical tabs:

- **General:** Name, Target address/interface, Dst., Max Limit upload/download;
- **Advanced:** packet marks, priority, Queue type, parent, time schedule and
  bucket size;
- **Queue:** Limit At (committed), Max Limit, Burst Limit/Threshold/Time,
  priority and queue type per direction;
- **Statistics/Traffic:** current rate, packet/byte totals, queued/dropped,
  thresholds and live graph.

Rates are upload/download from the target perspective. Parent capacity must be
shaped below the real bottleneck; child `limit-at` totals must fit. Generate new
traffic, inspect counters and temporarily exclude FastTrack when testing.

## Queues → Queue Tree

**Purpose:** hierarchical scheduling on a selected parent/interface/global path,
usually using packet marks or interface traffic.

New Queue fields include Name, Parent, Packet Mark, Queue Type, Priority,
Limit At, Max Limit, Burst values and bucket size. A child can only schedule
traffic that reaches its parent and matches its mark. Interface-parent trees
control egress on that interface; choose ingress/egress design deliberately.

## Queues → Queue Types

Defines scheduling algorithms used by Simple Queue/Queue Tree.

- **default/fifo:** byte/packet FIFO limit;
- **PCQ:** classifier fields, per-substream rate, limit, total limit, bursts and
  IPv4/IPv6 masks;
- **RED/SFQ:** queue/perturbation/threshold parameters where supported;
- **CoDel/FQ-CoDel/CAKE:** modern delay/fairness parameters where available.

For PCQ upload commonly classifies source address; download destination address.
Changing a shared queue type affects every queue referencing it. Test latency,
loss, fairness and memory under load—not only a speed-test peak.

## Queues → Interface Queues

Shows/sets the default transmit queue type per interface. Hardware-only queues,
multi-queue Ethernet and `only-hardware-queue` behavior depend on driver and
whether software queueing/bridge features are active. Do not change merely to
match another router model.

## Verification and failure map

| Symptom | First fields to inspect |
|---|---|
| Counter zero | FastTrack, target/mark, parent, actual routed path |
| Speed unchanged | bottleneck upstream, max-limit direction, hardware offload |
| High latency | parent shaping point, buffers, queue type, saturation |
| One user dominates | PCQ classifier/substream count, large-flow distribution |
| Guaranteed rates fail | sum of child limit-at versus parent real capacity |
| MPLS/bridge traffic absent | queue attachment path and offload compatibility |

Equivalent CLI: `/queue simple`, `/queue tree`, `/queue type`,
`/queue interface`, each with `print stats detail`.
