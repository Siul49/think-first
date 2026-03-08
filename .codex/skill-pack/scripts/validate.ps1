param(
    [string]$RepoRoot = "."
)

$ErrorActionPreference = "Stop"
$repoPath = (Resolve-Path $RepoRoot).Path
$required = @(
    ".codex/skill-pack/config/skill-style.json",
    ".codex/skill-pack/profiles/kyungsu.yaml",
    ".codex/skill-pack/templates/AGENTS.codex.template.md",
    ".codex/skill-pack/templates/user-preferences.template.yaml",
    ".codex/skill-pack/schemas/profile.schema.json",
    ".codex/skill-pack/scripts/install.ps1",
    ".codex/skill-pack/scripts/sync-style.ps1",
    ".codex/skills/_shared/skill-id-registry.json"
)
$missing = @()
foreach ($item in $required) { $path = Join-Path $repoPath $item; if (-not (Test-Path $path)) { $missing += $path } }
if ($missing.Count -gt 0) { $missing | ForEach-Object { Write-Output "[validate] missing: $_" }; throw "[validate] required Codex bundle files are missing." }
& (Join-Path $repoPath ".codex/skill-pack/scripts/sync-style.ps1") -RepoRoot $repoPath -DryRun
if (-not $?) { throw "[validate] sync-style dry-run failed." }
Write-Output "[validate] skill-pack validation passed."
