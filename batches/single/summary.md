# Single-issue triages

| # | title | verdict | confidence | evidence |
|---|---|---|---|---|
| 1523 | lnd updatechanpolicy has confusing --help | still-valid | high | master lncli still prints `(default: 0)` for required flags; 5 PRs unmerged; maintainer wants proto3 `optional` fix (#10499 review) |
| 4135 | REST returns 500 instead of 404 for missing invoice when no invoices exist | fixed | high | #10064 (v0.20.0-beta) maps ErrNoInvoicesCreated to codes.NotFound in LookupInvoice; rpcserver.go:5946 |
