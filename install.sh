#!/bin/bash
# Install builder-project into a project. Project-level only; never touches ~/.claude.
# Usage: ./install.sh [--dry-run] /path/to/project
set -e

DRY=0
if [ "$1" = "--dry-run" ]; then DRY=1; shift; fi
TARGET="${1:-}"
[ -n "$TARGET" ] && [ -d "$TARGET" ] || { echo "Usage: $0 [--dry-run] /path/to/project" >&2; exit 1; }
KIT="$(cd "$(dirname "$0")" && pwd)"
TARGET="$(cd "$TARGET" && pwd)"
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }

run() { if [ "$DRY" = 1 ]; then echo "would: $*"; else "$@"; fi; }
copy_if_missing() { # src dest
  if [ -e "$2" ]; then echo "keep   $2 (exists)"; else echo "create $2"; run mkdir -p "$(dirname "$2")"; run cp "$1" "$2"; fi
}

# 1. hooks and agents (always refreshed: they are the kit's own files)
run mkdir -p "$TARGET/.claude/hooks" "$TARGET/.claude/agents" "$TARGET/.claude/skills/builder-project"
for f in "$KIT"/hooks/*.sh; do echo "copy   .claude/hooks/$(basename "$f")"; run cp "$f" "$TARGET/.claude/hooks/"; run chmod +x "$TARGET/.claude/hooks/$(basename "$f")"; done
for f in "$KIT"/agents/*.md; do copy_if_missing "$f" "$TARGET/.claude/agents/$(basename "$f")"; done
echo "copy   .claude/skills/builder-project"
run cp "$KIT/skills/builder-project/SKILL.md" "$TARGET/.claude/skills/builder-project/SKILL.md"

# 2. per-project files (never overwritten)
copy_if_missing "$KIT/templates/builder.json" "$TARGET/.claude/builder.json"
copy_if_missing "$KIT/templates/review-gates.md" "$TARGET/docs/review-gates.md"
copy_if_missing "$KIT/templates/CLAUDE.md.template" "$TARGET/CLAUDE.md"

# 3. state folder stays out of git
if ! grep -qs '^\.claude/\.state/' "$TARGET/.gitignore"; then
  echo "append .gitignore: .claude/.state/"
  [ "$DRY" = 1 ] || printf '\n.claude/.state/\n' >> "$TARGET/.gitignore"
fi

# 4. merge hooks into .claude/settings.json without removing anything already there
echo "merge  .claude/settings.json"
if [ "$DRY" != 1 ]; then
python3 - "$TARGET/.claude/settings.json" "$KIT/templates/settings.hooks.json" <<'PY'
import json, os, sys
path, tpl = sys.argv[1:3]
cur = json.load(open(path)) if os.path.exists(path) else {}
new = json.load(open(tpl))["hooks"]
hooks = cur.setdefault("hooks", {})
for event, groups in new.items():
    existing = hooks.setdefault(event, [])
    have = {h.get("command") for g in existing for h in g.get("hooks", [])}
    for g in groups:
        keep = [h for h in g["hooks"] if h["command"] not in have]
        if keep:
            existing.append({**g, "hooks": keep})
json.dump(cur, open(path, "w"), indent=2)
open(path, "a").write("\n")
PY
fi

echo
echo "Done. Next: edit .claude/builder.json (your test commands) and docs/review-gates.md, then run /builder-project."
