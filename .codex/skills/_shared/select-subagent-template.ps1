param(
    [Parameter(Mandatory = $true)][string]$TaskText,
    [string]$Workspace = ".",
    [string]$ManifestPath = ".codex/subagent/template-manifest.json",
    [string]$TemplateId
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $Workspace)) {
    throw "[template-select] workspace not found: $Workspace"
}

$resolvedWorkspace = (Resolve-Path $Workspace).Path
$resolvedManifest = $ManifestPath
if (-not [System.IO.Path]::IsPathRooted($ManifestPath)) {
    $resolvedManifest = Join-Path $resolvedWorkspace $ManifestPath
}

if (-not (Test-Path $resolvedManifest)) {
    throw "[template-select] manifest not found: $resolvedManifest"
}

$manifest = Get-Content -Raw -Encoding utf8 $resolvedManifest | ConvertFrom-Json
$templates = @($manifest.templates)
if ($templates.Count -eq 0) {
    throw "[template-select] manifest has no templates."
}

$selected = $null
$selectionReason = ""
$taskLower = $TaskText.ToLowerInvariant()

if (-not [string]::IsNullOrWhiteSpace($TemplateId)) {
    $selected = $templates | Where-Object { $_.id -eq $TemplateId } | Select-Object -First 1
    if (-not $selected) {
        throw "[template-select] template not found: $TemplateId"
    }
    $selectionReason = "manual template id"
} else {
    foreach ($template in $templates) {
        $keywords = @($template.match_keywords)
        foreach ($k in $keywords) {
            $kw = $k.ToString().ToLowerInvariant()
            if ([string]::IsNullOrWhiteSpace($kw)) { continue }
            if ($taskLower.Contains($kw)) {
                $selected = $template
                $selectionReason = "keyword match: $kw"
                break
            }
        }
        if ($selected) { break }
    }

    if (-not $selected) {
        $defaultId = $manifest.default_template_id
        $selected = $templates | Where-Object { $_.id -eq $defaultId } | Select-Object -First 1
        if (-not $selected) {
            $selected = $templates[0]
            $selectionReason = "fallback: first template"
        } else {
            $selectionReason = "fallback: default template id"
        }
    }
}

$output = [ordered]@{
    template_id = $selected.id
    description = $selected.description
    skills = @($selected.skills)
    token_budget = [int]$selected.token_budget
    context_budget = [int]$selected.context_budget
    pm_mode = $selected.pm_mode
    report_schema = @($selected.report_schema)
    selection_reason = $selectionReason
}

$output | ConvertTo-Json -Depth 6
exit 0
