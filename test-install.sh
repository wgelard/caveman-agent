#!/usr/bin/env bash
# Verify caveman toolkit installation.
#
# Usage:
#   ./test-install.sh              # Verify install (files present)
#   ./test-install.sh absent       # Verify uninstall (files removed)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTRUCTIONS_DIR="$SCRIPT_DIR/instructions"
EXPECTED="${1:-present}"

# Detect VS Code prompts folder
if [[ "$OSTYPE" == darwin* ]]; then
    VSCODE_PROMPTS="$HOME/Library/Application Support/Code/User/prompts"
else
    VSCODE_PROMPTS="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User/prompts"
fi

COPILOT_AGENTS_DIR="$HOME/.copilot/agents"
COPILOT_INSTRUCTIONS="$HOME/.copilot/copilot-instructions.md"

pass=0
fail=0

check_file() {
    local path="$1"
    local label="$2"

    if [[ "$EXPECTED" == "present" ]]; then
        if [ -f "$path" ]; then
            echo "    ✅ $label"
            ((pass++))
        else
            echo "    ❌ $label — MISSING"
            ((fail++))
        fi
    else
        if [ ! -f "$path" ]; then
            echo "    ✅ $label — removed"
            ((pass++))
        else
            echo "    ❌ $label — STILL EXISTS"
            ((fail++))
        fi
    fi
}

# --- VS Code instructions ---
echo ""
echo "==> VS Code prompts ($VSCODE_PROMPTS)"

for f in "$INSTRUCTIONS_DIR"/*.instructions.md; do
    [ -f "$f" ] || continue
    name="$(basename "$f")"
    check_file "$VSCODE_PROMPTS/$name" "$name"
done

# Stale files should always be absent
for stale in caveman.agent.md anvil.agent.md caveman-review.prompt.md; do
    if [ -f "$VSCODE_PROMPTS/$stale" ]; then
        echo "    ⚠️  $stale — stale file from old install"
        ((fail++))
    fi
done

# --- Copilot CLI agents ---
echo ""
echo "==> Copilot agents ($COPILOT_AGENTS_DIR)"

for f in "$SCRIPT_DIR"/*.agent.md; do
    [ -f "$f" ] || continue
    name="$(basename "$f" .agent.md)"
    check_file "$COPILOT_AGENTS_DIR/$name.md" "$name.md"
done

# Stale CLI agent
if [ -f "$COPILOT_AGENTS_DIR/caveman.md" ]; then
    echo "    ⚠️  caveman.md — stale agent from old install"
    ((fail++))
fi

# --- Copilot CLI instructions ---
echo ""
echo "==> Copilot CLI instructions"
check_file "$COPILOT_INSTRUCTIONS" "copilot-instructions.md"

# --- Summary ---
echo ""
total=$((pass + fail))
if [ "$fail" -eq 0 ]; then
    echo "==> All $total checks passed ✅"
else
    echo "==> $fail/$total checks failed ❌"
    exit 1
fi
