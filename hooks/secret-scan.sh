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

# Secret patterns
PATTERNS=(
  'AKIA[0-9A-Z]{16}'                           # AWS access key
  '-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----' # Private key header
  '"type":\s*"service_account"'                  # GCP service account JSON
  'xoxb-[0-9]+-[0-9A-Za-z]+'                   # Slack bot token
  'xoxp-[0-9]+-[0-9A-Za-z]+'                   # Slack user token
  'ghp_[0-9A-Za-z]{36}'                         # GitHub personal access token
  'gho_[0-9A-Za-z]{36}'                         # GitHub OAuth token
  'ghs_[0-9A-Za-z]{36}'                         # GitHub server token
  'sk-[0-9A-Za-z]{20}T3BlbkFJ[0-9A-Za-z]{20}'  # OpenAI API key
)

# Assignment patterns (key=value style secrets)
ASSIGNMENT_PATTERNS=(
  '(api_key|api_secret|apikey|apisecret)\s*[=:]\s*["\x27][A-Za-z0-9/+=]{16,}'
  '(secret_key|private_key|access_token)\s*[=:]\s*["\x27][A-Za-z0-9/+=]{16,}'
  '(password|passwd|pwd)\s*[=:]\s*["\x27][^\s"'\'']{8,}'
)

for pattern in "${PATTERNS[@]}"; do
  if echo "$CONTENT" | grep -qE "$pattern"; then
    echo "BLOCKED: content matches secret pattern: $pattern" >&2
    echo "File: $FILE_PATH" >&2
    exit 2
  fi
done

for pattern in "${ASSIGNMENT_PATTERNS[@]}"; do
  if echo "$CONTENT" | grep -iqE "$pattern"; then
    echo "BLOCKED: content contains potential secret assignment: $pattern" >&2
    echo "File: $FILE_PATH" >&2
    exit 2
  fi
done

exit 0
