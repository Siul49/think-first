param(
    [string]$RepoRoot
)

$ErrorActionPreference = "Stop"

if (-not $RepoRoot) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $RepoRoot = (Resolve-Path (Join-Path $scriptDir "../../..")).Path
}

$skillsRoot = Join-Path $RepoRoot ".agent/skills"
$verifyImplFile = Join-Path $skillsRoot "verify-implementation/SKILL.md"
$routingFile = Join-Path $skillsRoot "_shared/skill-routing.md"
$manageSkillsFile = Join-Path $skillsRoot "manage-skills/SKILL.md"

$requiredFiles = @($verifyImplFile, $routingFile, $manageSkillsFile)
foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        Write-Output "MISSING FILE: $file"
        exit 1
    }
}

$actualSkills = Get-ChildItem -Path $skillsRoot -Directory -Filter "verify-*" |
    Where-Object { $_.Name -ne "verify-implementation" } |
    ForEach-Object { $_.Name.ToLowerInvariant() } |
    Sort-Object -Unique

if ($actualSkills.Count -eq 0) {
    Write-Output "No verify-* skills found under .agent/skills (excluding verify-implementation)."
    exit 1
}

function Extract-VerifySkillsFromText {
    param([string]$Text)

    $matches = [regex]::Matches($Text, '(?im)\|\s*(?:\d+\s*\|\s*)?`?(verify-[a-z0-9-]+)`?\s*\|')
    $results = @()
    foreach ($m in $matches) {
        $name = $m.Groups[1].Value.ToLowerInvariant()
        if ($name -and $name -ne "verify-implementation") {
            $results += $name
        }
    }
    return $results | Sort-Object -Unique
}

function Compare-Sets {
    param(
        [string]$Label,
        [string[]]$Actual,
        [string[]]$Declared
    )

    $missing = $Actual | Where-Object { $_ -notin $Declared }
    $stale = $Declared | Where-Object { $_ -notin $Actual }

    if ($missing.Count -gt 0 -or $stale.Count -gt 0) {
        Write-Output "[$Label] mismatch detected."
        if ($missing.Count -gt 0) {
            Write-Output "  Missing: $($missing -join ', ')"
        }
        if ($stale.Count -gt 0) {
            Write-Output "  Stale: $($stale -join ', ')"
        }
        return $false
    }
    return $true
}

$verifyImplText = Get-Content -Raw $verifyImplFile
$routingText = Get-Content -Raw $routingFile
$manageSkillsText = Get-Content -Raw $manageSkillsFile

$executionList = Extract-VerifySkillsFromText -Text $verifyImplText
$routingList = Extract-VerifySkillsFromText -Text $routingText
$registeredList = Extract-VerifySkillsFromText -Text $manageSkillsText

$ok = $true

if (-not (Compare-Sets -Label "verify-implementation execution list" -Actual $actualSkills -Declared $executionList)) {
    $ok = $false
}
if (-not (Compare-Sets -Label "skill-routing summary" -Actual $actualSkills -Declared $routingList)) {
    $ok = $false
}
if (-not (Compare-Sets -Label "manage-skills registry" -Actual $actualSkills -Declared $registeredList)) {
    $ok = $false
}

if (-not $ok) {
    exit 1
}

Write-Output "Verify registry validation passed: execution/routing/registry are synchronized."
exit 0
