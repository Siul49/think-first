param(
    [Parameter(Mandatory = $true)][string]$TaskText,
    [string]$Workspace = ".",
    [string]$AgentType = "orchestrator",
    [string[]]$SelectedSkills = @(),
    [string]$SkillLockPath = ".codex/context/skill-lock.json",
    [string]$TemplateManifestPath = ".codex/subagent/template-manifest.json",
    [string]$TemplateId,
    [switch]$DisableKarpathy,
    [switch]$NoSkill,
    [string]$NoSkillReason
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

function Normalize-SkillList {
    param([object[]]$Items)
    $results = @()
    foreach ($item in $Items) {
        if ($null -eq $item) { continue }
        $normalized = $item.ToString().Trim().ToLowerInvariant()
        if ($normalized -ne "" -and $normalized -notin $results) {
            $results += $normalized
        }
    }
    return $results
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
        throw "[run-task] failed to parse skill registry: $RegistryPath"
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
        [object[]]$Items,
        [hashtable]$LegacyToCanonical
    )

    $normalized = Normalize-SkillList -Items $Items
    $results = @()
    foreach ($item in $normalized) {
        $resolved = Resolve-SkillId -SkillId $item -LegacyToCanonical $LegacyToCanonical
        if ($resolved -ne "" -and $resolved -notin $results) {
            $results += $resolved
        }
    }
    return $results
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
    throw "[run-task] workspace not found: $Workspace"
}
$resolvedWorkspace = (Resolve-Path $Workspace).Path

$guardrailsPath = Join-Path $resolvedWorkspace ".codex/skills/_shared/skill-guardrails.json"
if (-not (Test-Path $guardrailsPath)) {
    throw "[run-task] guardrails file not found: $guardrailsPath"
}

$guardrails = Get-Content -Raw -Encoding utf8 $guardrailsPath | ConvertFrom-Json
$aliasMap = @{}
if ($guardrails.aliases) {
    foreach ($p in $guardrails.aliases.PSObject.Properties) {
        $aliasMap[$p.Name.ToLowerInvariant()] = $p.Value.ToString().ToLowerInvariant()
    }
}

$skillRegistryPath = Join-Path $resolvedWorkspace ".codex/skills/_shared/skill-id-registry.json"
$skillRegistry = Load-SkillRegistry -RegistryPath $skillRegistryPath
$legacyToCanonical = $skillRegistry.LegacyToCanonical
$canonicalToLocalPath = $skillRegistry.CanonicalToLocalPath

$taskLower = $TaskText.ToLowerInvariant()
$requiredSkills = @()
$matchedRules = @()
foreach ($rule in $guardrails.rules) {
    $skillId = Resolve-SkillId -SkillId $rule.skill.ToString() -LegacyToCanonical $legacyToCanonical
    $keywords = @($rule.keywords)
    $hitKeyword = $null
    foreach ($keywordObj in $keywords) {
        $keyword = $keywordObj.ToString().Trim().ToLowerInvariant()
        if ($keyword -eq "") { continue }
        if ($taskLower.Contains($keyword)) {
            $hitKeyword = $keyword
            break
        }
    }

    if ($hitKeyword) {
        if ($skillId -notin $requiredSkills) {
            $requiredSkills += $skillId
        }
        $matchedRules += [pscustomobject]@{
            skill = $skillId
            keyword = $hitKeyword
        }
    }
}

$hasExplicitSelectedSkills = @($SelectedSkills).Count -gt 0
$templateSelection = $null
$templateSelectorScript = Join-Path $resolvedWorkspace ".codex/skills/_shared/select-subagent-template.ps1"
if (-not $NoSkill -and (Test-Path $templateSelectorScript)) {
    $selectionJson = & $templateSelectorScript -TaskText $TaskText -Workspace $resolvedWorkspace -ManifestPath $TemplateManifestPath -TemplateId $TemplateId
    if ($LASTEXITCODE -ne 0) {
        throw "[run-task] template selection failed."
    }
    if (-not [string]::IsNullOrWhiteSpace($selectionJson)) {
        $templateSelection = $selectionJson | ConvertFrom-Json
    }
}

