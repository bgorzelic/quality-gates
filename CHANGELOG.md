# Changelog

All notable changes to this project will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.1.0] - 2026-02-27

### Added
- Claude Code hooks: `secret-scan.sh` (PreToolUse blocker) and `validate-commit-msg.sh` (PostToolUse warning)
- Pre-commit templates for Python, Node, and language-agnostic projects
- Lefthook templates for Python and Node projects
- GitHub Actions CI templates for Python and Node (lint, typecheck, test, security)
- Makefile templates with standard targets (verify, test, lint, format, typecheck, security)
- Gitignore templates with credential patterns
- CODEOWNERS template
- Per-project QUALITY_GATES.md template
- `create-project.sh` scaffolding script with pre-commit/Lefthook selection
- `install.sh` for deploying hooks, templates, commands, and settings to any machine
- `/repo-polish` Claude Code slash command for auditing existing repos
- Master reference documentation at `docs/QUALITY_GATES.md`

### Fixed
- macOS grep compatibility for secret-scan patterns containing leading dashes
- Global `core.hooksPath` conflict with pre-commit install (temporary unset/restore)
