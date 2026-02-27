# Quality Gates

Self-enforcing quality gates for every new project. Three layers of automated enforcement:

- **Layer 0:** Claude Code hooks — global, always active, blocks secrets and dangerous commands
- **Layer 1:** Git hooks — per-project lint, format, typecheck, secret scan (pre-commit or Lefthook)
- **Layer 2:** CI — GitHub Actions with lint, typecheck, test, and security jobs

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (for hooks and `/repo-polish` command)
- [jq](https://jqlang.github.io/jq/) — required by `install.sh` and hook scripts (`brew install jq`)
- [pre-commit](https://pre-commit.com/) — for Python project scaffolding (`pip install pre-commit`)
- [git](https://git-scm.com/) 2.20+

**Optional** (for specific templates):
- [gitleaks](https://github.com/gitleaks/gitleaks) — secret scanning in git hooks (`brew install gitleaks`)
- [Lefthook](https://github.com/evilmartians/lefthook) — alternative hook manager for Node projects (`brew install lefthook`)
- [ruff](https://docs.astral.sh/ruff/), [mypy](https://mypy-lang.org/), [bandit](https://bandit.readthedocs.io/) — Python quality tools
- [eslint](https://eslint.org/), [prettier](https://prettier.io/), [typescript](https://www.typescriptlang.org/) — Node quality tools

## Quick Start

```bash
# Clone and install
git clone https://github.com/bgorzelic/quality-gates.git ~/dev/quality-gates
cd ~/dev/quality-gates
./install.sh

# Create a new project
~/dev/scripts/create-project.sh my-api python
~/dev/scripts/create-project.sh my-app node
```

## What Gets Installed

| Component | Location | Purpose |
|-----------|----------|---------|
| Claude Code hooks | `~/.claude/hooks/` | Global secret scan, commit msg validation |
| Claude Code commands | `~/.claude/commands/` | `/repo-polish` slash command |
| Settings update | `~/.claude/settings.json` | Registers hooks with Claude Code |
| Templates | `~/dev/.templates/_shared/` | Pre-commit, Lefthook, CI, Makefile configs |
| Scaffolding script | `~/dev/scripts/create-project.sh` | One-command project setup |
| Documentation | `~/dev/docs/QUALITY_GATES.md` | Master reference |

## Templates Included

| File | Description |
|------|-------------|
| `pre-commit-python.yaml` | ruff, mypy, bandit, gitleaks |
| `pre-commit-node.yaml` | eslint, prettier, tsc, gitleaks |
| `pre-commit-base.yaml` | Language-agnostic (file checks + gitleaks) |
| `lefthook-python.yml` | Same as pre-commit-python, Lefthook format |
| `lefthook-node.yml` | Same as pre-commit-node, Lefthook format |
| `ci-python.yml` | GitHub Actions: ruff, mypy, pytest, bandit, pip-audit, trivy |
| `ci-node.yml` | GitHub Actions: eslint, prettier, tsc, vitest, npm audit, trivy |
| `Makefile-python` | Standard targets: verify, test, lint, format, typecheck, security |
| `Makefile-node` | Same targets for npm/npx |
| `gitignore-python` | Python + credential patterns |
| `gitignore-node` | Node + credential patterns |
| `CODEOWNERS` | Default: `* @bgorzelic` |
| `QUALITY_GATES.md` | Per-project docs explaining what's enforced |

## Scaffolding Script

```bash
create-project.sh <name> <type> [options]

# Types: python, node, generic
# Options:
#   -d <dir>        Target directory (default: ~/dev/projects)
#   --hooks <mgr>   pre-commit or lefthook (default: python->pre-commit, node->lefthook)
```

Creates a fully configured project with git hooks installed and first commit ready.

## Repo Polish Command

For existing repos, use the `/repo-polish` slash command in Claude Code:

```
cd ~/dev/projects/my-existing-repo
/repo-polish
```

This runs an adaptive audit and cleanup pass: identifies repo type, reports findings, then applies a conformity baseline (README, structure, release hygiene, CI) appropriate to that specific repo.

## Updating Templates

Edit files in `templates/_shared/`, then re-run `./install.sh` to deploy changes.

For pre-commit hook version pins, you can also run `pre-commit autoupdate` inside any scaffolded project.

## Full Documentation

See [docs/QUALITY_GATES.md](docs/QUALITY_GATES.md) for the complete reference including architecture, troubleshooting, and file locations.

## License

[MIT](LICENSE)
