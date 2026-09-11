---
title: "rescan: a single failed block fetch permanently kills the rescan; Update() fails until process restart"
repo: lightninglabs/neutrino
posted: true
url: https://github.com/lightninglabs/neutrino/issues/388
---

### Summary

When `extractBlockMatches` fails to fetch a block (for example, all peers time out and `GetBlock` returns `couldn't retrieve block ... from network`), the error propagates out of the rescan loop and the goroutine started by `Rescan.Start()` exits. Nothing restarts it. Every later call to `Rescan.Update()` then returns:

```
Rescan is already done and cannot be updated. It returned error: couldn't retrieve block <hash> from network
```

For lnd this means that after one transient network hiccup, wallet operations that register new addresses or outpoints (`newaddress`, channel funding, and so on) fail until lnd is restarted. lnd's neutrino notifier only logs the error from `Start()`'s error channel and does not recreate the rescan.

### Where it happens (master @ ac63a41)

The same code is in v0.18.0 (pinned by lnd master) and v0.16.1 (pinned by the latest lnd release, v0.19.3-beta); in v0.16.1 the `rescan.go` lines below are one lower.

- `rescan.go:1391` `Rescan.Start()`: runs `rs.rescan()` once in a goroutine; on error it closes `r.running`, stores the error in `r.err`, sends it on the error channel, and returns. There is no retry or restart path.
- `rescan.go:994` `extractBlockMatches()`: calls `chain.GetBlock(...)` and returns any error upward, which ends the rescan loop.
- `rescan.go:1470` `Rescan.Update()`: selects on `r.running`; once it is closed (`rescan.go:1487`) every call returns the "Rescan is already done and cannot be updated" error.
- `query.go:938` `ChainService.GetBlock()`: the `couldn't retrieve block %s from network` error returned when the query finishes with no block.
- lnd side, `chainntnfs/neutrinonotify/neutrino.go:563` (lnd master): the error from `Start()` is only logged as `Error during rescan: %v`; the rescan is never recreated.

The query dispatcher retries (`QueryNumRetries = 8`, `query.go:52`) make the trigger rarer, but when the retries are exhausted the outcome is the same.

### Expected behaviour

A failed block fetch should be treated as transient: the rescan should retry the block later or wait for new peers, as suggested by halseth in the lnd thread. Alternatively, `Rescan` could be restartable so callers can recover without a process restart.

### Reports

Tracked in lnd as lightningnetwork/lnd#4870 (opened Dec 2020). Reported again there by other operators in 2022 and, by the ZEUS wallet maintainer, in Dec 2024 as something they see "fairly often" on neutrino nodes.
