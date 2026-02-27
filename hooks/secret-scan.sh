#!/usr/bin/env bash
set -euo pipefail

# PreToolUse hook: Block writes containing secrets
# Reads tool input JSON from stdin, exits 2 to block.

INPUT=$(cat)

# Extract file path and content from Write or Edit tool input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty')

[[ -z "$CONTENT" ]] && exit 0
[[ -z "$FILE_PATH" ]] && exit 0

# Skip documentation and example files
case "$FILE_PATH" in
  *.md|*.txt|*.example|*.template|*.rst) exit 0 ;;
esac

# Check for secret patterns using individual grep calls for macOS compatibility
check_pattern() {
  local label="$1"
  local pattern="$2"
  if printf '%s\n' "$CONTENT" | grep -qE -e "$pattern" 2>/dev/null; then
    echo "BLOCKED: content contains $label" >&2
    echo "File: $FILE_PATH" >&2
    exit 2
  fi
}

# Token/key patterns
check_pattern "AWS access key"          'AKIA[0-9A-Z]{16}'
check_pattern "private key header"      '-----BEGIN.*PRIVATE KEY-----'
check_pattern "GCP service account"     '"type":.*"service_account"'
check_pattern "Slack bot token"         'xoxb-[0-9]+-[0-9A-Za-z]+'
check_pattern "Slack user token"        'xoxp-[0-9]+-[0-9A-Za-z]+'
check_pattern "GitHub PAT"             'ghp_[0-9A-Za-z]{36}'
check_pattern "GitHub OAuth token"     'gho_[0-9A-Za-z]{36}'
check_pattern "GitHub server token"    'ghs_[0-9A-Za-z]{36}'
check_pattern "OpenAI API key"         'sk-[0-9A-Za-z]{20}T3BlbkFJ[0-9A-Za-z]{20}'

# Assignment patterns (case-insensitive)
check_assignment() {
  local label="$1"
  local pattern="$2"
  if printf '%s\n' "$CONTENT" | grep -iqE -e "$pattern" 2>/dev/null; then
    echo "BLOCKED: content contains $label" >&2
    echo "File: $FILE_PATH" >&2
    exit 2
  fi
}

check_assignment "API key assignment"     '(api_key|api_secret|apikey|apisecret)[[:space:]]*[=:][[:space:]]*["][A-Za-z0-9/+=]{16,}'
check_assignment "secret/token assignment" '(secret_key|private_key|access_token)[[:space:]]*[=:][[:space:]]*["][A-Za-z0-9/+=]{16,}'
check_assignment "password assignment"     '(password|passwd|pwd)[[:space:]]*[=:][[:space:]]*["][^"]{8,}'

exit 0
