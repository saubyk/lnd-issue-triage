#!/usr/bin/env bash
# Sync the lnd worktree to upstream/master and discard any local changes.
# Usage: scripts/reset-lnd.sh
set -euo pipefail
cd "$(dirname "$0")/.."
lnd=$(jq -r .lnd_path triage.json)
cd "$lnd"
git fetch upstream --quiet
git checkout --quiet --detach upstream/master
git reset --hard --quiet
git clean -fdq
echo "lnd worktree at $(git log --oneline -1)"
