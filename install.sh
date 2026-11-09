#!/bin/bash
# Install builder-project into a project. Project-level only; never touches ~/.claude.
# Usage: ./install.sh [--dry-run] [--with-session-title] /path/to/project
#   --with-session-title  also install the session-title reminder (needs the Claude desktop app)
set -e

DRY=0
TITLE=0
while [ "${1:-}" != "" ] && [ "${1#--}" != "$1" ]; do
  case "$1" in
    --dry-run) DRY=1 ;;
    --with-session-title) TITLE=1 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done
TARGET="${1:-}"
[ -n "$TARGET" ] && [ -d "$TARGET" ] || { echo "Usage: $0 [--dry-run] [--with-session-title] /path/to/project" >&2; exit 1; }
KIT="$(cd "$(dirname "$0")" && pwd)"
TARGET="$(cd "$TARGET" && pwd)"
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }
command -v node >/dev/null || echo "warning: node not found; the .mjs hooks (context check, handoff loader) will do nothing until Node 18+ is installed"

run() { if [ "$DRY" = 1 ]; then echo "would: $*"; else "$@"; fi; }
copy_if_missing() { # src dest
  if [ -e "$2" ]; then echo "keep   $2 (exists)"; else echo "create $2"; run mkdir -p "$(dirname "$2")"; run cp "$1" "$2"; fi
}

# 1. hooks and agents (hooks always refreshed: they are the kit's own files)
run mkdir -p "$TARGET/.claude/hooks" "$TARGET/.claude/agents" "$TARGET/.claude/skills/builder-project"
for f in "$KIT"/hooks/*.sh; do echo "copy   .claude/hooks/$(basename "$f")"; run cp "$f" "$TARGET/.claude/hooks/"; run chmod +x "$TARGET/.claude/hooks/$(basename "$f")"; done
for f in "$KIT"/hooks/*.mjs; do
  if [ "$(basename "$f")" = "session-title-reminder.mjs" ] && [ "$TITLE" != 1 ]; then continue; fi
  echo "copy   .claude/hooks/$(basename "$f")"; run cp "$f" "$TARGET/.claude/hooks/"
done
for f in "$KIT"/agents/*.md; do copy_if_missing "$f" "$TARGET/.claude/agents/$(basename "$f")"; done
echo "copy   .claude/skills/builder-project"
run cp "$KIT/skills/builder-project/SKILL.md" "$TARGET/.claude/skills/builder-project/SKILL.md"
echo "copy   .claude/skills/handoff"
run mkdir -p "$TARGET/.claude/skills/handoff"
run cp "$KIT/skills/handoff/SKILL.md" "$TARGET/.claude/skills/handoff/SKILL.md"

# 2. per-project files (never overwritten)
copy_if_missing "$KIT/templates/builder.json" "$TARGET/.claude/builder.json"
copy_if_missing "$KIT/templates/review-gates.md" "$TARGET/docs/review-gates.md"
copy_if_missing "$KIT/templates/CLAUDE.md.template" "$TARGET/CLAUDE.md"

# 3. state folder and handoff file stay out of git
for pat in '.claude/.state/' '.claude/handoff.md'; do
  if ! grep -qsxF "$pat" "$TARGET/.gitignore"; then
    echo "append .gitignore: $pat"
    [ "$DRY" = 1 ] || printf '\n%s\n' "$pat" >> "$TARGET/.gitignore"
  fi
done

# 4. merge hooks into .claude/settings.json without removing anything already there
TEMPLATES="$KIT/templates/settings.hooks.json"
[ "$TITLE" = 1 ] && TEMPLATES="$TEMPLATES $KIT/templates/settings.session-title.json"
echo "merge  .claude/settings.json"
if [ "$DRY" != 1 ]; then
python3 - "$TARGET/.claude/settings.json" $TEMPLATES <<'PY'
import json, os, sys
path, templates = sys.argv[1], sys.argv[2:]
cur = json.load(open(path)) if os.path.exists(path) else {}
hooks = cur.setdefault("hooks", {})
for tpl in templates:
    new = json.load(open(tpl))["hooks"]
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
