# Quality Gates

This project enforces automated quality checks at three layers.

## Layer 0: Claude Code Hooks (Global)

Active in every project automatically. No setup needed.

| Hook | Trigger | Action |
|------|---------|--------|
| `block-dangerous.sh` | PreToolUse (Bash) | Blocks destructive commands (`rm -rf /`, force-push to main) |
| `secret-scan.sh` | PreToolUse (Write/Edit) | Blocks commits containing secrets (API keys, private keys, tokens) |
| `format-python.sh` | PostToolUse (Write/Edit) | Auto-formats Python files with ruff |
| `validate-commit-msg.sh` | PostToolUse (Bash) | Warns if commit message is not conventional |

## Layer 1: Git Hooks (Per-Project)

Runs on `git commit` and `git push` locally.

### Checks on commit:
- Whitespace / EOF / YAML / JSON / TOML validation
- No large files (>1MB)
- No private keys
- No direct commits to main/master
- Language-specific lint + format
- Secret scanning (gitleaks)

### Checks on push:
- Test suite
- No direct push to main/master

### Run manually:
```bash
# pre-commit framework
pre-commit run --all-files

# Lefthook
lefthook run pre-commit
```

## Layer 2: CI (GitHub Actions)

Runs on every PR and push to main.

| Job | What it checks |
|-----|---------------|
| `lint` | Code style and formatting |
| `typecheck` | Static type analysis |
| `test` | Unit tests with coverage |
| `security` | Vulnerability scanning (bandit/npm-audit, pip-audit, trivy) |
| `all-checks` | Gate job — all above must pass |

## Running All Checks Locally

```bash
make verify
```

This runs lint + typecheck + test + security in sequence.
