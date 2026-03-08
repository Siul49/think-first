param(
    [string]$RepoRoot = ".",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$repoPath = (Resolve-Path $RepoRoot).Path
$stylePath = Join-Path $repoPath ".codex/skill-pack/config/skill-style.json"
$registryPath = Join-Path $repoPath ".codex/skills/_shared/skill-id-registry.json"
$style = Get-Content -Raw -Encoding utf8 $stylePath | ConvertFrom-Json
$registry = Get-Content -Raw -Encoding utf8 $registryPath | ConvertFrom-Json
$idToPath = @{}
foreach ($entry in @($registry.skills)) { $idToPath[$entry.canonical_id] = $entry.path }
$changed = 0
$skipped = 0
foreach ($entry in @($style.skills)) {
    if (-not $idToPath.ContainsKey($entry.id)) { $skipped++; continue }
    $skillFile = Join-Path $repoPath ".codex/skills/$($idToPath[$entry.id])/SKILL.md"
    if (-not (Test-Path $skillFile)) { $skipped++; continue }
    $content = Get-Content -Raw -Encoding utf8 $skillFile
    $updated = [regex]::Replace($content, "(?m)^name:\s*.*$", "name: $($entry.display_name)", 1)
    if ($updated -ne $content) {
        if (-not $DryRun) {
            $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
            [System.IO.File]::WriteAllText($skillFile, $updated, $utf8NoBom)
        }
        $changed++
    }
}
Write-Output "[sync-style] changed=$changed skipped=$skipped dry_run=$DryRun"