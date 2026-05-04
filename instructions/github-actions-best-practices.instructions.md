---
applyTo: "**/.github/workflows/*.{yml,yaml},**/.github/actions/**"
description: "GitHub Actions best practices: pin action SHAs, minimal permissions, secret hygiene, caching, reusable workflows. Use when working on GitHub Actions workflow files."
---

## GitHub Actions Best Practices

### Security

- **Pin actions to full commit SHA**, not tags (`@v4` can be force-pushed):
  ```yaml
  uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2
  ```
- Set `permissions` at job or workflow level — default to read-only, add only what's needed:
  ```yaml
  permissions:
    contents: read
    pull-requests: write
  ```
- Never print secrets to logs. `echo "$SECRET"` → masked, but `echo ${SECRET:0:4}` is not.
- Use `${{ secrets.NAME }}` — never hardcode credentials.
- Beware `pull_request_target`: it runs with repo secrets on PRs from forks. Treat any input as untrusted.
- Sanitize `github.event.*` inputs used in `run:` steps to prevent script injection:
  ```yaml
  # Bad
  run: echo "${{ github.event.pull_request.title }}"
  # Good
  env:
    PR_TITLE: ${{ github.event.pull_request.title }}
  run: echo "$PR_TITLE"
  ```

### Permissions model

Explicitly declare permissions — never rely on defaults:
```yaml
permissions:
  contents: read        # checkout
  id-token: write       # OIDC for cloud auth
  packages: write       # push to GHCR
```

### Caching

- Cache language-level deps with `actions/cache` or built-in cache flags:
  ```yaml
  - uses: actions/setup-node@<sha>
    with:
      node-version: '22'
      cache: 'npm'
  ```
- Cache key on lockfile hash: `key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}`
- Use `restore-keys` for partial cache hits on dependency changes.

### Job structure

- Fail fast: put cheap checks (lint, type-check) before expensive ones (build, test).
- Use `continue-on-error: true` sparingly — only for non-blocking quality checks.
- Set `timeout-minutes` on every job to prevent runaway bills.
- Use `concurrency` to cancel superseded runs on the same branch:
  ```yaml
  concurrency:
    group: ${{ github.workflow }}-${{ github.ref }}
    cancel-in-progress: true
  ```

### Matrix builds

```yaml
strategy:
  fail-fast: false
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    node: ['20', '22']
```
Use `fail-fast: false` when you want full matrix results even after a partial failure.

### Reusable workflows

- Extract common pipelines into `.github/workflows/reusable-*.yml` with `workflow_call` trigger.
- Pass secrets explicitly: `secrets: inherit` is convenient but leaks all secrets to the callee.
- Use `inputs` and `outputs` to keep reusable workflows self-documenting.

### Artifacts and outputs

- Upload artifacts with explicit retention: `retention-days: 7`.
- Use job outputs (`$GITHUB_OUTPUT`) instead of environment files for passing values between steps:
  ```bash
  echo "version=$(cat VERSION)" >> "$GITHUB_OUTPUT"
  ```
- Never use `set-output` (deprecated) or `::set-output::`.

### General

- Use `if: github.event_name == 'push' && github.ref == 'refs/heads/main'` to gate deploys.
- Prefer `ubuntu-latest` (cheapest); pin to `ubuntu-24.04` when you need stability.
- Use composite actions (`.github/actions/<name>/action.yml`) to DRY up repeated step sequences.
- Add `workflow_dispatch` to any workflow you may need to run manually.
