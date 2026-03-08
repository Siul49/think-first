param(
    [string]$ConfigPath = ".codex/project-customization.json",
    [switch]$Init,
    [switch]$RunValidation
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$skillDir = Resolve-Path (Join-Path $scriptDir "..")
$repoRoot = Resolve-Path (Join-Path $scriptDir "../../../..")
$skillsRoot = Join-Path $repoRoot ".codex/skills"
$templatePath = Join-Path $skillDir "resources/customization-config.example.json"

function Ensure-ConfigFile {
    param(
        [string]$Path,
        [string]$Template
    )

    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
        Copy-Item -Path $Template -Destination $Path -Force
        Write-Output "[customizer] created template config: $Path"
        return $false
    }
    return $true
}

function Assert-RequiredField {
    param(
        [hashtable]$Config,
        [string]$FieldName
    )
    if (-not $Config.ContainsKey($FieldName)) {
        throw "Missing required field: $FieldName"
    }
    $value = $Config[$FieldName]
    if ($null -eq $value) {
        throw "Required field is null: $FieldName"
    }
    if ($value -is [string] -and [string]::IsNullOrWhiteSpace($value)) {
        throw "Required field is empty: $FieldName"
    }
    if ($value -is [array] -and $value.Count -eq 0) {
        throw "Required array field is empty: $FieldName"
    }
}

function Insert-RowIntoTable {
    param(
        [string]$FilePath,
        [string]$HeaderPattern,
        [string]$Row,
        [string]$DuplicatePattern,
        [scriptblock]$RowGenerator
    )

    $text = Get-Content -Raw -Encoding utf8 $FilePath
    if ($text -match $DuplicatePattern) {
        return
    }

    $lines = Get-Content -Encoding utf8 $FilePath
    $headerIdx = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match $HeaderPattern) {
            $headerIdx = $i
            break
        }
    }
    if ($headerIdx -lt 0) {
        throw "Table header not found in $FilePath"
    }

    $insertIdx = $headerIdx + 2
    while ($insertIdx -lt $lines.Count -and $lines[$insertIdx] -match '^\|') {
        $insertIdx++
    }

    $finalRow = $Row
    if ($RowGenerator) {
        $finalRow = & $RowGenerator $lines $headerIdx $insertIdx
    }

    $newLines = @()
    if ($insertIdx -gt 0) {
        $newLines += $lines[0..($insertIdx - 1)]
    }
    $newLines += $finalRow
    if ($insertIdx -lt $lines.Count) {
        $newLines += $lines[$insertIdx..($lines.Count - 1)]
    }

    Set-Content -Path $FilePath -Value $newLines -Encoding utf8
}

function Get-NextVerifyExecutionIndex {
    param(
        [string[]]$Lines,
        [int]$HeaderIdx,
        [int]$InsertIdx
    )

    $max = 0
    for ($i = $HeaderIdx + 2; $i -lt $InsertIdx; $i++) {
        if ($Lines[$i] -match '^\|\s*(\d+)\s*\|') {
            $num = [int]$Matches[1]
            if ($num -gt $max) {
                $max = $num
            }
        }
    }
    return ($max + 1)
}

function New-VerifySkillMarkdown {
    param([hashtable]$Config)

    $name = $Config.verify_skill_name
    $displayName = $name
    if ($Config.ContainsKey("skill_display_name") -and -not [string]::IsNullOrWhiteSpace($Config.skill_display_name)) {
        $displayName = $Config.skill_display_name.ToString().Trim()
    }
    $description = $Config.verify_skill_description
    $relatedFiles = $Config.related_files
    $checks = $Config.checks
    $exceptions = $Config.exceptions
    $bt = [char]96

    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine("name: $displayName")
    [void]$sb.AppendLine("description: $description")
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("# $displayName")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("- Skill ID: $bt$name$bt")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("## Purpose")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("1. Validate project-specific contracts defined in this skill.")
    [void]$sb.AppendLine("2. Provide deterministic PASS/FAIL checks with evidence.")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("## When to run")
    [void]$sb.AppendLine()
    foreach ($keyword in $Config.routing_keywords) {
        [void]$sb.AppendLine("- Related changes around: $bt$keyword$bt")
    }
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("## Related Files")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("| File | Purpose |")
    [void]$sb.AppendLine("|------|---------|")
    foreach ($rf in $relatedFiles) {
        [void]$sb.AppendLine("| $bt$($rf.file)$bt | $($rf.purpose) |")
    }
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("## Workflow")
    [void]$sb.AppendLine()
    $step = 1
    foreach ($check in $checks) {
        [void]$sb.AppendLine("### Step ${step}: $($check.name)")
        [void]$sb.AppendLine()
        [void]$sb.AppendLine('```bash')
        [void]$sb.AppendLine($check.command)
        [void]$sb.AppendLine('```')
        [void]$sb.AppendLine()
        [void]$sb.AppendLine("PASS if $($check.pass_criteria)")
        [void]$sb.AppendLine()
        $step++
    }
    [void]$sb.AppendLine("## Output Format")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("| Check | Status | Evidence | Action |")
    [void]$sb.AppendLine("|------|--------|----------|--------|")
    [void]$sb.AppendLine("| check-name | PASS/FAIL | $bt" + "path:line" + "$bt | fix if needed |")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("## Exceptions")
    [void]$sb.AppendLine()
    foreach ($ex in $exceptions) {
        [void]$sb.AppendLine("- $ex")
    }
    return $sb.ToString()
}

