param(
    [Parameter(Mandatory = $true)][string]$Workspace,
    [Parameter(Mandatory = $true)][string]$AgentType,
    [string]$ProtectedFileRegex = '^(\\.env|\\.env\\.|secrets/|.*\\.pem$|.*\\.key$)',
    [string]$SkillLockPath = ".codex/context/skill-lock.json",
    [switch]$SkipSkillLockCheck
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

$validateSkillLockScript = Join-Path $Workspace ".codex/skills/_shared/validate-skill-lock.ps1"
$skipSkillLock = $SkipSkillLockCheck -or (@("ci") -contains $AgentType.ToLowerInvariant())
if (-not $skipSkillLock) {
    if (-not (Test-Path $validateSkillLockScript)) {
        Write-Error "[preflight] skill-lock validator not found: $validateSkillLockScript"
        exit 1
    }
    & $validateSkillLockScript -Workspace $Workspace -AgentType $AgentType -SkillLockPath $SkillLockPath
    if ($LASTEXITCODE -ne 0) {
        Write-Error "[preflight] skill-lock validation failed"
        exit 1
    }

    $resolvedLockPath = $SkillLockPath
    if (-not [System.IO.Path]::IsPathRooted($SkillLockPath)) {
        $resolvedLockPath = Join-Path $Workspace $SkillLockPath
    }
    if (Test-Path $resolvedLockPath) {
        try {
            $lock = Get-Content -Raw -Encoding utf8 $resolvedLockPath | ConvertFrom-Json
            if ($lock.PSObject.Properties.Name -contains "context_pack_path") {
                $packPath = $lock.context_pack_path.ToString()
                if (-not [System.IO.Path]::IsPathRooted($packPath)) {
                    $packPath = Join-Path $Workspace $packPath
                }
                if (-not (Test-Path $packPath)) {
                    Write-Error "[preflight] context pack missing: $packPath"
                    exit 1
                }
            }
        } catch {
            Write-Error "[preflight] failed to read skill-lock/context-pack metadata."
            exit 1
        }
    }
}

$bigTaskGuard = Join-Path $Workspace ".codex/skills/_shared/ensure-big-task-docs.ps1"
$skipBigTaskGuard = @("ci") -contains $AgentType
if ((-not $skipBigTaskGuard) -and (Test-Path $bigTaskGuard)) {
    try {
        & $bigTaskGuard -Workspace $Workspace -Mode Check -RequireRecentReviewMinutes 240
        if ($LASTEXITCODE -ne 0) {
            Write-Error "[preflight] big-task docs check failed"
            exit 1
        }
    } catch {
        Write-Error "[preflight] big-task docs guard failed: $($_.Exception.Message)"
        exit 1
    }
}

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
