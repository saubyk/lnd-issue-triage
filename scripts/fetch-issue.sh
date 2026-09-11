#!/usr/bin/env bash
# Print one issue as JSON: body, labels, full comment thread, and cross-referenced
# PRs/issues from the timeline (with their state). Usage: scripts/fetch-issue.sh <number>
set -euo pipefail
cd "$(dirname "$0")/.."
n=${1:?issue number required}
repo=$(jq -r .repo triage.json)

issue=$(gh api "repos/$repo/issues/$n" --jq '{
  number, title, state, html_url, created_at, updated_at,
  author: .user.login, author_assoc: .author_association,
  labels: [.labels[].name], milestone: .milestone.title, body}')

comments=$(gh api --paginate "repos/$repo/issues/$n/comments" --jq '[.[] | {
  author: .user.login, assoc: .author_association, created_at, body}]' | jq -s 'add // []')

# Cross-references: PRs/issues that mention this one. State tells us if a fix merged.
refs=$(gh api --paginate "repos/$repo/issues/$n/timeline" --jq '[.[]
  | select(.event == "cross-referenced")
  | .source.issue
  | {number, title, state, is_pr: (.pull_request != null),
     merged: (.pull_request.merged_at != null), url: .html_url}]' | jq -s 'add // []')

jq -n --argjson i "$issue" --argjson c "$comments" --argjson r "$refs" \
  '$i + {comments: $c, cross_refs: $r}'