$templateSkills = @()
if ($templateSelection -and $templateSelection.skills) {
    $templateSkills = @(Resolve-SkillList -Items @($templateSelection.skills) -LegacyToCanonical $legacyToCanonical)
}

$normalizedSelected = @(Resolve-SkillList -Items $SelectedSkills -LegacyToCanonical $legacyToCanonical)
$autoFallbackApplied = $false
$karpathyAutoInjected = $false

if ($NoSkill) {
    if ([string]::IsNullOrWhiteSpace($NoSkillReason)) {
        throw "[run-task] -NoSkill requires -NoSkillReason."
    }
    $requiredSkills = @()
    $normalizedSelected = @("general-task")
}
elseif ($hasExplicitSelectedSkills) {
    # Keep explicit selection as base.
}
elseif ($templateSkills.Count -gt 0) {
    $normalizedSelected = @($templateSkills)
}
elseif ($requiredSkills.Count -gt 0) {
    $normalizedSelected = @($requiredSkills)
}
else {
    $normalizedSelected = @("skill.workflow.guide")
    $autoFallbackApplied = $true
}

$normalizedSelected = @(Resolve-SkillList -Items $normalizedSelected -LegacyToCanonical $legacyToCanonical)
$requiredSkills = @(Resolve-SkillList -Items $requiredSkills -LegacyToCanonical $legacyToCanonical)

$normalizedAgent = Normalize-AgentType -Name $AgentType -AliasMap $aliasMap
$normalizedAgent = Resolve-SkillId -SkillId $normalizedAgent -LegacyToCanonical $legacyToCanonical
if ($normalizedAgent -ne "skill.workflow.orchestrator" -and $normalizedAgent -notin $normalizedSelected) {
    $normalizedSelected += $normalizedAgent
}

if (-not $NoSkill -and $requiredSkills.Count -gt 0) {
    foreach ($requiredSkill in $requiredSkills) {
        if ($requiredSkill -notin $normalizedSelected) {
            $normalizedSelected += $requiredSkill
        }
    }
}

$codeSkills = @(
    "skill.agent.backend", "skill.agent.frontend", "skill.agent.mobile", "skill.agent.debug", "skill.agent.qa",
    "skill.verify.implementation", "skill.verify.api_schema", "skill.verify.database_layer",
    "skill.verify.crawler_engine", "skill.verify.business_logic", "skill.verify.room_pipeline"
)
$isCodeTask = (@($normalizedSelected | Where-Object { $_ -in $codeSkills }).Count -gt 0) -or
    (@($requiredSkills | Where-Object { $_ -in $codeSkills }).Count -gt 0)

if (-not $NoSkill -and -not $DisableKarpathy -and $isCodeTask) {
    if ("skill.governance.karpathy_guidelines" -notin $normalizedSelected) {
        $normalizedSelected += "skill.governance.karpathy_guidelines"
        $karpathyAutoInjected = $true
    }
    if ("skill.governance.karpathy_guidelines" -notin $requiredSkills) {
        $requiredSkills += "skill.governance.karpathy_guidelines"
    }
}

$missingRequired = $requiredSkills | Where-Object { $_ -notin $normalizedSelected } | Sort-Object -Unique
if ($missingRequired.Count -gt 0) {
    throw "[run-task] selected skills missing required skills: $($missingRequired -join ', ')"
}

$availableSkills = Get-ChildItem -Path (Join-Path $resolvedWorkspace ".codex/skills") -Directory |
    ForEach-Object { $_.Name.ToLowerInvariant() }
$knownVirtualSkills = @("general-task")
$unknownSkills = @()
foreach ($selectedSkill in $normalizedSelected) {
    if ($selectedSkill -in $knownVirtualSkills) { continue }
    $localSkillPath = Resolve-LocalSkillPath -CanonicalSkillId $selectedSkill -CanonicalToLocalPath $canonicalToLocalPath
    if ($localSkillPath -notin $availableSkills) {
        $unknownSkills += $selectedSkill
    }
}
$unknownSkills = $unknownSkills | Sort-Object -Unique
if ($unknownSkills.Count -gt 0) {
    throw "[run-task] selected unknown skills: $($unknownSkills -join ', ')"
}

