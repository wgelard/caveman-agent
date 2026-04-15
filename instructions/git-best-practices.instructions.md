---
description: "Git best practices: Conventional Commits, logical commits, branch strategy, git hygiene, commit message format, pre-commit hooks. Use when working with git, commits, branches, PRs, or version control."
---

## Logical Commits

- One commit = one logical change. No "fix everything" commits.
- Separate refactoring from feature work. Refactor first, then add feature.
- Separate formatting changes from logic changes.
- If a commit needs "and" in its description, it should be two commits.
- Use `git add -p` (patch mode) to stage partial files when needed.
- Commit early, commit often. Small commits are easier to review and revert.

## Commit Messages — Conventional Commits

Follow [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>[optional scope][!]: <subject>

[optional body]

[optional footer(s)]
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`.

**Rules**:
- Subject: imperative mood, lowercase, no period, max 50 chars.
- Body: wrap at 72 chars. Explain **why**, not what (the diff shows what).
- Footer: `BREAKING CHANGE: <description>`, issue refs (`Closes #123`).
- Breaking change shorthand: append `!` after type/scope — e.g. `feat(api)!: remove v1 endpoints`.

**Good**:
```
feat(parser): add support for nested expressions

Previous parser rejected nested parentheses beyond depth 3.
Recursive descent now handles arbitrary depth.

Closes #42
```

```
fix(auth)!: require token refresh for expired sessions

BREAKING CHANGE: clients must handle 401 and refresh token.
```

**Bad**:
```
Fixed stuff
Updated files
WIP
misc changes
feat: did a bunch of things and also fixed some bugs
```

## Branch Strategy

- `main`/`master`: always deployable.
- Feature branches: `feat/<short-description>` or `fix/<short-description>`.
- Keep branches short-lived. Merge often.
- Rebase feature branch on main before merge to keep history clean.
- Use `git rebase -i` to squash WIP commits before PR.

## Git Hygiene

- Never commit secrets, credentials, API keys. Use `.gitignore` and `.env`.
- Write meaningful `.gitignore` — OS files, build artifacts, IDE config, venv, `build/`, `__pycache__/`, `.venv/`.
- Tag releases with semver: `git tag -a v1.2.0 -m "Release 1.2.0"`.
- Use `git stash` for quick context switches, not WIP commits.
- Review `git diff --staged` before every commit.

## Pre-commit Hooks

Use [pre-commit](https://pre-commit.com/) to enforce quality gates before every commit:
- Install: `uvx pre-commit install` (sets up git hooks) or `uv add --dev pre-commit`.
- Config file: `.pre-commit-config.yaml` at repo root.
- Run on all files: `uvx pre-commit run --all-files`.
- Update hooks: `uvx pre-commit autoupdate`.

Recommended hooks for a C++/Python/CMake project:
```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.11.0
    hooks:
      - id: ruff          # lint
        args: [--fix]
      - id: ruff-format   # format

  - repo: https://github.com/pre-commit/mirrors-clang-format
    rev: v19.1.0
    hooks:
      - id: clang-format
        types_or: [c, c++]

  - repo: https://github.com/commitizen-tools/commitizen
    rev: v4.4.0
    hooks:
      - id: commitizen     # enforce Conventional Commits
```

- Always commit `.pre-commit-config.yaml` to the repo.
- CI should also run `pre-commit run --all-files` to catch skipped hooks.
