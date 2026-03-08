param(
    [string]$Workspace = ".",
    [ValidateSet("Init", "Review", "Check")] [string]$Mode = "Check",
    [string]$TaskId,
    [string]$SubtaskNote = "",
    [int]$RequireRecentReviewMinutes = 240
)

$ErrorActionPreference = "Stop"

function New-UtcNow {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function Get-TaskPaths {
    param([string]$Root, [string]$Id)
    $taskRoot = Join-Path (Join-Path $Root ".codex/context") $Id
    return @{
        Root       = $taskRoot
        Plan       = Join-Path $taskRoot "plan.md"
        Context    = Join-Path $taskRoot "context.md"
        Checklist  = Join-Path $taskRoot "checklist.md"
        ReviewLog  = Join-Path $taskRoot "review-log.md"
    }
}

function Resolve-CurrentTaskId {
    param([string]$Root, [string]$ExplicitTaskId)
    if (-not [string]::IsNullOrWhiteSpace($ExplicitTaskId)) {
        return $ExplicitTaskId.Trim()
    }
    $currentFile = Join-Path (Join-Path $Root ".codex/context") "current-task.txt"
    if (Test-Path $currentFile) {
        $id = (Get-Content -Raw $currentFile).Trim()
        if (-not [string]::IsNullOrWhiteSpace($id)) {
            return $id
        }
    }
    return $null
}

function Set-CurrentTaskId {
    param([string]$Root, [string]$Id)
    $ctxRoot = Join-Path $Root ".codex/context"
    New-Item -ItemType Directory -Path $ctxRoot -Force | Out-Null
    Set-Content -Path (Join-Path $ctxRoot "current-task.txt") -Value $Id -Encoding utf8
}

function Write-IfMissing {
    param([string]$Path, [string]$Content)
    if (-not (Test-Path $Path)) {
        Set-Content -Path $Path -Value $Content -Encoding utf8
    }
}

function Update-LastReviewed {
    param([string]$Path, [string]$Timestamp)
    $raw = Get-Content -Raw $Path
    if ($raw -match '(?m)^Last Reviewed:\s*.+$') {
        $updated = [regex]::Replace($raw, '(?m)^Last Reviewed:\s*.+$', "Last Reviewed: $Timestamp")
    } else {
        $updated = $raw.TrimEnd() + "`r`n`r`nLast Reviewed: $Timestamp`r`n"
    }
    Set-Content -Path $Path -Value $updated -Encoding utf8
}

function Read-LastReviewed {
    param([string]$Path)
    $raw = Get-Content -Raw $Path
    $m = [regex]::Match($raw, '(?m)^Last Reviewed:\s*(.+)$')
    if (-not $m.Success) {
        throw "Missing 'Last Reviewed' in $Path"
    }
    $value = $m.Groups[1].Value.Trim()
    $dt = [DateTime]::MinValue
    if (-not [DateTime]::TryParse($value, [ref]$dt)) {
        throw "Invalid Last Reviewed timestamp in ${Path}: $value"
    }
    return $dt.ToUniversalTime()
}

$workspacePath = (Resolve-Path $Workspace).Path
$taskId = Resolve-CurrentTaskId -Root $workspacePath -ExplicitTaskId $TaskId

if ($Mode -eq "Init") {
    if ([string]::IsNullOrWhiteSpace($taskId)) {
        $taskId = "task-" + (Get-Date).ToUniversalTime().ToString("yyyyMMdd-HHmmss")
    }

    $paths = Get-TaskPaths -Root $workspacePath -Id $taskId
    New-Item -ItemType Directory -Path $paths.Root -Force | Out-Null
    Set-CurrentTaskId -Root $workspacePath -Id $taskId

    $now = New-UtcNow
    Write-IfMissing -Path $paths.Plan -Content @"
# Big Task Plan

Task ID: $taskId
Last Reviewed: $now

## Goal
- Define final outcome and success criteria.

## Scope
- In scope:
- Out of scope:

## Milestones
- [ ] Milestone 1
- [ ] Milestone 2

## Subtasks
- [ ] Subtask A
- [ ] Subtask B
"@

    Write-IfMissing -Path $paths.Context -Content @"
# Big Task Context

Task ID: $taskId
Last Reviewed: $now

## Background
- Why this task exists.

## Constraints
- Technical constraints:
- Product constraints:

## Decisions
- Decision:
  - Reason:

## Risks
- Risk:
  - Mitigation:
"@

    Write-IfMissing -Path $paths.Checklist -Content @"
# Big Task Checklist

Task ID: $taskId
Last Reviewed: $now

## Pre-Work
- [ ] Read plan.md
- [ ] Read context.md
- [ ] Confirm checklist.md scope

## During Work
- [ ] Update checklist progress
- [ ] Log changed files
- [ ] Re-check constraints before risky edits

## Post-Work
- [ ] Run validations
- [ ] Summarize outcomes
- [ ] Record open follow-ups
"@

    Write-IfMissing -Path $paths.ReviewLog -Content @"
# Big Task Review Log

- $now | INIT | Initialized big-task document pack
"@

    Write-Output "[big-task-docs] initialized task pack: $taskId"
    Write-Output "[big-task-docs] path: $($paths.Root)"
    exit 0
}

if ([string]::IsNullOrWhiteSpace($taskId)) {
    Write-Error "[big-task-docs] no active task id found. Run Init first."
    exit 1
}

$paths = Get-TaskPaths -Root $workspacePath -Id $taskId
$required = @($paths.Plan, $paths.Context, $paths.Checklist, $paths.ReviewLog)
foreach ($f in $required) {
    if (-not (Test-Path $f)) {
        Write-Error "[big-task-docs] missing required file: $f"
        exit 1
    }
}

if ($Mode -eq "Review") {
    $now = New-UtcNow
    Update-LastReviewed -Path $paths.Plan -Timestamp $now
    Update-LastReviewed -Path $paths.Context -Timestamp $now
    Update-LastReviewed -Path $paths.Checklist -Timestamp $now

    $note = $SubtaskNote
    if ([string]::IsNullOrWhiteSpace($note)) {
        $note = "Subtask review checkpoint"
    }
    Add-Content -Path $paths.ReviewLog -Value "- $now | REVIEW | $note"
    Write-Output "[big-task-docs] review checkpoint updated for: $taskId"
    exit 0
}

# Mode Check
$planReviewed = Read-LastReviewed -Path $paths.Plan
$contextReviewed = Read-LastReviewed -Path $paths.Context
$checklistReviewed = Read-LastReviewed -Path $paths.Checklist
$latestReviewed = @($planReviewed, $contextReviewed, $checklistReviewed) | Sort-Object -Descending | Select-Object -First 1

$nowUtc = (Get-Date).ToUniversalTime()
$deltaMinutes = [int](($nowUtc - $latestReviewed).TotalMinutes)
if ($deltaMinutes -gt $RequireRecentReviewMinutes) {
    Write-Error "[big-task-docs] docs are stale ($deltaMinutes min). Run Review before continuing."
    exit 1
}

$checklistText = Get-Content -Raw $paths.Checklist
if ($checklistText -notmatch '(?m)^-\s\[( |x)\]\s') {
    Write-Error "[big-task-docs] checklist has no actionable checkbox items."
    exit 1
}

Write-Output "[big-task-docs] check pass (task=$taskId, reviewed=$deltaMinutes min ago)"
exit 0
