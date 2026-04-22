<#
.SYNOPSIS
    Uninstall caveman toolkit from VS Code Copilot and GitHub Copilot CLI.

.PARAMETER Target
    Uninstall target: 'all' (default), 'vscode', or 'cli'.

.EXAMPLE
    .\uninstall.ps1              # Uninstall from both
    .\uninstall.ps1 -Target vscode  # VS Code only
    .\uninstall.ps1 -Target cli     # Copilot CLI only
#>
[CmdletBinding()]
param(
    [ValidateSet('all', 'vscode', 'cli')]
    [string]$Target = 'all'
)

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$InstructionsDir = Join-Path $ScriptDir 'instructions'

# --- Paths ---
$VscodePrompts = Join-Path $env:APPDATA 'Code\User\prompts'
$CopilotAgentsDir = Join-Path $HOME '.copilot\agents'
$CopilotInstructions = Join-Path $HOME '.copilot\copilot-instructions.md'

function Uninstall-VsCode {
    Write-Host '==> Uninstalling from VS Code Copilot...' -ForegroundColor Cyan

    # Remove instruction files that we installed
    $instructions = Get-ChildItem -Path $InstructionsDir -Filter '*.instructions.md' -ErrorAction SilentlyContinue
    foreach ($f in $instructions) {
        $dest = Join-Path $VscodePrompts $f.Name
        if (Test-Path $dest) {
            Remove-Item $dest -Force
            Write-Host "    Removed $($f.Name)"
        }
    }

    # Remove stale files from older installs
    foreach ($stale in @('caveman.agent.md', 'anvil.agent.md', 'caveman-review.prompt.md')) {
        $stalePath = Join-Path $VscodePrompts $stale
        if (Test-Path $stalePath) {
            Remove-Item $stalePath -Force
            Write-Host "    Removed stale $stale"
        }
    }

    Write-Host '==> VS Code uninstall complete' -ForegroundColor Green
}

function Uninstall-Cli {
    Write-Host '==> Uninstalling from GitHub Copilot CLI...' -ForegroundColor Cyan

    # Remove agent files
    $agents = Get-ChildItem -Path $ScriptDir -Filter '*.agent.md' -ErrorAction SilentlyContinue
    foreach ($f in $agents) {
        $cliName = $f.BaseName -replace '\.agent$', ''
        $dest = Join-Path $CopilotAgentsDir "$cliName.md"
        if (Test-Path $dest) {
            Remove-Item $dest -Force
            Write-Host "    Removed agent: $cliName"
        }
    }

    # Remove stale agent from older installs
    $staleCli = Join-Path $CopilotAgentsDir 'caveman.md'
    if (Test-Path $staleCli) {
        Remove-Item $staleCli -Force
        Write-Host '    Removed stale caveman agent'
    }

    # Remove merged instructions file
    if (Test-Path $CopilotInstructions) {
        Remove-Item $CopilotInstructions -Force
        Write-Host '    Removed copilot-instructions.md'
    }

    Write-Host '==> Copilot CLI uninstall complete' -ForegroundColor Green
}

# --- Main ---
Write-Host ''
Write-Host 'caveman uninstaller' -ForegroundColor White
Write-Host ''

switch ($Target) {
    'vscode' { Uninstall-VsCode }
    'cli'    { Uninstall-Cli }
    'all'    { Uninstall-VsCode; Write-Host ''; Uninstall-Cli }
}

# Run verification
Write-Host ''
& (Join-Path $ScriptDir 'test-install.ps1') -Expected absent

Write-Host ''
