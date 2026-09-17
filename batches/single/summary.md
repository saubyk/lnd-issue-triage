# Single-issue triages

| # | title | verdict | confidence | evidence |
|---|---|---|---|---|
| 1523 | lnd updatechanpolicy has confusing --help | still-valid | high | master lncli still prints `(default: 0)` for required flags; 5 PRs unmerged; maintainer wants proto3 `optional` fix (#10499 review) |
| 4135 | REST returns 500 instead of 404 for missing invoice when no invoices exist | fixed | high | #10064 (v0.20.0-beta) maps ErrNoInvoicesCreated to codes.NotFound in LookupInvoice; rpcserver.go:5946 |
| 4219 | routing+invoices: allow multi-part payment probes | superseded | high | EstimateRouteFee probe is hardcoded MaxParts:1 (router_server.go:565); MPP probing was scoped out of #8136 via #7916; #9942 is the live RPC-level ask |
| 4910 | fwdinghistory doesn't include HTLCs settled using HTLC interceptor RPC | wontfix | high | Roasbeef declined 2021-01-18, reporter accepted; interceptor settle bypasses handlePacketSettle (interceptable_switch.go:1006); accounting need met by #6517 / LookupHtlcResolution in v0.16 |
| 5201 | QueryRoutes to own node returns impossible hop due to lack of funds | needs-decision (closed not planned) | high | balance check only for edges with fromNode == self (unified_edges.go:57); last hop into self is a network edge judged on capacity; no PR since carlaKC's 2021 sketch |
| 5062 | MPP failing with max_parts=2 but succeeds using 2 parts when max_parts=16 | still-valid | high | reproduced on master 606321b66 with itest, 2 of 6 runs fail; same-hint double dispatch + pair-level MC penalty + last-shard no-split (payment_session.go:399) |
