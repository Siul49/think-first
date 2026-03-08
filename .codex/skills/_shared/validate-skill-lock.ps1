param(
    [Parameter(Mandatory = $true)][string]$Workspace,
    [Parameter(Mandatory = $true)][string]$AgentType,
    [string]$SkillLockPath = ".codex/context/skill-lock.json",
    [int]$MaxAgeHours = 24
)

$ErrorActionPreference = "Stop"

function Normalize-AgentType {
    param(
        [string]$Name,
        [hashtable]$AliasMap
    )

    $trimmed = $Name.Trim().ToLowerInvariant()
    if ($AliasMap.ContainsKey($trimmed)) {
        return $AliasMap[$trimmed]
    }
    return $trimmed
}

function As-Array {
    param([object]$Value)
    if ($null -eq $Value) { return @() }
    if ($Value -is [array]) {
        return @($Value | ForEach-Object { $_.ToString().Trim() } | Where-Object { $_ -ne "" })
    }
    return @($Value.ToString().Trim()) | Where-Object { $_ -ne "" }
}

function Load-SkillRegistry {
    param([string]$RegistryPath)

    $legacyToCanonical = @{}
    $canonicalToLocalPath = @{}

    if (-not (Test-Path $RegistryPath)) {
        return [pscustomobject]@{
            LegacyToCanonical = $legacyToCanonical
            CanonicalToLocalPath = $canonicalToLocalPath
        }
    }

    try {
        $registry = Get-Content -Raw -Encoding utf8 $RegistryPath | ConvertFrom-Json
    } catch {
        Write-Error "[skill-lock] failed to parse skill registry: $RegistryPath"
        exit 1
    }

    foreach ($entry in @($registry.skills)) {
        if ($null -eq $entry) { continue }
        $canonicalId = $entry.canonical_id.ToString().Trim().ToLowerInvariant()
        if ([string]::IsNullOrWhiteSpace($canonicalId)) { continue }

        $legacyToCanonical[$canonicalId] = $canonicalId

        $scope = ""
        if ($entry.PSObject.Properties.Name -contains "scope") {
            $scope = $entry.scope.ToString().Trim().ToLowerInvariant()
        }
        $path = ""
        if ($entry.PSObject.Properties.Name -contains "path") {
            $path = $entry.path.ToString().Trim().ToLowerInvariant()
        }
        if ($scope -eq "local" -and -not [string]::IsNullOrWhiteSpace($path)) {
            $canonicalToLocalPath[$canonicalId] = $path
        }

        foreach ($legacyIdObj in @($entry.legacy_ids)) {
            if ($null -eq $legacyIdObj) { continue }
            $legacyId = $legacyIdObj.ToString().Trim().ToLowerInvariant()
            if (-not [string]::IsNullOrWhiteSpace($legacyId)) {
                $legacyToCanonical[$legacyId] = $canonicalId
            }
        }
    }

    return [pscustomobject]@{
        LegacyToCanonical = $legacyToCanonical
        CanonicalToLocalPath = $canonicalToLocalPath
    }
}

function Resolve-SkillId {
    param(
        [string]$SkillId,
        [hashtable]$LegacyToCanonical
    )

    $normalized = $SkillId.Trim().ToLowerInvariant()
    if ([string]::IsNullOrWhiteSpace($normalized)) {
        return ""
    }
    if ($LegacyToCanonical.ContainsKey($normalized)) {
        return $LegacyToCanonical[$normalized]
    }
    return $normalized
}

function Resolve-SkillList {
    param(
        [string[]]$Items,
        [hashtable]$LegacyToCanonical
    )

    $resolved = @()
    foreach ($item in $Items) {
        $normalized = Resolve-SkillId -SkillId $item -LegacyToCanonical $LegacyToCanonical
        if ($normalized -ne "" -and $normalized -notin $resolved) {
            $resolved += $normalized
        }
    }
    return $resolved
}

function Resolve-LocalSkillPath {
    param(
        [string]$CanonicalSkillId,
        [hashtable]$CanonicalToLocalPath
    )

    if ($CanonicalToLocalPath.ContainsKey($CanonicalSkillId)) {
        return $CanonicalToLocalPath[$CanonicalSkillId]
    }
    return $CanonicalSkillId
}

if (-not (Test-Path $Workspace)) {
    Write-Error "[skill-lock] workspace not found: $Workspace"
    exit 1
}

$resolvedWorkspace = (Resolve-Path $Workspace).Path
$resolvedLockPath = $SkillLockPath
if (-not [System.IO.Path]::IsPathRooted($SkillLockPath)) {
    $resolvedLockPath = Join-Path $resolvedWorkspace $SkillLockPath
}

if (-not (Test-Path $resolvedLockPath)) {
    Write-Error "[skill-lock] missing lock file: $resolvedLockPath"
    Write-Output "[skill-lock] run .codex/skills/_shared/run-task.ps1 first."
    exit 1
}

$guardrailsPath = Join-Path $resolvedWorkspace ".codex/skills/_shared/skill-guardrails.json"
$aliases = @{}
if (Test-Path $guardrailsPath) {
    $guardrails = Get-Content -Raw -Encoding utf8 $guardrailsPath | ConvertFrom-Json
    if ($guardrails.aliases) {
        foreach ($p in $guardrails.aliases.PSObject.Properties) {
            $aliases[$p.Name.ToLowerInvariant()] = $p.Value.ToString().ToLowerInvariant()
        }
    }
}

