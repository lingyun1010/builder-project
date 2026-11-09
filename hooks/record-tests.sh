#!/bin/bash
# PostToolUse (Bash, runs only on success): remember which test suites from .claude/builder.json passed this session.
source "$(dirname "$0")/lib.sh"
# Never count a suite when "||" could mask a failure.
case "$COMMAND" in *"||"*) exit 0 ;; esac
[ -f "$CONFIG" ] || exit 0
python3 - "$CONFIG" "$COMMAND" "$STATE_DIR" "$SESSION" <<'PY'
import json, os, re, sys
cfg, cmd, state, session = sys.argv[1:5]
for t in json.load(open(cfg)).get("tests", []):
    # the suite counts only when it is the command word of a segment
    if re.search(r"(^|[;&|] *)(" + t["match"] + r")( |$)", cmd):
        open(os.path.join(state, session + "." + t["name"]), "w").close()
PY
exit 0
