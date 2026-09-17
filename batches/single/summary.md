# Single-issue triages

| # | title | verdict | confidence | evidence |
|---|---|---|---|---|
| 1523 | lnd updatechanpolicy has confusing --help | still-valid | high | master lncli still prints `(default: 0)` for required flags; 5 PRs unmerged; maintainer wants proto3 `optional` fix (#10499 review) |
| 4135 | REST returns 500 instead of 404 for missing invoice when no invoices exist | fixed | high | #10064 (v0.20.0-beta) maps ErrNoInvoicesCreated to codes.NotFound in LookupInvoice; rpcserver.go:5946 |
| 4219 | routing+invoices: allow multi-part payment probes | superseded | high | EstimateRouteFee probe is hardcoded MaxParts:1 (router_server.go:565); MPP probing was scoped out of #8136 via #7916; #9942 is the live RPC-level ask |
