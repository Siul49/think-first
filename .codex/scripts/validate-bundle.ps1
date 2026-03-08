param(
    [string]$RepoRoot = "."
)

$ErrorActionPreference = "Stop"
$repoPath = (Resolve-Path $RepoRoot).Path
$required = @(
    ".codex/config/user-preferences.yaml",
    ".codex/mcp.json",
    ".codex/registry/catalog.json",
    ".codex/skills/_shared/skill-id-registry.json",
    ".codex/skills/_shared/skill-routing.md",
    ".codex/subagent/template-manifest.json",
    ".codex/skill-pack/config/skill-style.json",
    "AGENTS.md"
)
$missing = @()
foreach ($item in $required) {
    $path = Join-Path $repoPath $item
    if (-not (Test-Path $path)) { $missing += $path }
}
if ($missing.Count -gt 0) {
    $missing | ForEach-Object { Write-Output "[validate-bundle] missing: $_" }
    throw "[validate-bundle] required bundle files are missing."
}
& (Join-Path $repoPath ".codex/skill-pack/scripts/validate.ps1") -RepoRoot $repoPath
if (-not $?) { throw "[validate-bundle] skill-pack validation failed." }
$skillLinkValidator = Join-Path $repoPath ".codex/skills/manage-skills/scripts/validate-skill-links.ps1"
if (Test-Path $skillLinkValidator) {
    & $skillLinkValidator -SkillsRoot ".codex/skills"
    if (-not $?) { throw "[validate-bundle] skill link validation failed." }
}
$verifyRegistryValidator = Join-Path $repoPath ".codex/skills/manage-skills/scripts/validate-verify-registry.ps1"
if (Test-Path $verifyRegistryValidator) {
    & $verifyRegistryValidator -RepoRoot $repoPath
    if (-not $?) { throw "[validate-bundle] verify registry validation failed." }
}
$agentsContent = Get-Content -Raw -Encoding utf8 (Join-Path $repoPath "AGENTS.md")
if ($agentsContent -match '\.agent/') { throw "[validate-bundle] root AGENTS.md still references .agent paths." }
if ($agentsContent -notmatch '\.codex/') { throw "[validate-bundle] root AGENTS.md does not reference the .codex bundle." }
Write-Output "[validate-bundle] pass"
