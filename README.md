# Quality Gates

**One `./install.sh` gives every project three layers of automated quality enforcement — Claude Code hooks, git hooks, and CI — so secrets, lint failures, and broken tests are caught before they land.**

![Shell](https://img.shields.io/badge/shell-bash-4EAA25?style=flat&logo=gnubash&logoColor=white)
![Release](https://img.shields.io/github/v/release/bgorzelic/quality-gates?style=flat)
![License](https://img.shields.io/github/license/bgorzelic/quality-gates?style=flat)

## The Three Layers

| Layer | Where it runs | What it catches |
|-------|---------------|-----------------|
| **Layer 0 — Claude Code hooks** | Global, every Claude Code session | Secrets in file writes (**blocks**), non-conventional commit messages (warns) |
| **Layer 1 — Git hooks** | Per project, on `git commit` / `git push` | Lint, format, type errors, secret scan — via pre-commit or Lefthook |
| **Layer 2 — CI** | Per project, on every PR and push to main | Full test suite, typecheck, security scanning — via GitHub Actions |

Each layer catches a different failure mode: Layer 0 stops AI-assisted mistakes at the tool-call level, Layer 1 stops local developer mistakes at commit time, Layer 2 stops merge mistakes at review time.

One command deploys all of it:

```console
$ ./install.sh
Installing quality-gates...

  Installed hook: ~/.claude/hooks/secret-scan.sh
  Installed hook: ~/.claude/hooks/validate-commit-msg.sh
  Installed template: ~/dev/.templates/_shared/ci-node.yml
  Installed template: ~/dev/.templates/_shared/ci-python.yml
  ...
  Installed script: ~/dev/scripts/create-project.sh
  Installed command: ~/.claude/commands/repo-polish.md (/repo-polish)
  Installed doc: ~/dev/docs/QUALITY_GATES.md
  Added secret-scan hook to settings.json
  Added validate-commit-msg hook to settings.json

Installation complete.
```

## What Is Quality Gates

A self-enforcing quality system for every new project. Instead of remembering to set up linting, hooks, and CI per repo, you install this once: global Claude Code hooks become active immediately, and the `create-project.sh` scaffolder stamps out new Python/Node/generic projects with git hooks, CI workflows, Makefiles, and gitignores already wired up — first commit included.

For repos that already exist, the bundled `/repo-polish` Claude Code slash command runs an adaptive audit-and-cleanup pass instead.

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

## Prerequisites

| Tool | Needed for | Install |
|------|------------|---------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | Layer 0 hooks, `/repo-polish` | — |
| [jq](https://jqlang.github.io/jq/) | `install.sh` and hook scripts | `brew install jq` |
| [git](https://git-scm.com/) 2.20+ | Everything | — |
| [pre-commit](https://pre-commit.com/) | Python project scaffolding | `pip install pre-commit` |

**Optional** (for specific templates): [gitleaks](https://github.com/gitleaks/gitleaks), [Lefthook](https://github.com/evilmartians/lefthook), [ruff](https://docs.astral.sh/ruff/) / [mypy](https://mypy-lang.org/) / [bandit](https://bandit.readthedocs.io/) for Python, [eslint](https://eslint.org/) / [prettier](https://prettier.io/) / [typescript](https://www.typescriptlang.org/) for Node.

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
