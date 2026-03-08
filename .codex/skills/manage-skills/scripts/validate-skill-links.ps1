param(
    [string]$SkillsRoot = ".codex/skills"
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path ".").Path
$skillsPath = Join-Path $repoRoot $SkillsRoot
if (-not (Test-Path $skillsPath)) {
    Write-Error "Skills root not found: $skillsPath"
    exit 1
}

$skillFiles = Get-ChildItem -Recurse -Filter "SKILL.md" $skillsPath
$issues = @()

foreach ($sf in $skillFiles) {
    $dir = Split-Path -Parent $sf.FullName
    $content = Get-Content -Raw $sf.FullName
    $matches = [regex]::Matches($content, '`([^`]+)`')

    foreach ($m in $matches) {
        $ref = $m.Groups[1].Value.Trim()
        if ($ref -match '\s' -or $ref -match '[{}]' -or $ref -match '[*?]') { continue }
        if ($ref -notmatch '^(resources/|\.\./|\.codex/|scripts/|templates/|config/|assets/|references/)') { continue }

        $candidates = @()
        if ($ref.StartsWith('.codex/')) {
            $candidates += (Join-Path $repoRoot $ref)
        } elseif ($ref.StartsWith('scripts/')) {
            $candidates += (Join-Path $repoRoot $ref)
            $candidates += (Join-Path $dir $ref)
        } else {
            $candidates += (Join-Path $dir $ref)
        }

        $exists = $false
        foreach ($candidate in ($candidates | Select-Object -Unique)) {
            if (Test-Path $candidate) { $exists = $true; break }
        }

        if (-not $exists) {
            $issues += [pscustomobject]@{
                Skill = (Split-Path $dir -Leaf)
                SkillFile = $sf.FullName
                Reference = $ref
            }
        }
    }
}

if ($issues.Count -eq 0) {
    Write-Output "Skill link validation passed: no missing references."
    exit 0
}

$issues | Format-Table -AutoSize | Out-String | Write-Output
Write-Error "Skill link validation failed: $($issues.Count) missing references"
exit 1
