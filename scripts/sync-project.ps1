param(
    [Parameter(Mandatory = $true)][string]$TargetPath,
    [switch]$ApplyLocalIgnore,
    [switch]$SetSkipWorktree,
    [string]$Branch = "main"
)

$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$packRoot = Resolve-Path (Join-Path $scriptRoot "..")
$installScript = Join-Path $scriptRoot "install-to-project.ps1"

if (-not (Test-Path $installScript)) {
    throw "install script not found: $installScript"
}

& git -C $packRoot rev-parse --is-inside-work-tree | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "skill-pack is not a git repo: $packRoot"
}

Write-Output "[sync] fetching latest skill-pack ($Branch)"
& git -C $packRoot fetch origin $Branch | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "git fetch failed"
}

Write-Output "[sync] pulling latest skill-pack ($Branch)"
& git -C $packRoot pull --ff-only origin $Branch | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "git pull failed (non fast-forward or conflict)"
}

Write-Output "[sync] installing into target: $TargetPath"
$installArgs = @{
    TargetPath = $TargetPath
}
if ($ApplyLocalIgnore) {
    $installArgs["ApplyLocalIgnore"] = $true
}
if ($SetSkipWorktree) {
    $installArgs["SetSkipWorktree"] = $true
}

& $installScript @installArgs
if ($LASTEXITCODE -ne 0) {
    throw "install step failed"
}

Write-Output "[sync] done"
