---
applyTo: "**/*.py"
description: "Python best practices: type hints, pathlib, uv package manager, ruff linter/formatter, pytest testing. Use when working on Python files."
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

Always prefer `uv` over pip/pip-tools/poetry/pipx/virtualenv:
- **Init project**: `uv init <name>` — creates `pyproject.toml` + structure.
- **Add dependency**: `uv add <pkg>` — adds to `pyproject.toml` and installs.
- **Add dev dependency**: `uv add --dev <pkg>`.
- **Remove dependency**: `uv remove <pkg>`.
- **Run command in venv**: `uv run <command>` — auto-creates venv if needed.
- **Run Python**: `uv run python script.py` — runs in managed venv without manual activation.
- **Lock deps**: `uv lock` — generates `uv.lock` lockfile.
- **Sync env**: `uv sync` — install all locked deps.
- **Install Python**: `uv python install 3.12`.
- **Pin Python version**: `uv python pin 3.11`.
- **Run tool**: `uvx <tool>` — run CLI tool in ephemeral env (replaces `pipx run`).
- **Install tool globally**: `uv tool install <tool>`.
- **Inline script deps**: `uv add --script script.py <pkg>` — add deps in script metadata.
- **pip compat**: `uv pip install`, `uv pip compile` work as drop-in replacements.
Never use `pip install` directly. Always `uv add` or `uv pip install`.

## Linting & Formatting — ruff

- Use `ruff` for both linting and formatting (replaces flake8, isort, black).
- Lint: `uvx ruff check .` or `uvx ruff check --fix .` (auto-fix).
- Format: `uvx ruff format .`.
- Config goes in `pyproject.toml` under `[tool.ruff]`.
- Default rules: `E` (pycodestyle), `F` (pyflakes). Recommended extras: `I` (isort), `UP` (pyupgrade), `B` (bugbear), `SIM` (simplify).
- Never mix formatting changes with logic changes in the same commit.

## Testing — pytest

- Use `pytest` as the test runner. Install: `uv add --dev pytest`.
- Test file naming: `test_<module>.py` or `<module>_test.py`.
- Test function naming: `test_<what_is_tested>_<expected_behavior>`.
- Use `pytest.fixture` for setup/teardown, `pytest.mark.parametrize` for data-driven tests.
- Run: `uv run pytest` or `uv run pytest -v` for verbose.
- Run single: `uv run pytest tests/test_foo.py::test_specific`.
- Coverage: `uv add --dev pytest-cov`, run `uv run pytest --cov=src`.
- Test edge cases: None/empty input, boundary values, exceptions, type errors.