$skillRegistryPath = Join-Path $resolvedWorkspace ".codex/skills/_shared/skill-id-registry.json"
$skillRegistry = Load-SkillRegistry -RegistryPath $skillRegistryPath
$legacyToCanonical = $skillRegistry.LegacyToCanonical
$canonicalToLocalPath = $skillRegistry.CanonicalToLocalPath

$lock = Get-Content -Raw -Encoding utf8 $resolvedLockPath | ConvertFrom-Json

$requiredFields = @("task_text", "selected_skills", "required_skills", "created_at_utc", "status")
foreach ($field in $requiredFields) {
    if (-not $lock.PSObject.Properties.Name.Contains($field)) {
        Write-Error "[skill-lock] missing required field: $field"
        exit 1
    }
}

$selectedRaw = As-Array -Value $lock.selected_skills | ForEach-Object { $_.ToLowerInvariant() }
$requiredRaw = As-Array -Value $lock.required_skills | ForEach-Object { $_.ToLowerInvariant() }
$selectedSkills = @(Resolve-SkillList -Items $selectedRaw -LegacyToCanonical $legacyToCanonical)
$requiredSkills = @(Resolve-SkillList -Items $requiredRaw -LegacyToCanonical $legacyToCanonical)
$isNoSkillTask = $selectedSkills -contains "general-task"
$karpathyOptOut = $false
if ($lock.PSObject.Properties.Name -contains "karpathy_opt_out") {
    $karpathyOptOut = [bool]$lock.karpathy_opt_out
}

if ($selectedSkills.Count -eq 0) {
    Write-Error "[skill-lock] selected_skills must not be empty."
    exit 1
}

if ($isNoSkillTask) {
    if (-not $lock.PSObject.Properties.Name.Contains("no_skill_reason") -or [string]::IsNullOrWhiteSpace($lock.no_skill_reason.ToString())) {
        Write-Error "[skill-lock] general-task requires no_skill_reason."
        exit 1
    }
}

$missingRequired = $requiredSkills | Where-Object { $_ -notin $selectedSkills } | Sort-Object -Unique
if ($missingRequired.Count -gt 0) {
    Write-Error "[skill-lock] required skills are missing from selected_skills: $($missingRequired -join ', ')"
    exit 1
}

$availableSkills = Get-ChildItem -Path (Join-Path $resolvedWorkspace ".codex/skills") -Directory |
    ForEach-Object { $_.Name.ToLowerInvariant() }
$knownVirtualSkills = @("general-task")
$unknownSkills = @()
foreach ($selectedSkill in $selectedSkills) {
    if ($selectedSkill -in $knownVirtualSkills) { continue }
    $localSkillPath = Resolve-LocalSkillPath -CanonicalSkillId $selectedSkill -CanonicalToLocalPath $canonicalToLocalPath
    if ($localSkillPath -notin $availableSkills) {
        $unknownSkills += $selectedSkill
    }
}
$unknownSkills = $unknownSkills | Sort-Object -Unique
if ($unknownSkills.Count -gt 0) {
    Write-Error "[skill-lock] selected unknown skills: $($unknownSkills -join ', ')"
    exit 1
}

$codeSkills = @(
    "skill.agent.backend", "skill.agent.frontend", "skill.agent.mobile", "skill.agent.debug", "skill.agent.qa",
    "skill.verify.implementation", "skill.verify.api_schema", "skill.verify.database_layer",
    "skill.verify.crawler_engine", "skill.verify.business_logic", "skill.verify.room_pipeline"
)
$isCodeTask = (@($selectedSkills | Where-Object { $_ -in $codeSkills }).Count -gt 0) -or
    (@($requiredSkills | Where-Object { $_ -in $codeSkills }).Count -gt 0)
if ($isCodeTask -and -not $isNoSkillTask -and -not $karpathyOptOut) {
    if ("skill.governance.karpathy_guidelines" -notin $selectedSkills) {
        Write-Error "[skill-lock] code task must include skill.governance.karpathy_guidelines unless karpathy_opt_out=true."
        exit 1
    }
}

$createdAt = $null
try {
    $createdAt = [datetime]$lock.created_at_utc
} catch {
    Write-Error "[skill-lock] invalid created_at_utc value: $($lock.created_at_utc)"
    exit 1
}

$age = (Get-Date).ToUniversalTime() - $createdAt.ToUniversalTime()
if ($age.TotalHours -gt $MaxAgeHours) {
    Write-Error "[skill-lock] lock is stale ($([Math]::Round($age.TotalHours, 1))h). Create a new lock."
    exit 1
}

$normalizedAgent = Normalize-AgentType -Name $AgentType -AliasMap $aliases
$normalizedAgent = Resolve-SkillId -SkillId $normalizedAgent -LegacyToCanonical $legacyToCanonical
if ((-not $isNoSkillTask) -and $normalizedAgent -ne "ci" -and $normalizedAgent -ne "skill.workflow.orchestrator") {
    if ($normalizedAgent -notin $selectedSkills) {
        Write-Error "[skill-lock] selected_skills does not include current agent: $normalizedAgent"
        exit 1
    }
}

if ($lock.status.ToString().ToLowerInvariant() -eq "closed") {
    Write-Error "[skill-lock] lock status is closed. Create a new task lock."
    exit 1
}

Write-Output "[skill-lock] pass"
Write-Output "[skill-lock] selected=$($selectedSkills -join ', ') required=$($requiredSkills -join ', ') agent=$normalizedAgent"
exit 0
