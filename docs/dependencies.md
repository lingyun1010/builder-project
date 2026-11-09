# Dependencies and fallbacks

builder-project only orchestrates. It does not bundle other people's skills. For each stage, here is what to use and what to do if you do not have it. Check each skill's own licence and install instructions before use.

| Stage | Skill | If you do not have it |
| --- | --- | --- |
| 2 Think | `research` | Read the primary source yourself; write findings in a markdown file with the source URL beside each claim. |
| 2 Think | `grill-with-docs` | Ask Claude to question your plan one decision at a time and write each answer into `GLOSSARY.md` or a decision note. |
| 2 Think | `prototype` | Build a throwaway page or script for the one open question, then delete it. |
| 3 Map | `wayfinder` | Keep a `map.md` with Destination, Notes and one line per resolved decision. |
| 4 Slice | `to-spec`, `to-tickets` | One markdown file per ticket: question, acceptance criteria, `Blocked by:` line. |
| 5 Build | `tdd`, `implement` | Write the failing test first, then the smallest code that passes; commit per ticket. |
| 5 Build | `codebase-design`, `diagnosing-bugs` | Name the seam before coding; reproduce a failing test before fixing a bug. |
| 6 Pre-PR | `simplify`, `security-review` | Claude Code ships both; use the built-in versions. |
| 6 Pre-PR | Impeccable (optional) | Skip the detector; `design-reviewer` still works on its own checklist. |
| 7 Review | `code-review` | Ask for a standards review and a spec review as two separate passes. |
| 8 Merge | `pr` | Write the body from your ticket: what, why, evidence. |
| 9 Post-merge | `retro`, `handoff` | Copy `templates/handoff.md` and fill it in. |

## Other requirements

- `bash` and `python3` for the hooks (no `jq` needed).
- `gh` (GitHub CLI), logged in, for the PR and merge gates.
- The review agents list browser tools named `mcp__Claude_Browser__*`. They exist in the Claude desktop app's built-in browser. Elsewhere, edit the `tools:` line of each agent to the browser tools you have.
