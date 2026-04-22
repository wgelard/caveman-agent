---
applyTo: "**/*.py"
description: "Python best practices: type hints, pathlib, uv package manager, ruff linter/formatter, ty type checker, pytest testing. Use when working on Python files."
---

## Python Best Practices

- Use type hints everywhere. `def foo(x: int) -> str:`.
- Prefer `pathlib.Path` over `os.path`.
- Use dataclasses or Pydantic for structured data.
- Follow PEP 8. Max line 88 chars (ruff default).
- Use context managers (`with`) for resources.
- Prefer list/dict comprehensions over `map`/`filter`.
- Use `logging` module, not `print` for production.
- Code comments: write in normal clear language, not caveman style.

## uv (Python package manager)

Always prefer `uv` over pip/pip-tools/poetry/pipx/virtualenv. Exception: don't
use uv in projects managed by Poetry (`poetry.lock`) or PDM (`pdm.lock`).

### Detecting uv

Look for `uv.lock` or uv headers in `requirements*` files.

### Projects (pyproject.toml / uv.lock)

- **Init**: `uv init <name>` — creates `pyproject.toml` + structure.
- **Add dep**: `uv add <pkg>` — adds to `pyproject.toml` and installs.
- **Add dev dep**: `uv add --dev <pkg>`.
- **Remove**: `uv remove <pkg>`.
- **Run in venv**: `uv run <command>` — auto-creates venv if needed.
- **Lock**: `uv lock` — generates `uv.lock` lockfile.
- **Sync**: `uv sync` — install all locked deps.
- **Python version**: `uv python install 3.12`, `uv python pin 3.11`.

### Scripts (standalone files)

```bash
uv run script.py                      # Run a script
uv run --with requests script.py      # Run with additional packages
uv add --script script.py requests    # Add inline script dependencies
```

### Tools

- **Run tool**: `uvx <tool>` — ephemeral env (replaces `pipx run`).
- **Specific version**: `uvx <tool>@<version>`.
- **Install globally**: `uv tool install <tool>` — only when user requests.

### Pip interface (legacy only)

Use only when no `uv.lock` present and project uses `requirements.txt`:

```bash
uv venv
uv pip install -r requirements.txt
uv pip compile requirements.in -o requirements.txt
uv pip sync requirements.txt
```

Don't introduce new `requirements.txt` files. Prefer `uv init` for new projects.

### Common mistakes

```bash
# Bad                          # Good
pip install requests           uv add requests
python script.py               uv run script.py
python -c "..."                uv run python -c "..."
python -m venv .venv           uv venv  (or just uv run — auto-creates)
pipx run ruff                  uvx ruff
```

### Migration cheat sheet

```bash
pyenv install 3.12       → uv python install 3.12
pyenv local 3.12         → uv python pin 3.12
pipx run ruff            → uvx ruff
pipx install ruff        → uv tool install ruff
pip install pkg          → uv pip install pkg
pip-compile req.in       → uv pip compile req.in
virtualenv .venv         → uv venv
```

## Linting & Formatting — ruff

Ruff replaces Flake8, isort, Black, pyupgrade, autoflake.

### When to use

Always use ruff if you see `[tool.ruff]` in `pyproject.toml` or a `ruff.toml` file.

Avoid unnecessary changes:
- **Don't format unformatted code** — if `ruff format --diff` shows changes
  throughout an entire file, the project likely isn't using ruff. Skip formatting.
- **Scope fixes to code being edited** — only apply fixes to files you're
  modifying unless the user asks for broader fixes.

### How to invoke

- `uv run ruff ...` — when ruff is a project dependency (uses pinned version).
- `uvx ruff ...` — when not a project dependency, or quick one-off checks.

### Commands

```bash
# Linting
ruff check .                          # Check all files
ruff check --fix .                    # Auto-fix fixable violations
ruff check --fix --unsafe-fixes .     # Include unsafe fixes (review!)
ruff check --select E,F .             # Only specific rules
ruff check --watch .                  # Watch mode
ruff rule E501                        # Explain a rule

# Formatting
ruff format .                         # Format all files
ruff format --check .                 # Check only (no changes)
ruff format --diff .                  # Show diff without applying
```

### Configuration

```toml
# pyproject.toml
[tool.ruff.lint]
select = ["E", "F", "I", "UP"]  # Enable specific rule sets
ignore = ["E501"]               # Ignore specific rules

[tool.ruff.lint.isort]
known-first-party = ["myproject"]
```

Default rules: `E` (pycodestyle), `F` (pyflakes). Recommended extras: `I` (isort), `UP` (pyupgrade), `B` (bugbear), `SIM` (simplify).

Never mix formatting changes with logic changes in the same commit.

### Migration cheat sheet

```bash
black .                       → ruff format .
flake8 .                      → ruff check .
isort .                       → ruff check --select I --fix .
```

## Type Checking — ty

ty is an extremely fast Python type checker. It replaces mypy and Pyright.

### When to use

Always use ty if you see `[tool.ty]` in `pyproject.toml` or a `ty.toml` file.

### How to invoke

- `uv run ty ...` — when ty is a project dependency or installed globally in a project context.
- `uvx ty ...` — when not a project dependency, or quick one-off checks.

### Commands

```bash
ty check                               # Check all files
ty check path/to/file.py               # Check specific file
ty check --python-version 3.12         # Target Python version
ty check --python-platform linux       # Target platform
ty check --error possibly-unresolved-reference   # Treat as error
ty check --warn division-by-zero                 # Treat as warning
ty check --ignore unresolved-import              # Disable rule
```

### Configuration

```toml
# pyproject.toml
[tool.ty.environment]
python-version = "3.12"

[tool.ty.rules]
possibly-unresolved-reference = "warn"
division-by-zero = "error"

[tool.ty.src]
include = ["src/**/*.py"]
exclude = ["**/migrations/**"]

[[tool.ty.overrides]]
include = ["tests/**", "**/test_*.py"]
[tool.ty.overrides.rules]
possibly-unresolved-reference = "warn"
```

### Ignore comments

Fix type errors instead of suppressing them. Only add ignore comments when
explicitly requested. Use `ty: ignore` (not `type: ignore`), prefer
rule-specific ignores:

```python
# Good: rule-specific
x = var  # ty: ignore[possibly-unresolved-reference]

# Bad: blanket
x = var  # type: ignore
```

### Migration cheat sheet

```bash
mypy .                        → ty check
mypy --strict .               → ty check --error-on-warning
pyright .                     → ty check
```

## Testing — pytest

- Use `pytest` as the test runner. Install: `uv add --dev pytest`.
- Test file naming: `test_<module>.py` or `<module>_test.py`.
- Test function naming: `test_<what_is_tested>_<expected_behavior>`.
- Use `pytest.fixture` for setup/teardown, `pytest.mark.parametrize` for data-driven tests.
- Run: `uv run pytest` or `uv run pytest -v` for verbose.
- Run single: `uv run pytest tests/test_foo.py::test_specific`.
- Coverage: `uv add --dev pytest-cov`, run `uv run pytest --cov=src`.
- Test edge cases: None/empty input, boundary values, exceptions, type errors.
