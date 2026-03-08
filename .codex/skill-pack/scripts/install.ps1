param(
    [string]$RepoRoot = ".",
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$repoPath = (Resolve-Path $RepoRoot).Path
$templateAgents = Join-Path $repoPath ".codex/skill-pack/templates/AGENTS.codex.template.md"
$templatePrefs = Join-Path $repoPath ".codex/skill-pack/templates/user-preferences.template.yaml"
$targetAgents = Join-Path $repoPath "AGENTS.md"
$targetPrefs = Join-Path $repoPath ".codex/config/user-preferences.yaml"
if ((Test-Path $targetAgents) -and -not $Force) { Write-Output "[install] skip existing AGENTS.md (use -Force to overwrite)" } else { Copy-Item $templateAgents $targetAgents -Force; Write-Output "[install] wrote: $targetAgents" }
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $targetPrefs) | Out-Null
if ((Test-Path $targetPrefs) -and -not $Force) { Write-Output "[install] skip existing user preferences (use -Force to overwrite)" } else { Copy-Item $templatePrefs $targetPrefs -Force; Write-Output "[install] wrote: $targetPrefs" }
Write-Output "[install] completed. next steps:"
Write-Output "  1) powershell -ExecutionPolicy Bypass -File .codex/scripts/validate-bundle.ps1 -RepoRoot ."
Write-Output "  2) powershell -ExecutionPolicy Bypass -File .codex/scripts/build-inventory.ps1 -RepoRoot ."