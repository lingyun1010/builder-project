# builder-project

A small kit that helps you build with Claude Code like an engineer, not just a prompter. It answers one question: **which method do I use at this point, and how do I stop myself skipping the checks?**

It came from building [DrainWise](#origin), a hackathon project, and the talk "How a Vibe Coder Becomes a Builder".

## What you get

| Part | What it does |
| --- | --- |
| `/builder-project` skill | Names your current stage (1 Init to 9 Post-merge), says which skill to use now, and refuses to move on while a gate is red. Includes a "which skill when" table. |
| `hooks/` | Block dangerous git commands; block `gh pr create` until your tests passed this session; block `gh pr merge` unless CI is green and the PR body has evidence; nudge you before commits and after merges. |
| `agents/` | Four read-only reviewers: `smoke-tester`, `ui-reviewer`, `ux-reviewer`, `design-reviewer`. |
| `templates/` | `builder.json` (your test commands), `review-gates.md`, `CLAUDE.md`, `handoff.md`. |

## Install

Needs `bash`, `python3` and the GitHub CLI (`gh`). Read the hook scripts first: they run shell commands on your machine.

```bash
./install.sh --dry-run /path/to/your/project   # shows what it would do
./install.sh /path/to/your/project
```

It installs into the project's `.claude/` only, never into `~/.claude`. It never overwrites an existing `builder.json`, `review-gates.md`, `CLAUDE.md` or agent file, and it merges (does not replace) your `settings.json`.

Then edit two files:

1. `.claude/builder.json`: the test commands that must pass before a PR, for example
   `{ "tests": [{ "name": "unit", "match": "npm (run )?test", "run": "npm test" }], "evidence_word": "smoke" }`
2. `docs/review-gates.md`: your blocker rule and main flow.

Start a Claude Code session and type `/builder-project`.

## Honest limits

- **Nudges are advice**: the agent may skip them. **Blocks are enforced** inside Claude Code. **CI on the pull request** is the only check that does not depend on the session. Turn on required checks if your plan allows it.
- The merge gate checks that the PR body contains your evidence word, not that the evidence is good. Read it.
- It orchestrates other skills (`research`, `tdd`, `wayfinder` and more) but does not bundle them. See [docs/skills-i-use.md](docs/skills-i-use.md) for the skills I use at each stage, where to get them and their licences, and [docs/dependencies.md](docs/dependencies.md) for a plain fallback if you lack one.
- The review agents use browser tools from the Claude desktop app. Elsewhere, edit the `tools:` line.
- Tested on macOS with Claude Code. Not tested on Windows.

## Origin

Built over two days for the City of Parramatta hackathon (a drain-blockage planner). The project ran with these hooks, four review agents and 28 tickets. The hooks and agents here are generalised from that project: test commands and flow details moved into config files.

## Licence

MIT. See [LICENSE](LICENSE).
