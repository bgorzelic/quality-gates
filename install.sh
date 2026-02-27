#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing quality-gates..."
echo ""

# --- Deploy Claude Code hooks ---

HOOKS_DIR="$HOME/.claude/hooks"
mkdir -p "$HOOKS_DIR"

for hook in "$SCRIPT_DIR"/hooks/*.sh; do
  name=$(basename "$hook")
  cp "$hook" "$HOOKS_DIR/$name"
  chmod +x "$HOOKS_DIR/$name"
  echo "  Installed hook: $HOOKS_DIR/$name"
done

# --- Deploy templates ---

TEMPLATE_DEST="$HOME/dev/.templates/_shared"
mkdir -p "$TEMPLATE_DEST"

for tmpl in "$SCRIPT_DIR"/templates/_shared/*; do
  name=$(basename "$tmpl")
  cp "$tmpl" "$TEMPLATE_DEST/$name"
  echo "  Installed template: $TEMPLATE_DEST/$name"
done

# --- Deploy scaffolding script ---

SCRIPTS_DIR="$HOME/dev/scripts"
mkdir -p "$SCRIPTS_DIR"
cp "$SCRIPT_DIR/scripts/create-project.sh" "$SCRIPTS_DIR/create-project.sh"
chmod +x "$SCRIPTS_DIR/create-project.sh"
echo "  Installed script: $SCRIPTS_DIR/create-project.sh"

# --- Deploy Claude Code commands ---

COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$COMMANDS_DIR"

for cmd in "$SCRIPT_DIR"/commands/*.md; do
  [[ -f "$cmd" ]] || continue
  name=$(basename "$cmd")
  cp "$cmd" "$COMMANDS_DIR/$name"
  echo "  Installed command: $COMMANDS_DIR/$name (/$(basename "$name" .md))"
done

# --- Deploy docs ---

DOCS_DIR="$HOME/dev/docs"
mkdir -p "$DOCS_DIR"
cp "$SCRIPT_DIR/docs/QUALITY_GATES.md" "$DOCS_DIR/QUALITY_GATES.md"
echo "  Installed doc: $DOCS_DIR/QUALITY_GATES.md"

# --- Update Claude Code settings ---

SETTINGS="$HOME/.claude/settings.json"
if [[ -f "$SETTINGS" ]]; then
  # Check if secret-scan hook already exists
  if ! jq -e '.hooks.PreToolUse[]? | select(.matcher == "Write|Edit")' "$SETTINGS" &>/dev/null; then
    # Add secret-scan PreToolUse entry
    jq '.hooks.PreToolUse += [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/hooks/secret-scan.sh",
        "timeout": 5
      }]
    }]' "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"
    echo "  Added secret-scan hook to settings.json"
  else
    echo "  secret-scan hook already in settings.json (skipped)"
  fi

  # Check if validate-commit-msg hook already exists in Bash PostToolUse
  if ! jq -e '.hooks.PostToolUse[]? | select(.matcher == "Bash") | .hooks[]? | select(.command | contains("validate-commit-msg"))' "$SETTINGS" &>/dev/null; then
    # Append validate-commit-msg to existing Bash PostToolUse entry
    jq '(.hooks.PostToolUse[] | select(.matcher == "Bash") | .hooks) += [{
      "type": "command",
      "command": "~/.claude/hooks/validate-commit-msg.sh",
      "timeout": 5
    }]' "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"
    echo "  Added validate-commit-msg hook to settings.json"
  else
    echo "  validate-commit-msg hook already in settings.json (skipped)"
  fi
else
  echo "  WARNING: $SETTINGS not found. Skipping settings update."
  echo "  You'll need to manually add hook entries. See docs/QUALITY_GATES.md."
fi

echo ""
echo "Installation complete."
echo ""
echo "Installed:"
echo "  - Claude Code hooks (global, active now)"
echo "  - Claude Code commands (/repo-polish)"
echo "  - Project templates (~/dev/.templates/_shared/)"
echo "  - Scaffolding script (~/dev/scripts/create-project.sh)"
echo "  - Documentation (~/dev/docs/QUALITY_GATES.md)"
echo ""
echo "Create a new project:"
echo "  create-project.sh <name> python|node|generic"
echo ""
echo "Polish an existing repo:"
echo "  cd <repo> && /repo-polish"
