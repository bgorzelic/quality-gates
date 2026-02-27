#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TEMPLATE_DIR="${SCRIPT_DIR}/../templates/_shared"

usage() {
  cat <<'USAGE'
Usage: create-project.sh <name> <type> [options]

Arguments:
  name          Project name (used as directory name)
  type          Project type: python | node | generic

Options:
  -d <dir>      Target parent directory (default: ~/dev/projects)
  --hooks <mgr> Hook manager: pre-commit | lefthook (default: python→pre-commit, node→lefthook)
  -h, --help    Show this help

Examples:
  create-project.sh my-api python
  create-project.sh my-app node --hooks pre-commit
  create-project.sh my-tool generic -d /tmp
USAGE
}

# --- Parse arguments ---

NAME=""
TYPE=""
TARGET_DIR="$HOME/dev/projects"
HOOK_MGR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d) TARGET_DIR="$2"; shift 2 ;;
    --hooks) HOOK_MGR="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [[ -z "$NAME" ]]; then
        NAME="$1"
      elif [[ -z "$TYPE" ]]; then
        TYPE="$1"
      else
        echo "Unexpected argument: $1" >&2
        usage >&2
        exit 1
      fi
      shift
      ;;
  esac
done

if [[ -z "$NAME" || -z "$TYPE" ]]; then
  echo "Error: name and type are required." >&2
  usage >&2
  exit 1
fi

if [[ "$TYPE" != "python" && "$TYPE" != "node" && "$TYPE" != "generic" ]]; then
  echo "Error: type must be python, node, or generic." >&2
  exit 1
fi

# Set default hook manager
if [[ -z "$HOOK_MGR" ]]; then
  case "$TYPE" in
    python)  HOOK_MGR="pre-commit" ;;
    node)    HOOK_MGR="lefthook" ;;
    generic) HOOK_MGR="pre-commit" ;;
  esac
fi

PROJECT_DIR="${TARGET_DIR}/${NAME}"

if [[ -d "$PROJECT_DIR" ]]; then
  echo "Error: directory already exists: $PROJECT_DIR" >&2
  exit 1
fi

echo "Creating $TYPE project: $NAME"
echo "  Location: $PROJECT_DIR"
echo "  Hook manager: $HOOK_MGR"
echo ""

# --- Create directory structure ---

mkdir -p "$PROJECT_DIR"/{src,tests,.github/workflows}

# --- Copy templates ---

# Git hooks config
case "$HOOK_MGR" in
  pre-commit)
    case "$TYPE" in
      python)  cp "$TEMPLATE_DIR/pre-commit-python.yaml" "$PROJECT_DIR/.pre-commit-config.yaml" ;;
      node)    cp "$TEMPLATE_DIR/pre-commit-node.yaml" "$PROJECT_DIR/.pre-commit-config.yaml" ;;
      generic) cp "$TEMPLATE_DIR/pre-commit-base.yaml" "$PROJECT_DIR/.pre-commit-config.yaml" ;;
    esac
    ;;
  lefthook)
    case "$TYPE" in
      python) cp "$TEMPLATE_DIR/lefthook-python.yml" "$PROJECT_DIR/lefthook.yml" ;;
      node)   cp "$TEMPLATE_DIR/lefthook-node.yml" "$PROJECT_DIR/lefthook.yml" ;;
      generic)
        echo "Warning: Lefthook with generic type not supported, falling back to pre-commit." >&2
        cp "$TEMPLATE_DIR/pre-commit-base.yaml" "$PROJECT_DIR/.pre-commit-config.yaml"
        HOOK_MGR="pre-commit"
        ;;
    esac
    ;;
esac

# CI config
case "$TYPE" in
  python)  cp "$TEMPLATE_DIR/ci-python.yml" "$PROJECT_DIR/.github/workflows/ci.yml" ;;
  node)    cp "$TEMPLATE_DIR/ci-node.yml" "$PROJECT_DIR/.github/workflows/ci.yml" ;;
  generic) ;; # No CI for generic
esac

# Makefile
case "$TYPE" in
  python)  cp "$TEMPLATE_DIR/Makefile-python" "$PROJECT_DIR/Makefile" ;;
  node)    cp "$TEMPLATE_DIR/Makefile-node" "$PROJECT_DIR/Makefile" ;;
  generic) ;; # No Makefile for generic
