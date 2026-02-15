param(
    [Parameter(Mandatory = $true)][string]$TargetPath,
    [switch]$ApplyLocalIgnore,
    [switch]$SetSkipWorktree
)

$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$packRoot = Resolve-Path (Join-Path $scriptRoot "..")
$sourceAgent = Join-Path $packRoot ".agent"
$targetAgent = Join-Path $TargetPath ".agent"

if (-not (Test-Path $sourceAgent)) {
    throw "source .agent path not found: $sourceAgent"
}
if (-not (Test-Path $TargetPath)) {
    throw "target path not found: $TargetPath"
}

$rbExit = 0
& robocopy $sourceAgent $targetAgent /E /XD reports /XF plan.json | Out-Null
$rbExit = $LASTEXITCODE
if ($rbExit -ge 8) {
    throw "robocopy failed with exit code: $rbExit"
}

Write-Output "[install] copied .agent assets to $TargetPath"

if ($ApplyLocalIgnore) {
    & git -C $TargetPath rev-parse --is-inside-work-tree | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "target is not a git repository: $TargetPath"
    }

    $excludeFile = Join-Path $TargetPath ".git/info/exclude"
    if (-not (Test-Path $excludeFile)) {
        New-Item -ItemType File -Path $excludeFile -Force | Out-Null
    }

    $rules = @(
        "# skill-pack local ignores",
        ".agent/plan.json",
        ".agent/reports/",
        ".tmp-cc-system/",
        ".claude/",
        ".vscode/"
    )

    $current = Get-Content $excludeFile -ErrorAction SilentlyContinue
    foreach ($rule in $rules) {
        if (-not ($current -contains $rule)) {
            Add-Content -Path $excludeFile -Value $rule
        }
    }
    Write-Output "[install] updated local exclude: $excludeFile"
}

if ($SetSkipWorktree) {
    $trackedAgentFiles = git -C $TargetPath ls-files .agent
    foreach ($file in $trackedAgentFiles) {
        git -C $TargetPath update-index --skip-worktree -- $file
    }
    Write-Output "[install] skip-worktree set for tracked .agent files"
}

Write-Output "[install] done"
