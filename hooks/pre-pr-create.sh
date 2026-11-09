#!/bin/bash
# PreToolUse (Bash): block `gh pr create` until every suite in .claude/builder.json passed this session.
source "$(dirname "$0")/lib.sh"
only_if 'gh pr create'
WORD=$(cfg evidence_word smoke)
if [ ! -f "$CONFIG" ]; then
  nudge PreToolUse "No .claude/builder.json found, so no test suite is required before this PR. Create it (see templates/builder.json in the builder-project kit) so this gate can enforce your tests."
  exit 0
fi
missing=$(python3 - "$CONFIG" "$STATE_DIR" "$SESSION" <<'PY'
import json, os, sys
cfg, state, session = sys.argv[1:4]
out = []
for t in json.load(open(cfg)).get("tests", []):
    if not os.path.exists(os.path.join(state, session + "." + t["name"])):
        out.append(t["name"] + " (" + t.get("run", t["match"]) + ")")
print(", ".join(out))
PY
)
[ -z "$missing" ] || block "tests have not passed in this session. Missing: $missing. Run them, then retry gh pr create."
nudge PreToolUse "Pre-PR gates (review-gates.md): run the smoke test only if a feature was added or its behaviour changed; for layout, style or copy-only changes reuse earlier evidence and say what changed. Ask the user before running the UI, UX or design reviewers. The PR body must contain the word '$WORD' because gh pr merge is blocked without it."
