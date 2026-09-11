# lnd issue triage

Tooling and records for triaging stale issues on lightningnetwork/lnd.

- `triage.json` — repo, path to the lnd worktree, default search query.
- `scripts/` — fetch and reset helpers (`gh` + `jq`; no other deps).
- `issues/<n>.md` — one verdict file per triaged issue. This is the record of truth.
- `batches/<date>-<slug>/` — batch summaries; raw JSON under `raw/` is gitignored.
- `lnd/` — git worktree of the lnd fork, detached at upstream/master. Gitignored.
  Never commit from inside it. Reset with `scripts/reset-lnd.sh`.

Run `/triage` to work a batch. The skill never posts to GitHub; the human does.
