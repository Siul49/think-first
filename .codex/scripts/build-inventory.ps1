param(
    [string]$RepoRoot = "."
)

$ErrorActionPreference = "Stop"
$repoPath = (Resolve-Path $RepoRoot).Path
$catalogPath = Join-Path $repoPath ".codex/registry/catalog.json"
$reportPath = Join-Path $repoPath ".codex/reports/asset-inventory.md"
$catalog = Get-Content -Raw -Encoding utf8 $catalogPath | ConvertFrom-Json
function Rows($items) {
    $rows = @('| 이름 | 설명 |','|------|------|')
    foreach ($item in $items) { $rows += "| $($item.name) | $($item.description) |" }
    return $rows
}
$lines = @('# Codex Bundle Inventory','','## Skills') + (Rows $catalog.skills) + @('','## Workflows') + (Rows $catalog.workflows) + @('','## Hooks') + (Rows $catalog.hooks) + @('','## Shared Assets') + (Rows $catalog.shared_assets) + @('')
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($reportPath, (($lines -join "`n") + "`n"), $utf8NoBom)
Write-Output "[inventory] wrote: $reportPath"