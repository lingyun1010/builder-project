---
name: handoff
description: Save this conversation's context to the repository so work can continue in a new window without losing information. Use when the user runs /handoff, agrees to a context-size warning, or asks to wrap up and continue in a new window.
---

Goal: a fresh session that reads CLAUDE.md (auto-loaded) plus `.claude/handoff.md` can continue the work with no other context.

## 1. Route durable knowledge to its permanent home first

Do not put things in the handoff file that belong elsewhere. For each item from this conversation, write it where it belongs (edit only if it changed). Look at the repo's CLAUDE.md / AGENTS.md for the project's own locations; the defaults are:

| What | Where |
| --- | --- |
| Product or architecture decisions, resolved open questions, scope changes | The relevant spec under `docs/specs/` (or `docs/`) |
| A phase or PR changed status (started, merged, deployed), or the next step changed | The "Now" section of `STATUS.md` (and the spec's progress table if one exists) |
| New repository rules or workflow agreements | `AGENTS.md` (tool-neutral) or `CLAUDE.md` (Claude-specific) |
| A new security or design pattern that was approved and implemented | `docs/SECURITY_PATTERNS.md` (or the project's pattern doc) |
| How the user likes to work (preferences, corrections) | Claude memory directory, per the memory instructions |

Keep edits minimal and factual. Do not invent decisions the user did not make; mark them as open.

## 2. Write `.claude/handoff.md` (working state only)

Overwrite it with this structure, concise, absolute dates:

```markdown
# Handoff — <YYYY-MM-DD HH:MM>

## Current goal
<one or two sentences>

## Where things are
- Branches: <branch> — <state: committed/pushed/uncommitted, what's on it>
- PRs: <owner/repo#N url> — <CI status, review state>
- Uncommitted changes: <files or "none">

## Done this session
- <bullet per completed unit, with commit SHA where relevant>

## Open questions for the user
- <unresolved decisions, each with the recommended option>

## Next steps
1. <concrete next action, with files to read first>

## Gotchas
- <non-obvious facts discovered that are not yet in docs>
```

Include facts, not narration. Leave out anything already recorded in the docs from step 1; link to them instead.

## 3. Verify and tell the user

- Run `git status --short` and make sure the handoff file reflects it.
- `.claude/handoff.md` must be gitignored (add `.claude/handoff.md` to `.gitignore` if it is not) and never committed. Ask before committing doc changes from step 1 unless the user already asked to commit.
- Reply to the user with: which docs were updated and the handoff file path. The builder-project SessionStart hook (`load-handoff.mjs`) loads `STATUS.md` and `.claude/handoff.md` into the next new window automatically, so the user only needs to open a new window and say what they want to do (for example "continue").
