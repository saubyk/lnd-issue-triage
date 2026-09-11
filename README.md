# lnd-issue-triage

Records and tooling for deciding which stale `lightningnetwork/lnd` issues to
keep open or close.

## Layout

| path | purpose |
|---|---|
| `triage.json` | repo, lnd worktree path, default search query, batch size |
| `scripts/fetch-batch.sh <name> [query] [limit]` | fetch a batch of issues (oldest-updated first) into `batches/<name>/raw/` |
| `scripts/fetch-issue.sh <n>` | one issue as JSON: body, full thread, cross-referenced PRs with merge state |
| `scripts/reset-lnd.sh` | sync the `lnd/` worktree to `upstream/master` and clean it |
| `issues/<n>.md` | one verdict file per issue (see `issues/TEMPLATE.md`) |
| `batches/<name>/summary.md` | per-batch verdict table |
| `.claude/skills/triage/` | the `/triage` skill: rubric, procedure, output format |

`lnd/` is a git worktree of the lnd fork, detached at `upstream/master`. It is
gitignored and exists only so reproduction tests can be built and run. Recreate
it with:

```
git -C ~/Projects/saubyk/lnd worktree add --detach ~/Projects/saubyk/lnd-issue-triage/lnd upstream/master
```

## Workflow

1. `/triage <batch-name>` in Claude Code. Optionally pass a query and limit.
2. Review `batches/<name>/summary.md` and the per-issue verdict files.
3. Post the draft comments you agree with, by hand. Flip `posted: true`.
4. Commit the verdict files.

Requires `gh` (authenticated) and `jq`.
