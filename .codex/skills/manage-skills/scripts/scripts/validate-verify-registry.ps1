param(
    [string]$RepoRoot
)

$ErrorActionPreference = "Stop"

if (-not $RepoRoot) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $RepoRoot = (Resolve-Path (Join-Path $scriptDir "../../..")).Path
}

$skillsRoot = Join-Path $RepoRoot ".codex/skills"
$verifyImplFile = Join-Path $skillsRoot "verify-implementation/SKILL.md"
$routingFile = Join-Path $skillsRoot "_shared/skill-routing.md"
$manageSkillsFile = Join-Path $skillsRoot "manage-skills/SKILL.md"
$skillRegistryFile = Join-Path $skillsRoot "_shared/skill-id-registry.json"

$requiredFiles = @($verifyImplFile, $routingFile, $manageSkillsFile, $skillRegistryFile)
foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        Write-Output "MISSING FILE: $file"
        exit 1
    }
}

$registry = Get-Content -Raw -Encoding utf8 $skillRegistryFile | ConvertFrom-Json
$legacyToCanonical = @{}
foreach ($entry in @($registry.skills)) {
    if ($null -eq $entry) { continue }
    $canonical = $entry.canonical_id.ToString().Trim().ToLowerInvariant()
    if (-not $canonical.StartsWith("skill.verify.")) { continue }
    $legacyToCanonical[$canonical] = $canonical
    foreach ($legacyObj in @($entry.legacy_ids)) {
        if ($null -eq $legacyObj) { continue }
        $legacy = $legacyObj.ToString().Trim().ToLowerInvariant()
        if ($legacy -ne "") {
            $legacyToCanonical[$legacy] = $canonical
        }
    }
}

function Resolve-VerifySkillId {
    param([string]$SkillId)

    $normalized = $SkillId.Trim().ToLowerInvariant()
    if ($legacyToCanonical.ContainsKey($normalized)) {
        return $legacyToCanonical[$normalized]
    }
    return $normalized
}

$actualSkills = Get-ChildItem -Path $skillsRoot -Directory -Filter "verify-*" |
    Where-Object { $_.Name -ne "verify-implementation" } |
    ForEach-Object { Resolve-VerifySkillId -SkillId $_.Name } |
    Where-Object { $_ -ne "skill.verify.implementation" -and $_.StartsWith("skill.verify.") } |
    Sort-Object -Unique

if ($actualSkills.Count -eq 0) {
    Write-Output "No verify-* skills found under .codex/skills (excluding verify-implementation)."
    exit 1
}

function Extract-VerifySkillsFromText {
    param([string]$Text)

    $matches = [regex]::Matches($Text, '(?im)\|\s*(?:\d+\s*\|\s*)?`?(verify-[a-z0-9-]+|skill\.verify\.[a-z0-9_]+)`?\s*\|')
    $results = @()
    foreach ($m in $matches) {
        $name = Resolve-VerifySkillId -SkillId $m.Groups[1].Value.ToLowerInvariant()
        if ($name -and $name -ne "skill.verify.implementation" -and $name.StartsWith("skill.verify.")) {
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
