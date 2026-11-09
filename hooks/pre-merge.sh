#!/bin/bash
# PreToolUse (Bash): block `gh pr merge` unless CI is green and the PR body contains the evidence word.
source "$(dirname "$0")/lib.sh"
only_if 'gh pr merge'
WORD=$(cfg evidence_word smoke)
PR=$(echo "$COMMAND" | grep -oE 'gh pr merge +[0-9]+' | grep -oE '[0-9]+')
ARGS=${PR:+$PR}
checks=$(gh pr checks $ARGS 2>&1) || block "CI is not green on this PR:
$checks"
body=$(gh pr view $ARGS --json body --jq .body 2>&1)
echo "$body" | grep -qi "$WORD" || block "no '$WORD' evidence found in the PR body. Add it (command output or screenshot) before merging."
exit 0
