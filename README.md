# caveman-agent

A VS Code Copilot agent toolkit: **caveman** for ultra-compressed communication and **anvil** for evidence-first code verification — backed by shared best-practice instructions for C/C++, Python, CMake, and Git.

Inspired by [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) and [burkeholland/anvil](https://github.com/burkeholland/anvil).

## What's Inside

### Agents

| File | Purpose |
|------|---------|
| `caveman.agent.md` | Communication mode — caveman speech, ASK→PLAN→DO workflow, intensity levels (lite/full/ultra) |
| `anvil.agent.md` | Evidence-first coding agent — pushback, verification cascade, adversarial review, auto-commit |

### Prompts

| File | Purpose |
|------|---------|
| `caveman-review.prompt.md` | Terse code review — one line per finding, ready to paste into a PR |

### Instructions (auto-load by file type)

| File | Purpose |
|------|---------|
| `instructions/cpp-best-practices.instructions.md` | Modern C/C++, RAII, clang-format/tidy, GoogleTest |
| `instructions/python-best-practices.instructions.md` | Type hints, uv, ruff, ty, pytest |
| `instructions/cmake-best-practices.instructions.md` | Target-based CMake 3.16+, FetchContent, CTest |
| `instructions/git-best-practices.instructions.md` | Conventional Commits, logical commits, pre-commit hooks |
| `instructions/readme-best-practices.instructions.md` | README structure and guidelines |

Caveman controls **how** the agent talks. Anvil controls **how** the agent works on code. The instruction files auto-load by file type and work with **any** Copilot agent. All three compose naturally — activate caveman mode, invoke anvil for a code task, and get terse explanations with full verification rigor.

## Install

### Quick install (recommended)

**Windows (PowerShell):**

```powershell
git clone https://github.com/<owner>/caveman-agent.git
cd caveman-agent
.\install.ps1
```

**macOS / Linux:**

```bash
git clone https://github.com/<owner>/caveman-agent.git
cd caveman-agent
chmod +x install.sh
./install.sh
```

The install script copies files to the right locations for both platforms:

| Target | What gets installed | Where |
|--------|-------------------|-------|
| VS Code | Agents, prompts, instructions (as-is) | `~/.config/Code/User/prompts/` (Linux/macOS) or `%APPDATA%\Code\User\prompts\` (Windows) |
| Copilot CLI | Agents (frontmatter stripped) | `~/.copilot/agents/` |
| Copilot CLI | Instructions (merged into one file) | `~/.copilot/copilot-instructions.md` |

Install a specific target only:

```bash
./install.sh vscode    # VS Code only
./install.sh cli       # Copilot CLI only
```

```powershell
.\install.ps1 -Target vscode    # VS Code only
.\install.ps1 -Target cli       # Copilot CLI only
```

### Platform support

| Platform | Agents (caveman, anvil) | Instructions | How to invoke agents |
|----------|------------------------|--------------|---------------------|
| **VS Code Copilot Chat** | ✅ Full support | ✅ Auto-load by file type | `@caveman` or `@anvil` in chat |
| **GitHub Copilot CLI** | ✅ Global agents | ✅ Global instructions | `/agent`, prompt naturally, or `copilot --agent=caveman` |

The install script strips VS Code-specific YAML frontmatter when copying agents to Copilot CLI. Agent behavior (system prompt) is preserved — only VS Code metadata (`tools`, `model`, `argument-hint`) is removed.

Then open Copilot Chat, type `@` and select **caveman** or **anvil**.

## Agents

### Caveman — communication mode

Cuts ~75% of output tokens by speaking like a caveman while keeping full technical accuracy.

### Intensity Levels

| Level | Command | Style |
|-------|---------|-------|
| **lite** | `/caveman lite` | No filler, full sentences, professional |
| **full** | `/caveman full` | Default — drop articles, fragments, classic caveman |
| **ultra** | `/caveman ultra` | Max compression, abbreviations, arrows |

Level persists until changed or session ends. Default is **ultra**.

### Workflow (agent mode)

For non-trivial tasks, caveman follows a 3-step process:

1. **ASK** — Short clarifying questions before acting
2. **PLAN** — Shows a bullet plan, waits for your OK
3. **DO** — Executes step by step with progress tracking

For simple questions, it skips the workflow and answers directly.

### Language

Responds in English by default. Switches to French if you write in French.

### Turn Off

Say "stop caveman" or "normal mode" to revert to normal speech.

### Code Review

Attach a file or use `#changes`, then:

```
@caveman /caveman-review
```

Output is one line per finding, ready to paste into a PR:

```
L42: 🔴 bug: user can be null after .find(). Add guard before .email.
L87: 🟡 risk: no retry on 429. Wrap in withBackoff(3).
L120: 🔵 nit: magic number 3600. Extract to TOKEN_TTL_SECONDS.
```

### Anvil — evidence-first coding agent

Verifies code before presenting it. Attacks its own output with adversarial multi-model review. Never shows broken code to the developer.

#### The Anvil Loop

For Medium and Large tasks, anvil runs a full verification pipeline:

1. **Pushback** — Challenges the request at implementation AND requirements level
2. **Git Hygiene** — Checks dirty state, branch, worktree before starting
3. **Baseline Capture** — Records current system state before changes
4. **Implement** — Follows existing patterns, prefers reuse over new abstractions
5. **Verify (The Forge)** — IDE diagnostics → syntax → build → type check → lint → tests → smoke test
6. **Adversarial Review** — Launches independent code-review subagents (different models)
7. **Evidence Bundle** — SQL-generated verification report with confidence level
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

## Combining Agents

Caveman and anvil compose naturally. Activate caveman mode in your session, then invoke anvil for code tasks — you get terse caveman-style explanations with full anvil verification rigor.

```
@caveman              ← activates caveman communication mode
@anvil fix the bug    ← anvil runs full verification, caveman keeps output terse
```

## License

MIT
