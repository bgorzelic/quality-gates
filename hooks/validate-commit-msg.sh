#!/usr/bin/env bash
set -euo pipefail

# PostToolUse hook: Warn on non-conventional commit messages
# Reads tool input JSON from stdin. PostToolUse cannot block, only warn.

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

[[ -z "$COMMAND" ]] && exit 0

# Only check git commit commands
echo "$COMMAND" | grep -q 'git commit' || exit 0

# Extract commit message from -m flag
# Handle both 'git commit -m "msg"' and heredoc patterns
MSG=""

# Try -m "message" pattern
MSG=$(echo "$COMMAND" | sed -n 's/.*-m[[:space:]]*"\([^"]*\)".*/\1/p')

# Try -m 'message' pattern if no match
if [[ -z "$MSG" ]]; then
  MSG=$(echo "$COMMAND" | sed -n "s/.*-m[[:space:]]*'\([^']*\)'.*/\1/p")
fi

# Try heredoc pattern (cat <<'EOF' ... EOF)
if [[ -z "$MSG" ]]; then
  MSG=$(echo "$COMMAND" | sed -n '/<<.*EOF/,/EOF/p' | grep -v 'EOF' | grep -v '<<' | sed 's/^[[:space:]]*//' | head -1)
fi

[[ -z "$MSG" ]] && exit 0

# Get first line only
FIRST_LINE=$(echo "$MSG" | head -1 | sed 's/^[[:space:]]*//')

# Conventional commit pattern: type(scope)?: description
VALID_TYPES="feat|fix|refactor|docs|chore|test|style|perf|ci|build|revert"
if ! echo "$FIRST_LINE" | grep -qE "^($VALID_TYPES)(\([a-zA-Z0-9._-]+\))?(!)?:[[:space:]].+"; then
  echo "WARNING: Commit message does not follow conventional format." >&2
  echo "Expected: <type>[optional scope]: <description>" >&2
  echo "Types: $VALID_TYPES" >&2
  echo "Got: $FIRST_LINE" >&2
fi

exit 0
