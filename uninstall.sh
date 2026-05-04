#!/usr/bin/env bash
# Uninstall caveman toolkit from VS Code Copilot, GitHub Copilot CLI, and OpenCode.
#
# Usage:
#   ./uninstall.sh              # Uninstall from VS Code, Copilot CLI, and OpenCode
#   ./uninstall.sh vscode       # VS Code only
#   ./uninstall.sh cli          # Copilot CLI only
#   ./uninstall.sh opencode     # OpenCode only
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTRUCTIONS_DIR="$SCRIPT_DIR/instructions"

# Detect VS Code prompts folder
if [[ "$OSTYPE" == darwin* ]]; then
    VSCODE_PROMPTS="$HOME/Library/Application Support/Code/User/prompts"
else
    VSCODE_PROMPTS="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User/prompts"
fi

COPILOT_AGENTS_DIR="$HOME/.copilot/agents"
COPILOT_INSTRUCTIONS="$HOME/.copilot/copilot-instructions.md"

uninstall_vscode() {
    echo "==> Uninstalling from VS Code Copilot..."

    # Remove instruction files that we installed
    for f in "$INSTRUCTIONS_DIR"/*.instructions.md; do
        [ -f "$f" ] || continue
        name="$(basename "$f")"
        dest="$VSCODE_PROMPTS/$name"
        if [ -f "$dest" ]; then
            rm -f "$dest"
            echo "    Removed $name"
        fi
    done

    # Remove stale files from older installs
    for stale in caveman.agent.md anvil.agent.md caveman-review.prompt.md; do
        if [ -f "$VSCODE_PROMPTS/$stale" ]; then
            rm -f "$VSCODE_PROMPTS/$stale"
            echo "    Removed stale $stale"
        fi
    done

    echo "==> VS Code uninstall complete"
}

uninstall_cli() {
    echo "==> Uninstalling from GitHub Copilot CLI..."

    # Remove agent files
    for f in "$SCRIPT_DIR"/*.agent.md; do
        [ -f "$f" ] || continue
        name="$(basename "$f" .agent.md)"
        dest="$COPILOT_AGENTS_DIR/$name.md"
        if [ -f "$dest" ]; then
            rm -f "$dest"
            echo "    Removed agent: $name"
        fi
    done

    # Remove stale agent from older installs
    if [ -f "$COPILOT_AGENTS_DIR/caveman.md" ]; then
        rm -f "$COPILOT_AGENTS_DIR/caveman.md"
        echo "    Removed stale caveman agent"
    fi

    # Remove merged instructions file
    if [ -f "$COPILOT_INSTRUCTIONS" ]; then
        rm -f "$COPILOT_INSTRUCTIONS"
        echo "    Removed copilot-instructions.md"
    fi

    echo "==> Copilot CLI uninstall complete"
}

OPENCODE_AGENTS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/agents"
OPENCODE_AGENTS="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/AGENTS.md"

uninstall_opencode() {
    echo "==> Uninstalling from OpenCode..."

    # Remove agent files
    for f in "$SCRIPT_DIR"/*.agent.md; do
        [ -f "$f" ] || continue
        name="$(basename "$f" .agent.md)"
        dest="$OPENCODE_AGENTS_DIR/$name.md"
        if [ -f "$dest" ]; then
            rm -f "$dest"
            echo "    Removed agent: $name"
        fi
    done

    # Remove merged instructions file
    if [ -f "$OPENCODE_AGENTS" ]; then
        rm -f "$OPENCODE_AGENTS"
        echo "    Removed AGENTS.md"
    fi

    echo "==> OpenCode uninstall complete"
}

# --- Main ---
echo ""
echo "caveman uninstaller"
echo ""

target="${1:-all}"
case "$target" in
    vscode)   uninstall_vscode ;;
    cli)      uninstall_cli ;;
    opencode) uninstall_opencode ;;
    all)      uninstall_vscode; echo ""; uninstall_cli; echo ""; uninstall_opencode ;;
    *)        echo "Usage: $0 [all|vscode|cli|opencode]"; exit 1 ;;
esac

echo ""
