param(
    [string]$ConfigPath = ".codex/project-fit-orchestrator.json",
    [switch]$Init
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $scriptDir "../../../..")).Path
$skillsRoot = Join-Path $repoRoot ".codex/skills"
$templatePath = Join-Path (Join-Path $scriptDir "..") "resources/project-fit-orchestrator.example.json"
$customizerScript = Join-Path $repoRoot ".codex/skills/project-customizer/scripts/apply-project-customization.ps1"

function Ensure-Config {
    param([string]$Path, [string]$Template)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Path) | Out-Null
        Copy-Item -Path $Template -Destination $Path -Force
        Write-Output "[project-fit] created config template: $Path"
        return $false
    }
    return $true
}

function Get-VerifyCommands {
    param([string]$SkillFile)

    $content = Get-Content -Raw $SkillFile
    $matches = [regex]::Matches($content, '(?ms)```bash\s*(.*?)\s*```')
    $commands = @()
    foreach ($m in $matches) {
        $cmd = $m.Groups[1].Value.Trim()
        if (-not [string]::IsNullOrWhiteSpace($cmd)) {
            $commands += $cmd
        }
    }
    return $commands
}

function New-Report {
    param(
        [string]$ReportFile,
        [object[]]$Results
    )

    $bt = [char]96
    $lines = @(
        "# Project Fit Orchestrator Report",
        "",
        "- Timestamp (UTC): $((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))",
        "- Total Skills: $($Results.Count)",
        "",
        "| Skill | Status | Command Count | Failures |",
        "|------|--------|---------------|----------|"
    )

    foreach ($r in $Results) {
        $lines += "| $($r.Skill) | $($r.Status) | $($r.CommandCount) | $($r.Failures) |"
    }

    $lines += ""
    $lines += "## Command Results"
    foreach ($r in $Results) {
        $lines += ""
        $lines += "### $($r.Skill)"
        foreach ($c in $r.Commands) {
            $lines += "- [$($c.Status)] $bt$($c.Command)$bt"
        }
    }

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $ReportFile) | Out-Null
    $lines | Set-Content -Path $ReportFile -Encoding utf8
}

$resolvedConfig = Join-Path $repoRoot $ConfigPath
$hasConfig = Ensure-Config -Path $resolvedConfig -Template $templatePath
if ($Init -or -not $hasConfig) {
    Write-Output "[project-fit] edit config and rerun."
    exit 0
}

$configObj = Get-Content -Raw $resolvedConfig | ConvertFrom-Json
$config = @{}
foreach ($p in $configObj.PSObject.Properties) {
    $config[$p.Name] = $p.Value
}

$runCustomizer = $false
if ($config.ContainsKey("run_customizer_first")) {
    $runCustomizer = [bool]$config.run_customizer_first
}

if ($runCustomizer) {
    if (-not (Test-Path $customizerScript)) {
        throw "project-customizer script not found: $customizerScript"
    }
    $customPaths = @()
    if ($config.ContainsKey("customization_config_paths")) {
        $customPaths = @($config.customization_config_paths)
    }
    foreach ($path in $customPaths) {
        Write-Output "[project-fit] running project-customizer: $path"
        & $customizerScript -ConfigPath $path -RunValidation
        if ($LASTEXITCODE -ne 0) {
            throw "project-customizer failed: $path"
        }
    }
}

$targetSkills = @()
if ($config.ContainsKey("verify_skill_names") -and @($config.verify_skill_names).Count -gt 0) {
    $targetSkills = @($config.verify_skill_names)
} else {
    $targetSkills = Get-ChildItem -Path $skillsRoot -Directory -Filter "verify-*" |
        Where-Object { $_.Name -ne "verify-implementation" } |
        ForEach-Object { $_.Name }
}

if ($targetSkills.Count -eq 0) {
    throw "no verify skills to run"
}

$jobs = @()
foreach ($skill in $targetSkills) {
    $skillFile = Join-Path (Join-Path $skillsRoot $skill) "SKILL.md"
    if (-not (Test-Path $skillFile)) {
        throw "skill file not found: $skillFile"
    }
    $commands = Get-VerifyCommands -SkillFile $skillFile
    if ($commands.Count -eq 0) {
        Write-Output "[project-fit] no bash checks in $skill; skipping"
        continue
    }

    $jobs += Start-Job -Name $skill -ScriptBlock {
        param($skillName, $repoPath, $cmds)
        Set-Location $repoPath
        $resultRows = @()
        $failCount = 0

        foreach ($cmd in $cmds) {
            try {
                Invoke-Expression $cmd | Out-Null
                if ($LASTEXITCODE -ne 0) { throw "Non-zero exit code" }
                $resultRows += [pscustomobject]@{ Command = $cmd; Status = "PASS" }
            } catch {
                $failCount++
                $resultRows += [pscustomobject]@{ Command = $cmd; Status = "FAIL" }
            }
        }

        [pscustomobject]@{
            Skill        = $skillName
            Status       = if ($failCount -eq 0) { "PASS" } else { "FAIL" }
            CommandCount = $cmds.Count
            Failures     = $failCount
            Commands     = $resultRows
        }
    } -ArgumentList $skill, $repoRoot, $commands
}

if ($jobs.Count -eq 0) {
    throw "no runnable verify jobs found"
}

Wait-Job -Job $jobs | Out-Null
$results = @()
foreach ($job in $jobs) {
    $results += Receive-Job -Job $job
    Remove-Job -Job $job | Out-Null
}

$reportPath = ".codex/reports/project-fit-orchestrator.md"
if ($config.ContainsKey("report_path") -and -not [string]::IsNullOrWhiteSpace($config.report_path)) {
    $reportPath = $config.report_path
}
$resolvedReport = Join-Path $repoRoot $reportPath
New-Report -ReportFile $resolvedReport -Results $results

$failed = @($results | Where-Object { $_.Status -eq "FAIL" }).Count
Write-Output "[project-fit] completed. report: $resolvedReport"
if ($failed -gt 0) {
    Write-Output "[project-fit] failed skills: $failed"
    exit 1
}
Write-Output "[project-fit] all skills passed"
exit 0
