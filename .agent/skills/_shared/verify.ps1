param(
    [Parameter(Mandatory = $true)][string]$AgentType,
    [Parameter(Mandatory = $true)][string]$Workspace
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir "../../..")
$reportDir = Join-Path $repoRoot ".agent/reports"
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
$logFile = Join-Path $reportDir ("verify-{0}.log" -f $AgentType)

function Write-Log {
    param([string]$Message)
    $Message | Tee-Object -FilePath $logFile -Append
}

Write-Log "[verify] start agent=$AgentType workspace=$Workspace"

& (Join-Path $scriptDir "preflight.ps1") -Workspace $Workspace -AgentType $AgentType
if (-not $?) { exit 1 }

$checkRan = 0
$checkFailed = 0

function Invoke-Check {
    param(
        [string]$Label,
        [scriptblock]$Action
    )
    $script:checkRan++
    Write-Log "[verify] running: $Label"
    try {
        & $Action
        if ($LASTEXITCODE -ne 0) { throw "Non-zero exit code" }
        Write-Log "[verify] pass: $Label"
    } catch {
        $script:checkFailed++
        Write-Log "[verify] fail: $Label :: $($_.Exception.Message)"
    }
}

$skillLinkValidator = Join-Path $repoRoot ".agent/skills/manage-skills/scripts/validate-skill-links.ps1"
if (Test-Path $skillLinkValidator) {
    Invoke-Check "validate skill links" { & $skillLinkValidator | Out-Null }
}

$verifyRegistryValidator = Join-Path $repoRoot ".agent/skills/manage-skills/scripts/validate-verify-registry.ps1"
if (Test-Path $verifyRegistryValidator) {
    Invoke-Check "validate verify registry sync" { & $verifyRegistryValidator -RepoRoot $repoRoot | Out-Null }
}

if ((Test-Path (Join-Path $Workspace "package.json")) -and (Get-Command npm -ErrorAction SilentlyContinue)) {
    Invoke-Check "npm lint --if-present" { npm --prefix $Workspace run lint --if-present | Out-Null }
    Invoke-Check "npm test --if-present" { npm --prefix $Workspace run test --if-present | Out-Null }
}

if ((Test-Path (Join-Path $Workspace "app")) -and (Get-Command python -ErrorAction SilentlyContinue)) {
    Invoke-Check "python compileall app" { python -m compileall -q (Join-Path $Workspace "app") | Out-Null }
}

if ((Test-Path (Join-Path $Workspace "tests")) -and (Get-Command pytest -ErrorAction SilentlyContinue)) {
    Invoke-Check "pytest -q tests" { pytest -q (Join-Path $Workspace "tests") | Out-Null }
}

if ($checkRan -eq 0) {
    Write-Log "[verify] no automated checks found; fallback to git status"
    Invoke-Check "git status" { git -C $Workspace status --short 2>$null | Out-Null }
}

& (Join-Path $scriptDir "postflight.ps1") -Workspace $Workspace -AgentType $AgentType
if (-not $?) { exit 1 }

if ($checkFailed -gt 0) {
    Write-Log "[verify] completed with failures: $checkFailed"
    exit 1
}

Write-Log "[verify] completed successfully"
