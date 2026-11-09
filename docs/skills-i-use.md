# Skills I use

builder-project does not bundle other people's skills. This page lists the ones I use at each stage, what each is for, and where to get it. Check each source's own README and licence before you install.

## Where they come from

| Source | Licence | What |
| --- | --- | --- |
| [mattpocock/skills](https://github.com/mattpocock/skills) | MIT | Most of the skills below |
| [pbakaus/impeccable](https://github.com/pbakaus/impeccable) | Apache-2.0 | Design critique and a UI detector (optional) |
| Claude Code built-ins | n/a | `simplify`, `security-review` |
| This repo | MIT | `builder-project` |

Install the mattpocock set as a plugin. The upstream README gives this command for Claude Code (check it for the current one):

```bash
claude plugin install mattpocock-skills@claude-plugins-official
```

Impeccable is separate and large, so it is not copied into projects. Read its README first, then install it globally, never into your repo.

## By stage

| Stage | Skill | What it is for | Source |
| --- | --- | --- | --- |
| 1 Init | `setup-matt-pocock-skills` | Configure the issue tracker, triage labels and domain docs | mattpocock |
| 1 Init | `setup-pre-commit` | Husky, lint-staged, type check and tests on commit | mattpocock |
| 1 Init | `git-guardrails-claude-code` | Block dangerous git commands (this kit's hook does the same job) | mattpocock |
| 2 Think | `research` | Read primary sources and save findings to a file | mattpocock |
| 2 Think | `grill-with-docs` | Ask one decision at a time and write the glossary | mattpocock |
| 2 Think | `prototype` | Build a throwaway page to answer one design question | mattpocock |
| 3 Map | `wayfinder` | One map file plus one ticket per open decision | mattpocock |
| 4 Slice | `to-spec`, `to-tickets` | Turn decisions into a spec, then thin tickets with blocking edges | mattpocock |
| 5 Build | `tdd` | Failing test first, then the smallest code | mattpocock |
| 5 Build | `codebase-design` | Name the seam between modules before coding | mattpocock |
| 5 Build | `implement`, `implement-spec` | Build a ticket or a spec | mattpocock |
| 5 Build | `diagnosing-bugs` | Reproduce, find the cause, then fix | mattpocock |
| 6 Pre-PR | `simplify` | Trim reuse and needless complexity in changed code | Claude Code |
| 6 Pre-PR | `security-review` | Check pending changes for security problems | Claude Code |
| 6 Pre-PR | `impeccable` (optional) | Design critique rubric and a detect command | Impeccable |
| 7 Review | `code-review` | Standards review and spec review in parallel | mattpocock |
| 8 Merge | `pr` | Write the PR body | mattpocock |
| 9 Post-merge | `retro`, `handoff` | Close a milestone; save state for a fresh window | mattpocock |
| Any | `builder-project` | Name the stage and say which skill to use next | this repo |

## Not here on purpose

I have other skills installed (writing, teaching, personal helpers). They are not part of this workflow, so they are not listed.

If a skill is missing, `docs/dependencies.md` gives a plain fallback for each stage.
