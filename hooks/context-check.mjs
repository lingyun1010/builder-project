#!/usr/bin/env node
// UserPromptSubmit hook: when the conversation context gets large, tell the
// user and ask Claude to offer a handoff before continuing.
// Thresholds (tokens) can be overridden with CONTEXT_WARN_TOKENS and
// CONTEXT_WARN_STEP. Warns once per step per session, so it does not nag.
// Needs Node 18+. Reads token usage from the session transcript.
import { openSync, readSync, fstatSync, closeSync, readFileSync, writeFileSync, mkdirSync } from 'node:fs'
import { join } from 'node:path'
import { tmpdir } from 'node:os'

const WARN_AT = Number(process.env.CONTEXT_WARN_TOKENS ?? 150000)
const STEP = Number(process.env.CONTEXT_WARN_STEP ?? 50000)
const TAIL_BYTES = 2 * 1024 * 1024

const input = JSON.parse(readFileSync(0, 'utf8') || '{}')
const { transcript_path: transcriptPath, session_id: sessionId = 'unknown' } = input
if (!transcriptPath) process.exit(0)

function readTail(path) {
  const fd = openSync(path, 'r')
  try {
    const { size } = fstatSync(fd)
    const length = Math.min(size, TAIL_BYTES)
    const buffer = Buffer.alloc(length)
    readSync(fd, buffer, 0, length, size - length)
    return buffer.toString('utf8')
  } finally {
    closeSync(fd)
  }
}

let tokens = 0
const lines = readTail(transcriptPath).split('\n')
for (let i = lines.length - 1; i >= 0; i--) {
  if (!lines[i].includes('"usage"')) continue
  try {
    const usage = JSON.parse(lines[i])?.message?.usage
    if (!usage) continue
    tokens = (usage.input_tokens ?? 0) + (usage.cache_read_input_tokens ?? 0) + (usage.cache_creation_input_tokens ?? 0)
    break
  } catch {
    // first line of the tail may be a partial record
  }
}
if (tokens < WARN_AT) process.exit(0)

const level = Math.floor((tokens - WARN_AT) / STEP)
const stateDir = join(tmpdir(), 'claude-context-check')
const stateFile = join(stateDir, `${sessionId.replace(/[^\w-]/g, '')}.json`)
let lastLevel = -1
try { lastLevel = JSON.parse(readFileSync(stateFile, 'utf8')).level } catch {}
if (level <= lastLevel) process.exit(0)
mkdirSync(stateDir, { recursive: true })
writeFileSync(stateFile, JSON.stringify({ level, tokens }))

const k = Math.round(tokens / 1000)
process.stdout.write(JSON.stringify({
  systemMessage: `Context is about ${k}k tokens. Consider a handoff and a new window.`,
  hookSpecificOutput: {
    hookEventName: 'UserPromptSubmit',
    additionalContext: `The conversation context is about ${k}k tokens, which makes every turn expensive. Before working on the user's message, tell the user this in one or two sentences (in the language they are using) and ask whether they want to save a handoff now (run /handoff if it is installed, otherwise fill in .claude/handoff.md from the template) and continue in a new window, or keep going in this window. If they already answered this question earlier in this conversation at a lower token count, ask again briefly; if they say keep going, proceed with their message.`,
  },
}))
