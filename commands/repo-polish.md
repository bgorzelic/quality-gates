You are operating inside an existing GitHub repository. Your job is to perform a "repo polish + documentation cleanup" pass.

Core goal:
- Make this repo look professional, coherent, and maintainable.
- Improve documentation and release hygiene while respecting the repo's actual use case (library, app, CLI, infra, experiments, mono-repo, etc.).
- Do NOT force a one-size-fits-all template. Instead: identify the repo type, then apply a best-practice baseline appropriate to that type.

PROCESS (must follow):

1) Identify repo intent + type (from code + existing docs)
- Determine: app vs library vs CLI vs infra vs research/prototype vs docs-only vs mono-repo
- Summarize the repo in 3-6 sentences in plain English.
- List primary entrypoints (e.g., ./src, ./cmd, ./app, docker-compose, main.py, package.json scripts, etc.).
- Decide what "good documentation" means for this repo type.

2) Repo Audit (report first, then changes)
Create a short "Audit Findings" section with:
- What's missing / stale / misleading
- Documentation gaps
- Broken/unclear setup steps
- Unused files, dead scripts, orphaned docs
- Release hygiene gaps (versioning, changelog, tags, CI, license, security notes)

3) Apply a Conformity Baseline (variable per repo type)
Bring the repo up to a consistent "polished baseline" WITHOUT overbuilding:
- Ensure there is a high-quality README.md that accurately reflects the project.
- Ensure repo structure is understandable (minimal, intentional).
- Ensure installation/run steps are reproducible.
- Ensure config/env vars are documented (and secrets are not committed).
- Ensure contribution/dev workflow is clear if the repo is meant to be maintained.

Conformity baseline guidelines (adapt per repo):
- App/Service: README should emphasize run/deploy, env vars, ops, architecture.
- Library: README should emphasize install, API usage, examples, versioning, compatibility.
- CLI: README should emphasize install, commands, flags, examples, completions.
- Infra: README should emphasize prerequisites, provisioning steps, safety/rollback, environments, state mgmt.
- Prototype/Research: README should clearly label "experimental", include purpose, how to reproduce, known limitations.

4) README.md Requirements (adaptive)
Update README.md to include the sections that make sense for this repo type. Choose from:
- Overview (always)
- Quickstart (always if runnable)
- Installation (if applicable)
- Usage / Examples (if applicable)
- Configuration (env vars / config files)
- Architecture (if non-trivial)
- Development (if intended for contributors)
- Testing (if tests exist)
- Deployment / Operations (services/infra)
- Roadmap / Status (especially prototypes)
- License (always)

If a section does not apply, omit it rather than adding empty boilerplate.

5) Minimal but Real Release Hygiene
Do not add process for process' sake. Add only what fits:
- If this repo is "releaseable": add/normalize CHANGELOG.md + versioning strategy (SemVer if appropriate).
- If this repo is internal/prototype: add a "Status: Experimental / Internal" note and a lightweight changelog section or release notes approach.
- Ensure LICENSE exists or clearly document licensing status.
- Add SECURITY.md only if meaningful; otherwise include a brief "Security" section in README.

6) Structural Cleanup
- Remove obvious junk (obsolete files, duplicate docs, dead scripts) ONLY if safe.
- If unsure, quarantine into `./_archive/` with a note.
- Normalize naming conventions (docs filenames, script names).
- Add `/.gitignore` improvements if missing.

7) CI/CD (optional, only if appropriate)
If the repo has tests/linting and is meant to be maintained, ensure a minimal GitHub Actions workflow exists.
If it's a prototype with no tests, don't invent CI -- just document how to run it.

8) Output: Commit-Ready Plan + Changes
Deliver:
- A concise checklist of changes you made (or will make).
- A diff-style summary per file modified/added.
- Any follow-up recommendations labeled as "Optional".

Hard rules:
- Never misrepresent capabilities in README.
- No generic fluff. Everything must reflect actual repo behavior.
- Prefer clarity and correctness over completeness.
- Keep changes minimal but high-impact.
