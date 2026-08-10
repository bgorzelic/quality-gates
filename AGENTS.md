# Quality Gates

## What this is

Quality Gates is a Bash-based installer and template collection that adds three layers of automated quality enforcement to projects: Claude Code hooks, local git hooks, and GitHub Actions CI. It also provides a project scaffolder and a `/repo-polish` Claude Code command for existing repositories.

## Setup / install

Prerequisites are Git 2.20+, `jq`, and Claude Code. Python project scaffolding additionally requires `pre-commit`; tools such as gitleaks, Lefthook, ruff, mypy, bandit, ESLint, Prettier, TypeScript, and Trivy are optional or template-specific.

Clone the repository and run the installer:

```bash
git clone https://github.com/bgorzelic/quality-gates.git ~/dev/quality-gates
cd ~/dev/quality-gates
./install.sh
```

The installer writes hooks and commands under `~/.claude`, shared templates under `~/dev/.templates/_shared`, the scaffolding script under `~/dev/scripts`, and documentation under `~/dev/docs`. Review `install.sh` before running it when those destinations matter.

## Build / test / lint

There is no build step or single local verification command. CI runs these checks from the repository root:

```bash
shellcheck install.sh hooks/*.sh scripts/*.sh
```

YAML templates are validated with Python 3 and PyYAML. Install the parser and run the same validation used by CI:

```bash
python3 -m pip install pyyaml
python3 - <<'EOF'
import glob
import sys

import yaml

files = sorted(
    glob.glob("templates/**/*.yml", recursive=True)
    + glob.glob("templates/**/*.yaml", recursive=True)
)
if not files:
    sys.exit("No YAML templates found under templates/ — check the glob.")

failed = False
for path in files:
    try:
        with open(path) as fh:
            yaml.safe_load(fh)
        print(f"OK   {path}")
    except yaml.YAMLError as exc:
        print(f"FAIL {path}: {exc}", file=sys.stderr)
        failed = True

sys.exit(1 if failed else 0)
EOF
```

## Code style / conventions

- Shell scripts use Bash shebangs and `set -euo pipefail`.
- Quote shell variable expansions and use `[[ ... ]]` for Bash conditionals, matching the existing scripts.
- Shell changes must pass ShellCheck with the repository's CI command above.
- YAML template changes must parse successfully with PyYAML using the CI validation above.
- Keep reusable project assets in `templates/_shared/`; `install.sh` deploys every file in that directory.

No separate formatter configuration or contribution guide was found.

## Working with multiple agents here

This repository can be worked on by multiple parallel Claude Code or Codex agents launched through this machine's `launch-agents` tool. Each agent receives its own git worktree automatically; do not create branches or worktrees manually for that workflow.

On a multi-agent task, check the shared coordination database for existing file claims before editing any file another agent might be touching, and claim files through the coordination mechanism before making overlapping changes.

Recent repository history follows Conventional Commits, including `feat:`, `fix:`, `docs:`, `ci:`, and `chore:` prefixes. Continue that convention and keep commit messages in imperative form.

Never commit secrets or credentials. The current root `.gitignore` covers OS, editor, and temporary files, but it does **not** cover `.env` or credential-file patterns. Confirm and update ignore coverage as appropriate before assuming such files are safe from staging, and inspect staged changes before committing.
