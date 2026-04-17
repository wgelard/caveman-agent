# caveman-agent

A VS Code Copilot agent that speaks like a caveman — cutting ~75% of output tokens while enforcing C/C++, Python, CMake, and Git best practices.

Inspired by [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman).

## What's Inside

| File | Purpose |
|------|---------|
| `caveman.agent.md` | Agent persona — caveman speech, ASK→PLAN→DO workflow, intensity levels |
| `caveman-review.prompt.md` | Terse code review — one line per finding, ready to paste into a PR |
| `cpp-best-practices.instructions.md` | Modern C/C++, RAII, clang-format/tidy, GoogleTest |
| `python-best-practices.instructions.md` | Type hints, uv, ruff, pytest |
| `cmake-best-practices.instructions.md` | Target-based CMake 3.16+, FetchContent, CTest |
| `git-best-practices.instructions.md` | Conventional Commits, logical commits, pre-commit hooks |
| `readme-best-practices.instructions.md` | README structure and guidelines |

The agent file defines the caveman persona and workflow. The instruction files auto-load by file type — they work with **any** Copilot agent, not just caveman.

## Install

Copy all `.agent.md` and `.instructions.md` files to your VS Code user prompts folder:

**Windows:**

```powershell
Copy-Item *.agent.md, *.prompt.md, *.instructions.md "$env:APPDATA\Code\User\prompts\"
```

**macOS / Linux:**

```bash
cp *.agent.md *.prompt.md *.instructions.md ~/.config/Code/User/prompts/
```

Then open Copilot Chat, type `@` and select **caveman**.

## Usage

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

## License

MIT
