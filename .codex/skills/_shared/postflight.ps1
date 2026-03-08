param(
    [Parameter(Mandatory = $true)][string]$Workspace,
    [Parameter(Mandatory = $true)][string]$AgentType,
    [string]$SkillLockPath = ".codex/context/skill-lock.json"
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $Workspace)) {
    Write-Error "[postflight] workspace not found: $Workspace"
    exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir "../../..")
$reportDir = Join-Path $repoRoot ".codex/reports"
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

$resolvedLockPath = $SkillLockPath
if (-not [System.IO.Path]::IsPathRooted($SkillLockPath)) {
    $resolvedLockPath = Join-Path $Workspace $SkillLockPath
}

if (Test-Path $resolvedLockPath) {
    try {
        $lock = Get-Content -Raw -Encoding utf8 $resolvedLockPath | ConvertFrom-Json
        if ($lock.PSObject.Properties.Name -contains "updated_at_utc") { $lock.updated_at_utc = $timestamp } else { $lock | Add-Member -NotePropertyName "updated_at_utc" -NotePropertyValue $timestamp }
        if ($lock.PSObject.Properties.Name -contains "last_agent") { $lock.last_agent = $AgentType } else { $lock | Add-Member -NotePropertyName "last_agent" -NotePropertyValue $AgentType }
        if ($lock.PSObject.Properties.Name -contains "last_postflight_report") { $lock.last_postflight_report = $reportFile } else { $lock | Add-Member -NotePropertyName "last_postflight_report" -NotePropertyValue $reportFile }
        if ($lock.PSObject.Properties.Name -contains "changed_files_count") { $lock.changed_files_count = $changedFiles.Count } else { $lock | Add-Member -NotePropertyName "changed_files_count" -NotePropertyValue $changedFiles.Count }
        if ($changedFiles.Count -eq 0) {
            if ($lock.PSObject.Properties.Name -contains "status") { $lock.status = "closed" } else { $lock | Add-Member -NotePropertyName "status" -NotePropertyValue "closed" }
        }
        $lock | ConvertTo-Json -Depth 6 | Set-Content -Path $resolvedLockPath -Encoding utf8
        Write-Output "[postflight] updated skill-lock: $resolvedLockPath"
    } catch {
        Write-Output "[postflight] warning: failed to update skill-lock: $($_.Exception.Message)"
    }
}
