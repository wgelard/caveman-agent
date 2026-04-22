<#
.SYNOPSIS
    Verify caveman toolkit installation.

.DESCRIPTION
    Checks that all expected files are present (after install) or absent
    (after uninstall) in the correct locations.

.PARAMETER Expected
    'present' (default) — verify files exist (run after install).
    'absent' — verify files are removed (run after uninstall).

.EXAMPLE
    .\test-install.ps1                  # Verify install
    .\test-install.ps1 -Expected absent # Verify uninstall
#>
[CmdletBinding()]
param(
    [ValidateSet('present', 'absent')]
    [string]$Expected = 'present'
)

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$InstructionsDir = Join-Path $ScriptDir 'instructions'

# --- Paths ---
$VscodePrompts = Join-Path $env:APPDATA 'Code\User\prompts'
$CopilotAgentsDir = Join-Path $HOME '.copilot\agents'
$CopilotInstructions = Join-Path $HOME '.copilot\copilot-instructions.md'

$pass = 0
$fail = 0

function Test-FileState {
    param([string]$Path, [string]$Label)

    $exists = Test-Path $Path
    if ($script:Expected -eq 'present') {
        if ($exists) {
            Write-Host "    ✅ $Label" -ForegroundColor Green
            $script:pass++
        } else {
            Write-Host "    ❌ $Label — MISSING" -ForegroundColor Red
            $script:fail++
        }
    } else {
        if (-not $exists) {
            Write-Host "    ✅ $Label — removed" -ForegroundColor Green
            $script:pass++
        } else {
            Write-Host "    ❌ $Label — STILL EXISTS" -ForegroundColor Red
            $script:fail++
        }
    }
}

# --- VS Code instructions ---
Write-Host ''
Write-Host "==> VS Code prompts ($VscodePrompts)" -ForegroundColor Cyan

$instructions = Get-ChildItem -Path $InstructionsDir -Filter '*.instructions.md' -ErrorAction SilentlyContinue
foreach ($f in $instructions) {
    Test-FileState (Join-Path $VscodePrompts $f.Name) $f.Name
}

# Stale files should always be absent
foreach ($stale in @('caveman.agent.md', 'anvil.agent.md', 'caveman-review.prompt.md')) {
    $stalePath = Join-Path $VscodePrompts $stale
    if (Test-Path $stalePath) {
        Write-Host "    ⚠️  $stale — stale file from old install" -ForegroundColor Yellow
        $script:fail++
    }
}

# --- Copilot CLI agents ---
Write-Host ''
Write-Host "==> Copilot agents ($CopilotAgentsDir)" -ForegroundColor Cyan

$agents = Get-ChildItem -Path $ScriptDir -Filter '*.agent.md' -ErrorAction SilentlyContinue
foreach ($f in $agents) {
    $cliName = $f.BaseName -replace '\.agent$', ''
    Test-FileState (Join-Path $CopilotAgentsDir "$cliName.md") "$cliName.md"
}

# Stale CLI agent
$staleCli = Join-Path $CopilotAgentsDir 'caveman.md'
if (Test-Path $staleCli) {
    Write-Host "    ⚠️  caveman.md — stale agent from old install" -ForegroundColor Yellow
    $script:fail++
}

# --- Copilot CLI instructions ---
Write-Host ''
Write-Host '==> Copilot CLI instructions' -ForegroundColor Cyan
Test-FileState $CopilotInstructions 'copilot-instructions.md'

# --- Summary ---
Write-Host ''
$total = $pass + $fail
if ($fail -eq 0) {
    Write-Host "==> All $total checks passed ✅" -ForegroundColor Green
} else {
    Write-Host "==> $fail/$total checks failed ❌" -ForegroundColor Red
    exit 1
}