$resolvedLockPath = $SkillLockPath
if (-not [System.IO.Path]::IsPathRooted($SkillLockPath)) {
    $resolvedLockPath = Join-Path $resolvedWorkspace $SkillLockPath
}
New-Item -ItemType Directory -Path (Split-Path -Parent $resolvedLockPath) -Force | Out-Null

$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$lock = [ordered]@{
    lock_version = 2
    status = "active"
    created_at_utc = $timestamp
    updated_at_utc = $timestamp
    workspace = $resolvedWorkspace
    task_text = $TaskText
    entry_agent = $normalizedAgent
    selected_skills = $normalizedSelected
    required_skills = $requiredSkills
    matched_rules = $matchedRules
}

if ($templateSelection) {
    $lock["template"] = [ordered]@{
        id = $templateSelection.template_id
        selection_reason = $templateSelection.selection_reason
        pm_mode = $templateSelection.pm_mode
    }
    $lock["token_budget"] = [int]$templateSelection.token_budget
    $lock["context_budget"] = [int]$templateSelection.context_budget
    $lock["report_schema"] = @($templateSelection.report_schema)
}

if ($NoSkill) {
    $lock["no_skill_reason"] = $NoSkillReason.Trim()
}
if ($DisableKarpathy) {
    $lock["karpathy_opt_out"] = $true
}
if ($karpathyAutoInjected) {
    $lock["karpathy_auto_injected"] = $true
}
if ($autoFallbackApplied) {
    $lock["fallback_reason"] = "no matching skill rule found; skill.workflow.guide selected automatically"
}

$contextPackScript = Join-Path $resolvedWorkspace ".codex/skills/_shared/build-context-pack.ps1"
if (-not $NoSkill -and (Test-Path $contextPackScript)) {
    $packTokenBudget = 3000
    $packContextBudget = 1200
    $packReportSchema = @("changed_files", "tests", "risk", "decision")
    $packTemplateId = "manual"

    if ($templateSelection) {
        $packTokenBudget = [int]$templateSelection.token_budget
        $packContextBudget = [int]$templateSelection.context_budget
        $packReportSchema = @($templateSelection.report_schema)
        $packTemplateId = $templateSelection.template_id
    }

    $contextPackPath = & $contextPackScript `
        -Workspace $resolvedWorkspace `
        -TaskText $TaskText `
        -TemplateId $packTemplateId `
        -TokenBudget $packTokenBudget `
        -ContextBudget $packContextBudget `
        -SelectedSkills $normalizedSelected `
        -ReportSchema $packReportSchema `
        -OutputPath ".codex/context/context-pack.json"

    if ($LASTEXITCODE -ne 0) {
        throw "[run-task] failed to build context pack."
    }
    if (-not [string]::IsNullOrWhiteSpace($contextPackPath)) {
        $lock["context_pack_path"] = $contextPackPath.Trim()
    }
}

$lockJson = $lock | ConvertTo-Json -Depth 8
Set-Content -Path $resolvedLockPath -Value $lockJson -Encoding utf8

$validatorScript = Join-Path $resolvedWorkspace ".codex/skills/_shared/validate-skill-lock.ps1"
if (-not (Test-Path $validatorScript)) {
    throw "[run-task] validator script not found: $validatorScript"
}

& $validatorScript -Workspace $resolvedWorkspace -AgentType $normalizedAgent -SkillLockPath $resolvedLockPath
if ($LASTEXITCODE -ne 0) {
    throw "[run-task] lock validation failed"
}

Write-Output "[run-task] lock created: $resolvedLockPath"
Write-Output "[run-task] entry_agent=$normalizedAgent"
Write-Output "[run-task] selected_skills=$($normalizedSelected -join ', ')"
Write-Output "[run-task] required_skills=$($requiredSkills -join ', ')"
if ($templateSelection) {
    Write-Output "[run-task] template_id=$($templateSelection.template_id) reason=$($templateSelection.selection_reason)"
}
if ($karpathyAutoInjected) {
    Write-Output "[run-task] karpathy=auto-injected"
}
if ($autoFallbackApplied) {
    Write-Output "[run-task] fallback=skill.workflow.guide (no routing keyword match)"
}
exit 0
