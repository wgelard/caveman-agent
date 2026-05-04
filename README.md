# caveman

A VS Code Copilot toolkit: **anvil** agent for evidence-first code verification, **caveman** instruction for ultra-compressed communication, and shared best-practice instructions for C/C++, Python, CMake, and Git.

Inspired by [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) and [burkeholland/anvil](https://github.com/burkeholland/anvil).

## What's Inside

### Agents

| File | Purpose |
|------|---------|
| `anvil.agent.md` | Evidence-first coding agent — pushback, verification cascade, adversarial review, auto-commit |

### Instructions (always-on or auto-load by file type)

| File | Scope | Purpose |
|------|-------|---------|
| `instructions/caveman.instructions.md` | All files | Ultra-compressed communication — ~75% fewer tokens, always active |
| `instructions/cpp-best-practices.instructions.md` | `*.{c,cpp,h,hpp,...}` | Modern C/C++, RAII, clang-format/tidy, GoogleTest |
| `instructions/python-best-practices.instructions.md` | `*.py` | Type hints, uv, ruff, ty, pytest |
| `instructions/cmake-best-practices.instructions.md` | `CMakeLists.txt, *.cmake` | Target-based CMake 3.16+, FetchContent, CTest |
| `instructions/docker-best-practices.instructions.md` | `Dockerfile*, docker-compose*` | Multi-stage builds, minimal images, non-root, security |
| `instructions/github-actions-best-practices.instructions.md` | `.github/workflows/*.yml` | Pinned SHAs, minimal permissions, secret hygiene, caching |
| `instructions/git-best-practices.instructions.md` | All files | Conventional Commits, logical commits, pre-commit hooks |
| `instructions/readme-best-practices.instructions.md` | `README.md` | README structure and guidelines |

Caveman is an always-on instruction that controls **how** the agent talks. Anvil is an agent that controls **how** the agent works on code. The other instruction files auto-load by file type and work with **any** Copilot agent — including anvil.

## Install

### Quick install (recommended)

**Windows (PowerShell):**

```powershell
git clone https://github.com/<owner>/caveman.git
cd caveman
.\install.ps1
```

**macOS / Linux:**

```bash
git clone https://github.com/<owner>/caveman.git
cd caveman
chmod +x install.sh
./install.sh
```

The install script copies files to the right locations for both platforms:

| Target | What gets installed | Where |
|--------|-------------------|-------|
| VS Code | Instructions (as-is) | `~/.config/Code/User/prompts/` (Linux/macOS) or `%APPDATA%\Code\User\prompts\` (Windows) |
| Both | Agent (frontmatter stripped for CLI compat) | `~/.copilot/agents/` (read by both VS Code and CLI) |
| CLI | Instructions (merged into one file) | `~/.copilot/copilot-instructions.md` |
| OpenCode | Agent (OpenCode frontmatter) | `~/.config/opencode/agents/` |
| OpenCode | Instructions (merged into one file) | `~/.config/opencode/AGENTS.md` |
| Project | Instructions (merged, committed) | `./AGENTS.md` in repo root |

VS Code reads both its prompts folder and `~/.copilot/agents/`, so the agent is installed once to avoid duplicates.

The repo-level `AGENTS.md` is committed and auto-read by OpenCode, Claude Code, Gemini CLI, and any AI tool that follows the AGENTS.md convention — no install required for project-level use.

Install a specific target only:

```bash
./install.sh vscode    # VS Code only
./install.sh cli       # Copilot CLI only
./install.sh opencode  # OpenCode only
./install.sh project   # Regenerate repo-level AGENTS.md only
```

```powershell
.\install.ps1 -Target vscode    # VS Code only
.\install.ps1 -Target cli       # Copilot CLI only
.\install.ps1 -Target opencode  # OpenCode only
.\install.ps1 -Target project   # Regenerate repo-level AGENTS.md only
```

Both install and uninstall scripts run a verification check automatically. You can also run it standalone:

```powershell
.\test-install.ps1                  # Verify files are installed
.\test-install.ps1 -Expected absent # Verify files are removed
```

### Uninstall

```powershell
.\uninstall.ps1              # Remove from VS Code, CLI, and OpenCode
.\uninstall.ps1 -Target cli  # CLI only
```

```bash
./uninstall.sh               # Remove from all
./uninstall.sh cli           # CLI only
./uninstall.sh opencode      # OpenCode only
```

### Platform support

| Platform | Agent (anvil) | Instructions (caveman + others) | How to invoke |
|----------|---------------|--------------------------------|---------------|
| **VS Code Copilot Chat** | ✅ Full support | ✅ Auto-load by file type | `@anvil` in chat; caveman always active |
| **GitHub Copilot CLI** | ✅ Global agent | ✅ Global instructions | `copilot --agent=anvil`; caveman always active |
| **OpenCode** | ✅ Global agent | ✅ Global instructions | `@anvil` in TUI; caveman always active |
| **Claude Code / Gemini CLI** | ❌ Not supported | ✅ Via repo-level `AGENTS.md` | Instructions active automatically |

The install script converts frontmatter per platform: VS Code-specific fields (`tools`, `model`, `argument-hint`) are stripped for the Copilot CLI agent; OpenCode agents get `mode`, `permission`, and `description` added. The agent body (system prompt) is preserved for all platforms.

For OpenCode project-level use, `AGENTS.md` at the repo root provides all instructions — no install needed. `.opencode/agents/anvil.md` provides the anvil agent for projects that include this toolkit as a submodule or reference. When you add or modify instruction files, regenerate `AGENTS.md` with `.\install.ps1 -Target project`.

## Caveman — always-on communication style

Caveman is an instruction (not an agent) that's always active. Every Copilot response — including `@anvil` — uses caveman-compressed output by default.

### Intensity Levels

| Level | Command | Style |
|-------|---------|-------|
| **lite** | `/caveman lite` | No filler, full sentences, professional |
| **full** | `/caveman full` | Drop articles, fragments, classic caveman |
| **ultra** | `/caveman ultra` | Max compression, abbreviations, arrows (default) |

Level persists until changed or session ends.

### Code Review

When reviewing code, caveman uses structured one-line findings:

```text
L42: 🔴 bug: user can be null after .find(). Add guard before .email.
L87: 🟡 risk: no retry on 429. Wrap in withBackoff(3).
L120: 🔵 nit: magic number 3600. Extract to TOKEN_TTL_SECONDS.
```

### Turn Off

Say "stop caveman" or "normal mode" to revert to normal speech.

## Anvil — evidence-first coding agent

Verifies code before presenting it. Attacks its own output with adversarial multi-model review. Never shows broken code to the developer.

#### The Anvil Loop

For Medium and Large tasks, anvil runs a full verification pipeline:

1. **Pushback** — Challenges the request at implementation AND requirements level
2. **Git Hygiene** — Checks dirty state, branch, worktree before starting
3. **Baseline Capture** — Records current system state before changes
4. **Implement** — Follows existing patterns, prefers reuse over new abstractions
5. **Verify (The Forge)** — IDE diagnostics → syntax → build → type check → lint → tests → smoke test
6. **Adversarial Review** — Launches independent code-review subagents (different models)
7. **Evidence Bundle** — Verification report with confidence level
8. **Auto-Commit** — Commits with Conventional Commits format

#### Task Sizing

| Size | Trigger | Verification |
|------|---------|-------------|
| **Small** | Typo, rename, config tweak | IDE diagnostics + syntax only |
| **Medium** | Bug fix, feature, refactor | Full cascade + 1 adversarial reviewer |
| **Large** | New feature, multi-file, auth/crypto | Full cascade + 3 reviewers + user confirmation |

#### Risk Classification

- 🟢 Additive changes, tests, docs, config
- 🟡 Modifying business logic, function signatures, DB queries
- 🔴 Auth/crypto/payments, data deletion, schema migrations, public API

#### Usage

```
@anvil optimize the parser module
@anvil refactor the auth middleware
@anvil fix the race condition in the cache layer
```

## Composing Caveman + Anvil

Since caveman is an always-on instruction, invoking `@anvil` automatically gets caveman-compressed output. No extra setup needed.

```text
@anvil fix the bug    ← anvil runs full verification, caveman keeps output terse
```

To get verbose anvil output, say "stop caveman" first.

## License

MIT
