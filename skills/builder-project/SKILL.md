---
name: builder-project
description: Guided checklist from empty folder to merged feature, with a gate at every stage. Type /builder-project to start or resume; it names the current stage, says which skill to use now, and refuses to move past a red gate.
disable-model-invocation: true
---

# Builder project

A guide, not an automation. Say which stage you are in, run its skills, check its gate, move on. Never advance past a stage whose gate is red.

On start: read the repo (git status, `.scratch/` or the tracker, CLAUDE.md, open PRs, `.claude/builder.json`) and name the current stage. Show the stage list with a mark on the current one, then run that stage.

## Stages

Each line: what to do, which skill helps, and the **gate** (an observable condition to leave the stage). If a skill is not installed, use the plain fallback in `docs/dependencies.md`.

1. **Init**: git, `.gitignore`, CLAUDE.md (`/init`), pre-commit hook, CI that runs lint, type check and tests on every PR, the hooks in this kit, `.claude/builder.json` with your test commands. **Gate:** first commit exists, a dummy commit triggers the hook, CI is green on a dummy PR.
2. **Think**: `research` for facts, `grill-with-docs` for decisions (writes GLOSSARY.md and ADRs), `prototype` for design questions. **Gate:** every open question is an answered decision or a ticket.
3. **Map** (only if the work is larger than one session): `wayfinder`. **Gate:** every decision ticket is resolved or explicitly deferred.
4. **Slice**: `to-spec`, then `to-tickets` (thin tickets with blocking edges). **Gate:** each ticket fits one branch and one PR.
5. **Build** (per ticket, branch `feat/<ticket>`): `codebase-design` for the seam, `implement` with `tdd`; `diagnosing-bugs` when red for the wrong reason. **Gate:** full test suite green; each new seam has an integration test.
6. **Pre-PR**: `simplify`, `security-review`, then review agents for the gates in `review-gates.md`. Smoke only when behaviour changed. UI, UX and design reviewers only after asking the user. **Gate:** every applicable gate ticked with evidence.
7. **Review**: `code-review`, fix findings. **Gate:** no open finding above nit.
8. **Merge**: `pr` for the body, CI green, squash. **Gate:** CI green on the PR (not just local tests); branch deleted.
9. **Post-merge**: tests on main, close the ticket, update the map, `retro` at a milestone, `handoff` when context is long. **Gate:** main is green and the next ticket is named.

Stages 5 to 9 repeat per ticket. Return to stage 2 when a ticket exposes an undecided question.

## Which skill when (the question this kit exists to answer)

| Situation | Use |
| --- | --- |
| I do not know a fact (API, standard, data source) | `research` |
| I must choose between options | `grill-with-docs`, then write the decision down |
| I want to see two UI or logic options | `prototype` |
| The work is bigger than one session | `wayfinder` |
| I have a plan and need tickets | `to-spec`, `to-tickets` |
| I am about to code | `tdd`, `implement` |
| A test fails and I do not know why | `diagnosing-bugs` |
| I am about to commit | `simplify`, `security-review` |
| I am about to open a PR | review agents, `pr` |
| A PR is open | `code-review` |
| The conversation is long | `handoff` |

## Reminders to say out loud

- Before Merge: "Is the smoke evidence in the PR?" and "Does the PR touch one ticket only?"
- After Merge: "Is main green, and is the map updated?"

## Automation (offer once per project)

Run `install.sh` from this kit, or ask the user which hooks to install and add them to the project's `.claude/settings.json` (never global). A hook cannot run a skill: it either adds a reminder (nudge) or exits with an error (block).

| Hook | Trigger | Effect |
| --- | --- | --- |
| stage-start | SessionStart | nudge: name the stage |
| block-dangerous-git | PreToolUse, Bash | block: reset --hard, force push, branch -D |
| pre-commit-nudge | `git commit` | nudge: run `simplify` and `security-review` |
| pre-pr-create | `gh pr create` | block unless the tests in `builder.json` passed this session |
| pre-merge | `gh pr merge` | block unless CI is green and the PR body has the evidence word |
| post-merge | after `gh pr merge` | nudge: re-run tests, update the map |

Say plainly after installing: nudges are advice the agent may skip, blocks are enforced, and CI on the PR is the only enforcement that does not depend on this session. Record the choice in CLAUDE.md so the next session does not ask again.
