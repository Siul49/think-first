#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <workspace> <agent-type>" >&2
  exit 2
fi

workspace="$1"
agent_type="$2"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
report_dir="$repo_root/.agent/reports"
mkdir -p "$report_dir"

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
report_file="$report_dir/postflight-${agent_type}.md"

if [[ ! -d "$workspace" ]]; then
  echo "[postflight] workspace not found: $workspace" >&2
  exit 1
fi

changed_files="$(git -C "$workspace" diff --name-only HEAD 2>/dev/null || true)"
changed_count=0
if [[ -n "$changed_files" ]]; then
  changed_count="$(printf "%s\n" "$changed_files" | sed '/^$/d' | wc -l | tr -d ' ')"
fi

{
  echo "# Postflight Report"
  echo
  echo "- Timestamp (UTC): $timestamp"
  echo "- Agent Type: $agent_type"
  echo "- Workspace: $workspace"
  echo "- Changed Files Count: $changed_count"
  echo
  echo "## Changed Files"
  if [[ -n "$changed_files" ]]; then
    printf "%s\n" "$changed_files" | sed 's/^/- /'
  else
    echo "- (none)"
  fi
} > "$report_file"

echo "[postflight] wrote report: $report_file"
