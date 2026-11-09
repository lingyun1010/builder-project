# Review gates

Fill this in once per project. The review agents in `.claude/agents/` read this file, so criteria change in one place.

## Blocker rule

A finding blocks the merge only if it is one of:

1. The main flow cannot be completed (see "Main flow").
2. A console error during the main flow.
3. A hard rule from CLAUDE.md is broken: [list your non-negotiables, for example "simulated data is always labelled", "no secrets in the diff"].

Everything else is a **note**: record it under "Known issues" in the PR body, do not block.

## Main flow

[Numbered steps of the one happy path that must always work, from a clean state.]

## Devices

[Viewports and browsers, for example desktop 1280x800 and phone 375x812.]

## When each agent runs

- `smoke-tester`: only when a feature is added or its behaviour changes. Skip for layout, style, copy and docs-only changes; reuse the last evidence and say what changed.
- `ui-reviewer`, `ux-reviewer`, `design-reviewer`: never automatic. Ask the user first and run only the accepted ones, one at a time.

## Evidence for the PR body

A section headed with your evidence word (default "Smoke") containing: date, viewports, each step with PASS or FAIL, console errors, blockers, notes.

## Known issues (not blockers)

[Existing problems that are notes.]
