#!/bin/bash
source "$(dirname "$0")/lib.sh"
only_if 'gh pr merge'
nudge PostToolUse "Post-merge (stage 9): switch to main, re-run the tests and the smoke test, close the ticket, update the map, name the next ticket. Ask: is main green, and is the map updated?"