if ($Init) {
    $resolvedConfigPath = Join-Path $repoRoot $ConfigPath
    Ensure-ConfigFile -Path $resolvedConfigPath -Template $templatePath | Out-Null
    Write-Output "[customizer] fill config and rerun without -Init."
    exit 0
}

$resolvedPath = Join-Path $repoRoot $ConfigPath
$hasConfig = Ensure-ConfigFile -Path $resolvedPath -Template $templatePath
if (-not $hasConfig) {
    Write-Output "[customizer] config template generated. edit it first."
    exit 0
}

$configObj = Get-Content -Raw -Encoding utf8 $resolvedPath | ConvertFrom-Json
$config = @{}
foreach ($p in $configObj.PSObject.Properties) {
    $config[$p.Name] = $p.Value
}

Assert-RequiredField -Config $config -FieldName "verify_skill_name"
Assert-RequiredField -Config $config -FieldName "verify_skill_description"
Assert-RequiredField -Config $config -FieldName "execution_description"
Assert-RequiredField -Config $config -FieldName "routing_keywords"
Assert-RequiredField -Config $config -FieldName "coverage_patterns"
Assert-RequiredField -Config $config -FieldName "related_files"
Assert-RequiredField -Config $config -FieldName "checks"
Assert-RequiredField -Config $config -FieldName "exceptions"

$verifySkillName = $config.verify_skill_name.ToString().Trim()
$bt = [char]96
if ($verifySkillName -notmatch '^verify-[a-z0-9-]+$') {
    throw "verify_skill_name must match ^verify-[a-z0-9-]+$"
}
if ($verifySkillName -eq "verify-implementation") {
    throw "verify_skill_name cannot be verify-implementation"
}

$skillDisplayName = $verifySkillName
if ($config.ContainsKey("skill_display_name") -and -not [string]::IsNullOrWhiteSpace($config.skill_display_name)) {
    $skillDisplayName = $config.skill_display_name.ToString().Trim()
}
$executionDescWithDisplay = "$skillDisplayName: $($config.execution_description)"

$verifySkillDir = Join-Path $skillsRoot $verifySkillName
New-Item -ItemType Directory -Path $verifySkillDir -Force | Out-Null
$verifySkillFile = Join-Path $verifySkillDir "SKILL.md"

$generatedMarkdown = New-VerifySkillMarkdown -Config $config
Set-Content -Path $verifySkillFile -Value $generatedMarkdown -Encoding utf8
Write-Output "[customizer] wrote verify skill: $verifySkillFile"

$verifyImplementationFile = Join-Path $skillsRoot "verify-implementation/SKILL.md"
$manageSkillsFile = Join-Path $skillsRoot "manage-skills/SKILL.md"
$routingFile = Join-Path $skillsRoot "_shared/skill-routing.md"

Insert-RowIntoTable `
    -FilePath $verifyImplementationFile `
    -HeaderPattern '^\|\s*#\s*\|\s*Skill\s*\|\s*Description\s*\|' `
    -Row "" `
    -DuplicatePattern [regex]::Escape("$bt$verifySkillName$bt") `
    -RowGenerator {
        param($lines, $headerIdx, $insertIdx)
        $next = Get-NextVerifyExecutionIndex -Lines $lines -HeaderIdx $headerIdx -InsertIdx $insertIdx
        return ("| $next | $bt$verifySkillName$bt | $executionDescWithDisplay |")
    }

Insert-RowIntoTable `
    -FilePath $manageSkillsFile `
    -HeaderPattern '^\|\s*Skill\s*\|\s*Description\s*\|\s*Coverage patterns\s*\|' `
    -Row ("| $bt$verifySkillName$bt | $executionDescWithDisplay | $bt" + ($config.coverage_patterns -join "$bt, $bt") + "$bt |") `
    -DuplicatePattern [regex]::Escape("$bt$verifySkillName$bt")

$routingKeywordsText = ($config.routing_keywords -join ", ")
Insert-RowIntoTable `
    -FilePath $routingFile `
    -HeaderPattern '^\|\s*User Request Keywords\s*\|\s*Primary Skill\s*\|\s*Notes\s*\|' `
    -Row "| $routingKeywordsText | **$verifySkillName** | Project-specific verify skill ($skillDisplayName) |" `
    -DuplicatePattern [regex]::Escape("**$verifySkillName**")

Insert-RowIntoTable `
    -FilePath $routingFile `
    -HeaderPattern '^\|\s*Skill\s*\|\s*Description\s*\|' `
    -Row "| $verifySkillName | $executionDescWithDisplay |" `
    -DuplicatePattern [regex]::Escape("| $verifySkillName |")

Write-Output "[customizer] synchronized verify-implementation/manage-skills/skill-routing"

if ($RunValidation) {
    $linkValidator = Join-Path $skillsRoot "manage-skills/scripts/validate-skill-links.ps1"
    $registryValidator = Join-Path $skillsRoot "manage-skills/scripts/validate-verify-registry.ps1"

    if (Test-Path $linkValidator) {
        & $linkValidator
    }
    if (Test-Path $registryValidator) {
        & $registryValidator -RepoRoot $repoRoot
    }
}

Write-Output "[customizer] completed"
