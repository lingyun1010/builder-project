#!/bin/bash
# Shared helpers for builder-project hooks. Needs only bash and python3 (no jq).
INPUT=$(cat)
# field a.b.c : read a dotted path from the hook's JSON input, empty if missing
field() {
  echo "$INPUT" | python3 -c '
import sys, json
d = json.load(sys.stdin)
for k in sys.argv[1].split("."):
    d = d.get(k, "") if isinstance(d, dict) else ""
print(d)' "$1" 2>/dev/null
}
COMMAND=$(field tool_input.command)
SESSION=$(field session_id)
SESSION=${SESSION:-unknown}
PROJECT="${CLAUDE_PROJECT_DIR:-.}"
STATE_DIR="$PROJECT/.claude/.state"
CONFIG="$PROJECT/.claude/builder.json"
mkdir -p "$STATE_DIR"
# nudge EVENT TEXT : add context for the model, never blocks
nudge() { python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":sys.argv[1],"additionalContext":sys.argv[2]}}))' "$1" "$2"; }
# block TEXT : stop the tool call with an error the model can read
block() { echo "BLOCKED: $1" >&2; exit 2; }
# only_if REGEX : exit quietly unless the command runs that program at a command position.
# The settings "if" filter is not reliable for compound commands, so every script re-checks.
only_if() { echo "$COMMAND" | grep -qE "(^|[;&|] *)$1" || exit 0; }
# cfg KEY DEFAULT : read a top-level string from .claude/builder.json
cfg() {
  [ -f "$CONFIG" ] || { echo "$2"; return; }
  python3 -c '
import sys, json
try:
    v = json.load(open(sys.argv[1])).get(sys.argv[2], sys.argv[3])
except Exception:
    v = sys.argv[3]
print(v)' "$CONFIG" "$1" "$2"
}