esac

# Gitignore
case "$TYPE" in
  python)  cp "$TEMPLATE_DIR/gitignore-python" "$PROJECT_DIR/.gitignore" ;;
  node)    cp "$TEMPLATE_DIR/gitignore-node" "$PROJECT_DIR/.gitignore" ;;
  generic) cp "$TEMPLATE_DIR/gitignore-python" "$PROJECT_DIR/.gitignore" ;; # Use python as base
esac

# Shared files
cp "$TEMPLATE_DIR/CODEOWNERS" "$PROJECT_DIR/.github/CODEOWNERS"
cp "$TEMPLATE_DIR/QUALITY_GATES.md" "$PROJECT_DIR/QUALITY_GATES.md"

# --- Create project files ---

cat > "$PROJECT_DIR/HANDOFF.md" <<EOF
# $NAME — Handoff

## Status
Just scaffolded. No work started.

## Next Steps
- [ ] Define project purpose in README
- [ ] Add dependencies
- [ ] Write first test
EOF

cat > "$PROJECT_DIR/CLAUDE.md" <<EOF
# $NAME

## Project Type
$TYPE

## Quality Gates
See QUALITY_GATES.md for enforcement details.
Run \`make verify\` to check everything locally.

## Conventions
- Use conventional commits (feat|fix|refactor|docs|chore|test)
- All PRs must pass CI before merge
EOF

cat > "$PROJECT_DIR/README.md" <<EOF
# $NAME

> TODO: Add project description.

## Quick Start

\`\`\`bash
make dev      # Install deps + set up git hooks
make verify   # Run all quality checks
make test     # Run tests
make help     # Show all targets
\`\`\`

## Quality Gates

See [QUALITY_GATES.md](QUALITY_GATES.md) for what's enforced and how.
EOF

# --- Initialize git + install hooks ---

cd "$PROJECT_DIR"
git init -b main

# pre-commit refuses to install when core.hooksPath is set globally
# (e.g. by Lefthook shims at ~/.githooks). Temporarily unset it, install
# hooks, then restore.
GLOBAL_HOOKS_PATH=""
if git config --global --get core.hooksPath &>/dev/null; then
  GLOBAL_HOOKS_PATH=$(git config --global --get core.hooksPath)
  git config --global --unset core.hooksPath
fi

restore_hooks_path() {
  if [[ -n "$GLOBAL_HOOKS_PATH" ]]; then
    git config --global core.hooksPath "$GLOBAL_HOOKS_PATH"
  fi
}
trap restore_hooks_path EXIT

# Install hook manager
if [[ "$HOOK_MGR" == "pre-commit" ]]; then
  if command -v pre-commit &>/dev/null; then
    pre-commit install
    echo "pre-commit hooks installed."
  else
    echo "Warning: pre-commit not found. Run 'pip install pre-commit && pre-commit install' to set up hooks."
  fi
elif [[ "$HOOK_MGR" == "lefthook" ]]; then
  if command -v lefthook &>/dev/null; then
    lefthook install
    echo "Lefthook hooks installed."
  else
    echo "Warning: lefthook not found. Run 'brew install lefthook && lefthook install' to set up hooks."
  fi
fi

# Restore global hooks path immediately (trap also covers error cases)
restore_hooks_path
GLOBAL_HOOKS_PATH=""  # Prevent double-restore in trap

# Initial commit
git add -A
git commit -m "$(cat <<'COMMIT'
chore: initial project scaffold with quality gates
COMMIT
)"

echo ""
echo "Project created at: $PROJECT_DIR"
echo ""

# Show make help if Makefile exists
if [[ -f "$PROJECT_DIR/Makefile" ]]; then
  echo "Available targets:"
  make help
  echo ""
fi

echo "Next steps:"
echo "  cd $PROJECT_DIR"
if [[ "$TYPE" == "python" ]]; then
  echo "  uv init  # or create pyproject.toml"
  echo "  make dev"
elif [[ "$TYPE" == "node" ]]; then
  echo "  npm init"
  echo "  make dev"
fi
echo "  git remote add origin <url>"
echo "  git push -u origin main"
