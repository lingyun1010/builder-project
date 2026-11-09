#!/bin/bash
# SessionStart nudge: name the builder-project stage list and the active hooks.
cat >/dev/null
python3 - <<'PY'
import json
msg = ("builder-project: run /builder-project to name the current stage. Stages: 1 Init, 2 Think, 3 Map, 4 Slice, "
       "5 Build, 6 Pre-PR, 7 Review, 8 Merge, 9 Post-merge. Never advance past a stage whose gate is red. "
       "Hooks active: pre-commit nudge, pre-PR block (needs the tests in .claude/builder.json to pass this session), "
       "pre-merge block (needs CI green and evidence in the PR body), post-merge nudge.")
print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": msg}}))
PY
