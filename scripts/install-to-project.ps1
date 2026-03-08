param(
    [Parameter(Mandatory = $true)][string]$TargetPath,
    [switch]$ApplyLocalIgnore,
    [switch]$SetSkipWorktree
)

$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$packRoot = Resolve-Path (Join-Path $scriptRoot "..")
$sourceBundle = Join-Path $packRoot ".codex"
$targetBundle = Join-Path $TargetPath ".codex"
$bundleInstaller = Join-Path $targetBundle "skill-pack/scripts/install.ps1"

if (-not (Test-Path $sourceBundle)) {
    throw "source .codex path not found: $sourceBundle"
}
if (-not (Test-Path $TargetPath)) {
    throw "target path not found: $TargetPath"
}

New-Item -ItemType Directory -Force -Path $targetBundle | Out-Null
& robocopy $sourceBundle $targetBundle /E /XD context reports | Out-Null
$rbExit = $LASTEXITCODE
if ($rbExit -ge 8) {
    throw "robocopy failed with exit code: $rbExit"
}

Write-Output "[install] copied .codex bundle to $TargetPath"

if (-not (Test-Path $bundleInstaller)) {
    throw "bundle installer not found after copy: $bundleInstaller"
}

& $bundleInstaller -RepoRoot $TargetPath
if (-not $?) {
    throw "bundle bootstrap failed"
}

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
        ".codex/",
        ".codex/context/",
        ".codex/reports/",
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
    $trackedBundleFiles = git -C $TargetPath ls-files .codex
    foreach ($file in $trackedBundleFiles) {
        git -C $TargetPath update-index --skip-worktree -- $file
    }
    Write-Output "[install] skip-worktree set for tracked .codex files"
}

Write-Output "[install] done"
