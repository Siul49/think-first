param(
    [string]$Workspace = ".",
    [int]$SampleSize = 20,
    [string]$OutputPath = ".codex/reports/subagent-efficiency-baseline.json"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $Workspace)) {
    throw "[baseline] workspace not found: $Workspace"
}

$resolvedWorkspace = (Resolve-Path $Workspace).Path
$contextDir = Join-Path $resolvedWorkspace ".codex/context"
$reportsDir = Join-Path $resolvedWorkspace ".codex/reports"

$packs = @()
if (Test-Path $contextDir) {
    $packs = Get-ChildItem -Path $contextDir -Filter "context-pack-*.json" -File |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First $SampleSize
}

$totalTokenBudget = 0
$totalContextBudget = 0
$totalChangedFiles = 0
$count = 0
$templateDist = @{}

foreach ($f in $packs) {
    try {
        $obj = Get-Content -Raw -Encoding utf8 $f.FullName | ConvertFrom-Json
        $count++
        $tb = 0
        $cb = 0
        if ($obj.PSObject.Properties.Name -contains "token_budget") { $tb = [int]$obj.token_budget }
        if ($obj.PSObject.Properties.Name -contains "context_budget") { $cb = [int]$obj.context_budget }
        $totalTokenBudget += $tb
        $totalContextBudget += $cb
        if ($obj.delta_context -and $obj.delta_context.changed_files_count) {
            $totalChangedFiles += [int]$obj.delta_context.changed_files_count
        }
        $tpl = "unknown"
        if ($obj.PSObject.Properties.Name -contains "template_id") { $tpl = $obj.template_id.ToString() }
        if (-not $templateDist.ContainsKey($tpl)) { $templateDist[$tpl] = 0 }
        $templateDist[$tpl]++
    } catch {
        # Ignore malformed snapshots.
    }
}

$postflightCount = 0
if (Test-Path $reportsDir) {
    $postflightCount = @(Get-ChildItem -Path $reportsDir -Filter "postflight-*.md" -File).Count
}

$baseline = [ordered]@{
    generated_at_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    sample_size_requested = $SampleSize
    sample_size_used = $count
    avg_token_budget = if ($count -gt 0) { [Math]::Round($totalTokenBudget / $count, 2) } else { 0 }
    avg_context_budget = if ($count -gt 0) { [Math]::Round($totalContextBudget / $count, 2) } else { 0 }
    avg_changed_files = if ($count -gt 0) { [Math]::Round($totalChangedFiles / $count, 2) } else { 0 }
    template_distribution = $templateDist
    postflight_report_count = $postflightCount
}

$resolvedOutput = $OutputPath
if (-not [System.IO.Path]::IsPathRooted($OutputPath)) {
    $resolvedOutput = Join-Path $resolvedWorkspace $OutputPath
}
New-Item -ItemType Directory -Path (Split-Path -Parent $resolvedOutput) -Force | Out-Null
$baseline | ConvertTo-Json -Depth 6 | Set-Content -Path $resolvedOutput -Encoding utf8

Write-Output "[baseline] wrote: $resolvedOutput"
Write-Output "[baseline] sample_size_used=$count avg_token_budget=$($baseline.avg_token_budget) avg_context_budget=$($baseline.avg_context_budget)"
exit 0
