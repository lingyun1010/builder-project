#!/usr/bin/env node
// SessionStart hook: inject the project progress overview (STATUS.md, optional)
// and the handoff file (.claude/handoff.md) into every new session, so you do
// not have to ask for either. Silent when neither file exists. Needs Node 18+.
import { readFileSync, statSync } from 'node:fs'
import { join } from 'node:path'

const projectDir = process.env.CLAUDE_PROJECT_DIR ?? process.cwd()

function read(relativePath) {
  const path = join(projectDir, relativePath)
  try {
    const content = readFileSync(path, 'utf8').trim()
    return content ? { content, modified: statSync(path).mtime } : null
  } catch {
    return null
  }
}

const status = read('STATUS.md')
const handoff = read(join('.claude', 'handoff.md'))
if (!status && !handoff) process.exit(0)

const sections = []

if (status) {
  sections.push(`Project progress overview from STATUS.md (committed). Treat it as the overall status, but it can lag behind GitHub: verify PR and deploy states before acting on them.\n\n<status>\n${status.content}\n</status>`)
}

if (handoff) {
  const ageHours = Math.round((Date.now() - handoff.modified.getTime()) / 36e5)
  sections.push(`A handoff from a previous session exists at .claude/handoff.md (last written ${handoff.modified.toISOString()}, about ${ageHours}h ago). Its contents are below. Verify anything time-sensitive it claims (PR states, branch states, git status) before acting on it; if GitHub shows its goal is already done, say the handoff is stale.\n\n<handoff>\n${handoff.content}\n</handoff>`)
}

const firstReply = handoff
  ? 'In your first reply, briefly tell the user (in the language they use) that you loaded the progress overview and the handoff, and summarize the current goal and next step in one or two lines.'
  : 'In your first reply, briefly tell the user (in the language they use) that you loaded the progress overview (no handoff file exists), and summarize where the project stands and the next step in one or two lines.'

process.stdout.write(JSON.stringify({
  hookSpecificOutput: {
    hookEventName: 'SessionStart',
    additionalContext: `${sections.join('\n\n')}\n\n${firstReply} If the user's first message is about something unrelated, follow their message instead.`,
  },
}))
