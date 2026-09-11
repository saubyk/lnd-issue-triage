#!/usr/bin/env bash
# Fetch a batch of issues matching a search query into batches/<name>/raw/.
# Usage: scripts/fetch-batch.sh <batch-name> [query] [limit]
# Query defaults to triage.json default_query; limit to batch_size.
set -euo pipefail
cd "$(dirname "$0")/.."
name=${1:?batch name required}
repo=$(jq -r .repo triage.json)
query=${2:-$(jq -r .default_query triage.json)}
limit=${3:-$(jq -r .batch_size triage.json)}
out="batches/$name/raw"
mkdir -p "$out"

# Oldest-updated first so the stalest issues come up first. Search caps a
# page at 100; larger batches are not useful anyway.
[ "$limit" -le 100 ] || { echo "limit must be <= 100" >&2; exit 1; }
gh api -X GET search/issues \
  -f q="repo:$repo $query" -f sort=updated -f order=asc -f per_page="$limit" \
  --jq '.items[] | select(.pull_request == null) | .number' \
  > "batches/$name/numbers.txt"

while read -r n; do
  [ -f "$out/$n.json" ] && continue
  scripts/fetch-issue.sh "$n" > "$out/$n.json"
  echo "fetched #$n"
done < "batches/$name/numbers.txt"
echo "$(wc -l < "batches/$name/numbers.txt" | tr -d ' ') issues in batches/$name"
