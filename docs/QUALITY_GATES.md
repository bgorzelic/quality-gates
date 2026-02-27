# Quality Gates — Master Reference

A three-layer system ensuring code quality across all projects.

## Architecture

```
Layer 0: Claude Code Hooks  (global, always active, no setup)
Layer 1: Git Hooks           (per-project, pre-commit or Lefthook)
Layer 2: CI                  (per-project, GitHub Actions)
```

Each layer catches different failure modes:
- **Layer 0** prevents AI-assisted mistakes (secrets in writes, non-conventional commits)
- **Layer 1** prevents local developer mistakes (lint, format, type errors)
- **Layer 2** prevents merge mistakes (full test suite, security scanning)

---

## Layer 0: Claude Code Hooks

**Location:** `~/.claude/hooks/`
**Config:** `~/.claude/settings.json` → `hooks` section

These run automatically whenever Claude Code performs tool operations. No per-project setup needed.

### Hooks

| Script | Event | Matcher | Behavior |
|--------|-------|---------|----------|
| `block-dangerous.sh` | PreToolUse | Bash | **Blocks** destructive commands (rm -rf /, force-push main) |
| `secret-scan.sh` | PreToolUse | Write\|Edit | **Blocks** files containing secrets (AWS keys, tokens, private keys) |
| `format-python.sh` | PostToolUse | Write\|Edit | Auto-formats Python files with ruff |
| `validate-commit-msg.sh` | PostToolUse | Bash | **Warns** on non-conventional commit messages |
| `agent-heartbeat.sh` | PostToolUse | Bash | Tracks agent activity |
| `notify-pr.sh` | PostToolUse | Bash | Notifies on PR operations |

### Secret Patterns Detected

- AWS access keys (`AKIA...`)
- Private key headers (`-----BEGIN PRIVATE KEY-----`)
- GCP service account JSON (`"type": "service_account"`)
- Slack tokens (`xoxb-`, `xoxp-`)
- GitHub tokens (`ghp_`, `gho_`, `ghs_`)
- OpenAI API keys (`sk-...T3BlbkFJ...`)
- Generic key/secret/token/password assignments

---

## Layer 1: Per-Project Git Hooks

Two frameworks supported. Choose at scaffold time:

### pre-commit (Default for Python)

**Config:** `.pre-commit-config.yaml`

```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files  # manual run
pre-commit autoupdate        # update hook versions
```

### Lefthook (Default for Node)

**Config:** `lefthook.yml`

```bash
brew install lefthook
lefthook install
lefthook run pre-commit  # manual run
```

### What's Checked

| Check | Python | Node |
|-------|--------|------|
| Whitespace/EOF | pre-commit-hooks | pre-commit-hooks |
| YAML/JSON/TOML | pre-commit-hooks | pre-commit-hooks |
| Large files | pre-commit-hooks | pre-commit-hooks |
| Private keys | pre-commit-hooks | pre-commit-hooks |
| No commit to main | pre-commit-hooks | pre-commit-hooks |
| Lint | ruff | eslint |
| Format | ruff-format | prettier |
| Type check | mypy | tsc |
| Security | bandit | — |
| Secrets | gitleaks | gitleaks |

---

## Layer 2: CI (GitHub Actions)

**Config:** `.github/workflows/ci.yml`

Runs on push to main and all PRs. Four jobs plus a gate:

| Job | Python | Node |
|-----|--------|------|
| **lint** | ruff check + format | eslint + prettier |
| **typecheck** | mypy | tsc --noEmit |
| **test** | pytest + coverage | vitest + coverage |
| **security** | bandit, pip-audit, trivy | npm audit, trivy |
| **all-checks** | Gate — all must pass | Gate — all must pass |

---

## Creating a New Project

```bash
# Python project (uses pre-commit by default)
~/dev/quality-gates/scripts/create-project.sh my-api python

# Node project (uses Lefthook by default)
~/dev/quality-gates/scripts/create-project.sh my-app node

# Override hook manager
~/dev/quality-gates/scripts/create-project.sh my-api python --hooks lefthook

# Custom location
~/dev/quality-gates/scripts/create-project.sh my-tool generic -d /tmp
```

This creates the project with:
- `src/`, `tests/`, `.github/workflows/`
- Hook config (`.pre-commit-config.yaml` or `lefthook.yml`)
- CI config, Makefile, .gitignore, CODEOWNERS
- HANDOFF.md, CLAUDE.md, README.md, QUALITY_GATES.md
- Git initialized with hooks installed
- First commit: `chore: initial project scaffold with quality gates`

---

## File Locations

### Global (this repo)
```
~/dev/quality-gates/
├── templates/_shared/     # All template files
├── hooks/                 # Claude Code hook scripts
├── scripts/               # create-project.sh
├── docs/                  # This file
└── install.sh             # Deploy hooks + templates locally
```

### Installed Locations
```
~/.claude/hooks/           # Claude Code hooks (global)
~/.claude/settings.json    # Hook config (global)
~/dev/.templates/_shared/  # Template copies (for other scripts)
```

### Per-Project
```
<project>/
├── .pre-commit-config.yaml  # or lefthook.yml
├── .github/
│   ├── workflows/ci.yml
│   └── CODEOWNERS
├── Makefile
├── .gitignore
├── QUALITY_GATES.md
├── CLAUDE.md
├── HANDOFF.md
└── README.md
```

---

## Updating Hook Versions

### pre-commit hooks
```bash
cd <project>
pre-commit autoupdate
```

### Template versions
Edit files in `~/dev/quality-gates/templates/_shared/` and re-run `install.sh`.

---

## Troubleshooting

### pre-commit not running
```bash
pre-commit install          # reinstall hooks
pre-commit run --all-files  # verify manually
```

### Lefthook not running
```bash
lefthook install            # reinstall hooks
lefthook run pre-commit     # verify manually
```

### Claude Code hook not triggering
1. Check `~/.claude/settings.json` has the hook entry
2. Verify script is executable: `chmod +x ~/.claude/hooks/<script>.sh`
3. Test manually: `echo '{}' | ~/.claude/hooks/<script>.sh`

### Secret scan false positive
The `secret-scan.sh` hook skips `.md`, `.txt`, `.example`, `.template` files. If you need to write a file containing secret-like patterns (e.g., documentation showing key formats), use one of those extensions.

### gitleaks not installed
```bash
brew install gitleaks
```
Lefthook configs skip gitleaks gracefully if not installed. pre-commit downloads its own copy.
