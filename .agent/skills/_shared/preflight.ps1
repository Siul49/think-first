param(
    [Parameter(Mandatory = $true)][string]$Workspace,
    [Parameter(Mandatory = $true)][string]$AgentType,
    [string]$ProtectedFileRegex = '^(\\.env|\\.env\\.|secrets/|.*\\.pem$|.*\\.key$)'
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $Workspace)) {
    Write-Error "[preflight] workspace not found: $Workspace"
    exit 1
}

$prevErrorAction = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
git -C $Workspace rev-parse --is-inside-work-tree *> $null
$gitRepoExit = $LASTEXITCODE
$ErrorActionPreference = $prevErrorAction

if ($gitRepoExit -ne 0) {
    Write-Error "[preflight] not a git workspace: $Workspace"
    exit 1
}

Write-Output "[preflight] agent=$AgentType workspace=$Workspace"

$changedFiles = @()
$prevErrorAction = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$changedRaw = git -C $Workspace diff --name-only HEAD 2>$null
$gitDiffExit = $LASTEXITCODE
$ErrorActionPreference = $prevErrorAction

if ($gitDiffExit -eq 0 -and $changedRaw) {
    $changedFiles = $changedRaw -split "`r?`n" | Where-Object { $_ -ne '' }
}

if ($changedFiles.Count -gt 0) {
    $blocked = $changedFiles | Where-Object { $_ -match $ProtectedFileRegex }
    if ($blocked.Count -gt 0) {
        Write-Output "[preflight] blocked protected file changes detected:"
        $blocked | ForEach-Object { Write-Output $_ }
        exit 1
    }
}

if (Get-Command rg -ErrorAction SilentlyContinue) {
    $conflictHits = @()
    if ($changedFiles.Count -gt 0) {
        $conflictRaw = $changedFiles | rg -n '<<<<<<<|=======|>>>>>>>' 2>$null
        if ($conflictRaw) {
            $conflictHits = $conflictRaw -split "`r?`n" | Where-Object { $_ -ne '' }
        }
    }
    if ($conflictHits.Count -gt 0) {
        Write-Output "[preflight] merge conflict markers found in changed files:"
        $conflictHits | ForEach-Object { Write-Output $_ }
        exit 1
    }
}

Write-Output "[preflight] pass"
exit 0
