---
name: triage
description: Triage stale lightningnetwork/lnd issues. Fetches a batch, classifies each issue as fixed / superseded / not-reproducible / still-valid / needs-decision / wontfix with checkable evidence, optionally attempts a reproduction against current master in the lnd worktree, and writes one verdict file per issue plus a batch summary. Never posts to GitHub. Use via /triage <batch-name> [query], or /triage <issue-number>.
---

# Triage stale lnd issues

You produce verdicts; they are recommendations only. The decision to post a
comment, close, label, or otherwise act on an issue belongs strictly to the
human. Never comment on, label, or close a GitHub issue, and never suggest that
an action has already been taken. Never commit inside the `lnd/` worktree.

## Inputs

- `/triage <batch-name> [query] [limit]` — fetch a batch with
  `scripts/fetch-batch.sh` and work through it.
- `/triage <number>` — single issue via `scripts/fetch-issue.sh`.
- With no args, ask for a batch name; the default query in `triage.json` is used.

Skip any issue that already has `issues/<n>.md` unless asked to redo it.

## Per-issue procedure

Work cheapest evidence first. Stop as soon as the verdict is clear.

1. **Read the whole thread**, not just the body. The real state is often in a
   late comment. Weight `MEMBER`/`COLLABORATOR` comments over drive-by "+1"s.
   Note the lnd version the reporter was on.

2. **Cross-references** (`cross_refs` in the JSON). A merged PR that references
   the issue is the strongest "fixed" signal. Open a candidate PR with
   `gh pr view <n> --repo lightningnetwork/lnd` and confirm it actually
   addresses the report, not merely mentions it.

3. **Code and release-note search** in `lnd/`. Grep for the RPC, flag, function,
   or error string named in the issue. Check `docs/release-notes/` for the
   symptom. Many 2020–2022 bugs died when a subsystem was rewritten; say which
   one and point at the commit or PR.

4. **Duplicate search**: `gh issue list --repo lightningnetwork/lnd --search
   "<key phrase>"`. If a newer issue covers the same problem with more activity,
   verdict is `superseded` and the draft comment links it.

5. **Reproduction** — only if steps 1–4 are inconclusive AND the issue is a
   concrete bug with reproducible steps (not a feature request, question, or
   design discussion). Before starting run `scripts/reset-lnd.sh`.
   - Prefer a unit test: write a throwaway `_test.go` next to the code and run
     `make unit pkg=<pkg> case=<Test>` from inside `lnd/`.
   - Use an itest (`make itest icase=<name>`) only when the behaviour spans
     nodes; it needs the btcd/bitcoind harness and takes minutes.
   - Record exact commands and output in the verdict file.
   - Run `scripts/reset-lnd.sh` again when done, whatever the outcome.
   A passing test is evidence, not proof. Say what conditions it did not cover.

## Verdicts

| verdict | meaning | draft comment? |
|---|---|---|
| `fixed` | a specific PR/commit resolved it | yes, cite the PR |
| `superseded` | a newer issue tracks the same problem | yes, link it |
| `not-reproducible` | can't reproduce on current master; original conditions unclear | yes, say what was tried, invite reopen |
| `still-valid` | the gap is real on current master | no |
| `needs-decision` | feature request / design question; product call for a maintainer | no; one-line summary for the human |
| `wontfix` | explicitly declined by a maintainer in-thread, but left open | yes, quote the decision |

Set `confidence` honestly. `low` means a human should re-check before posting.

## Draft comments

The comment is posted by a product manager, not a developer, and is read by the
original reporter, who may have last looked at this years ago. Optimize for
readability: the reporter should understand in one read why the issue is being
closed and what to do if they disagree.

- Three to five short sentences. Plain language, no jargon. If a technical
  term is unavoidable (an RPC name, a flag), explain it in a few words.
- First sentence says what is happening and why: "Closing this, because the
  bug was fixed in lnd v0.17 by #1234."
- Cite the fix, the newer issue, or the maintainer decision by link or number
  so the reporter can verify. Do not restate the PR's internals, commit hashes,
  or file paths; those belong in the Evidence section, not the comment.
- For `not-reproducible`, say which lnd version was tested and describe the
  scenario in the reporter's own terms, then invite them to reopen or file a
  new issue with details on a current version. Never say "fixed".
- For `wontfix`, quote or paraphrase the maintainer decision and name who made
  it. Do not editorialize.
- No boilerplate, no apology, no thanks-for-your-patience filler.

Before finishing a verdict, reread the draft as the reporter would. If it
needs the Evidence section to make sense, simplify it.

## Output

- `issues/<n>.md` from `issues/TEMPLATE.md`. `checked_against` is the
  `lnd/` worktree HEAD (`git -C lnd rev-parse --short HEAD`).
- `batches/<name>/summary.md`: a table of `# | title | verdict | confidence |
  one-line evidence`, then the `needs-decision` items expanded so the human can
  decide quickly.

Finish by printing the summary table and the counts per verdict.
