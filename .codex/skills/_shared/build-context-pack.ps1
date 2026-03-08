param(
    [Parameter(Mandatory = $true)][string]$Workspace,
    [Parameter(Mandatory = $true)][string]$TaskText,
    [Parameter(Mandatory = $true)][string]$TemplateId,
    [int]$TokenBudget = 3000,
    [int]$ContextBudget = 1200,
    [string[]]$SelectedSkills = @(),
    [string[]]$ReportSchema = @("changed_files", "tests", "risk", "decision"),
    [string]$OutputPath = ".codex/context/context-pack.json"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $Workspace)) {
    throw "[context-pack] workspace not found: $Workspace"
}

$resolvedWorkspace = (Resolve-Path $Workspace).Path
$resolvedOutput = $OutputPath
if (-not [System.IO.Path]::IsPathRooted($OutputPath)) {
    $resolvedOutput = Join-Path $resolvedWorkspace $OutputPath
}

function Compress-Text {
    param(
        [string]$Text,
        [int]$MaxLen = 280
    )
    if ([string]::IsNullOrWhiteSpace($Text)) { return "" }
    $flat = ($Text -replace "\s+", " ").Trim()
    if ($flat.Length -le $MaxLen) { return $flat }
    return $flat.Substring(0, $MaxLen) + "..."
}

$agentsPath = Join-Path $resolvedWorkspace "AGENTS.md"
$constraints = @()
if (Test-Path $agentsPath) {
    $constraintLines = Get-Content -Encoding utf8 $agentsPath | Where-Object { $_ -match '^\-\s' } | Select-Object -First 12
    foreach ($line in $constraintLines) {
        $constraints += $line.Trim()
    }
}

$changedFiles = @()
$prev = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$diffRaw = git -C $resolvedWorkspace diff --name-only HEAD 2>$null
$diffExit = $LASTEXITCODE
$ErrorActionPreference = $prev
if ($diffExit -eq 0 -and $diffRaw) {
    $changedFiles = $diffRaw -split "`r?`n" | Where-Object { $_ -ne "" } | Select-Object -First 40
}

$taskSummary = Compress-Text -Text $TaskText -MaxLen 280

$pack = [ordered]@{
    version = 1
    generated_at_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    workspace = $resolvedWorkspace
    task_summary = $taskSummary
    template_id = $TemplateId
    token_budget = $TokenBudget
    context_budget = $ContextBudget
    selected_skills = @($SelectedSkills)
    report_schema = @($ReportSchema)
    constraints = @($constraints)
    delta_context = [ordered]@{
        changed_files = @($changedFiles)
        changed_files_count = @($changedFiles).Count
        include_policy = "Use changed files first, then nearest dependent files only."
    }
}

New-Item -ItemType Directory -Path (Split-Path -Parent $resolvedOutput) -Force | Out-Null
$json = $pack | ConvertTo-Json -Depth 7
$json | Set-Content -Path $resolvedOutput -Encoding utf8

$timestamp = (Get-Date).ToUniversalTime().ToString("yyyyMMdd-HHmmss")
$archivePath = Join-Path (Split-Path -Parent $resolvedOutput) ("context-pack-{0}.json" -f $timestamp)
$json | Set-Content -Path $archivePath -Encoding utf8

Write-Output $resolvedOutput
exit 0
