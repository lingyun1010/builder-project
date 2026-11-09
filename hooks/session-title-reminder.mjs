#!/usr/bin/env node
// UserPromptSubmit hook (optional): until this session has called
// set_session_title, remind Claude to give the session a meaningful title.
// Needs Node 18+ and the Claude desktop app, which provides the
// set_session_title tool. Without that tool the reminder would repeat forever,
// so install this one only with: ./install.sh --with-session-title
import { readFileSync } from "node:fs";

let input = {};
try {
  input = JSON.parse(readFileSync(0, "utf8"));
} catch {
  process.exit(0);
}

const transcript = input.transcript_path;
if (transcript) {
  try {
    const text = readFileSync(transcript, "utf8");
    // Match the tool_use record only, not instruction text that mentions the tool.
    if (/"name":"[^"]*set_session_title"/.test(text)) process.exit(0);
  } catch {
    // No transcript yet (first prompt): fall through and remind.
  }
}

process.stdout.write(
  JSON.stringify({
    hookSpecificOutput: {
      hookEventName: "UserPromptSubmit",
      additionalContext:
        'This session has not been renamed yet. As soon as the task is clear, call set_session_title with session_id "self" and a meaningful title (load it with ToolSearch "select:mcp__ccd_session_mgmt__set_session_title" if deferred). If the message is only a greeting, wait for the real task.',
    },
  }),
);
