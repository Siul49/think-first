param(
    [Parameter(Mandatory = $true)][string]$Workspace,
    [Parameter(Mandatory = $true)][string]$AgentType
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $Workspace)) {
    Write-Error "[postflight] workspace not found: $Workspace"
    exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir "../../..")
$reportDir = Join-Path $repoRoot ".agent/reports"
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null

$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$reportFile = Join-Path $reportDir ("postflight-{0}.md" -f $AgentType)

$changedFiles = @()
$prevErrorAction = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$changedRaw = git -C $Workspace diff --name-only HEAD 2>$null
$gitDiffExit = $LASTEXITCODE
$ErrorActionPreference = $prevErrorAction

if ($gitDiffExit -eq 0 -and $changedRaw) {
    $changedFiles = $changedRaw -split "`r?`n" | Where-Object { $_ -ne '' }
}

$lines = @(
    "# Postflight Report",
    "",
    "- Timestamp (UTC): $timestamp",
    "- Agent Type: $AgentType",
    "- Workspace: $Workspace",
    "- Changed Files Count: $($changedFiles.Count)",
    "",
    "## Changed Files"
)

if ($changedFiles.Count -eq 0) {
    $lines += "- (none)"
} else {
    $lines += ($changedFiles | ForEach-Object { "- $_" })
}

$lines | Set-Content -Path $reportFile -Encoding utf8
Write-Output "[postflight] wrote report: $reportFile"
