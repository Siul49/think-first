#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <agent-type> <workspace>" >&2
  exit 2
fi

agent_type="$1"
workspace="$2"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
report_dir="$repo_root/.agent/reports"
mkdir -p "$report_dir"
log_file="$report_dir/verify-${agent_type}.log"

exec > >(tee "$log_file") 2>&1

echo "[verify] start agent=$agent_type workspace=$workspace"
"$script_dir/preflight.sh" "$workspace" "$agent_type"

check_ran=0
check_failed=0

run_check() {
  local label="$1"
  shift
  check_ran=$((check_ran + 1))
  echo "[verify] running: $label"
  if "$@"; then
    echo "[verify] pass: $label"
  else
    echo "[verify] fail: $label" >&2
    check_failed=$((check_failed + 1))
  fi
}

if command -v pwsh >/dev/null 2>&1; then
  if [[ -f "$repo_root/.agent/skills/manage-skills/scripts/validate-skill-links.ps1" ]]; then
    run_check "validate skill links" pwsh -NoProfile -ExecutionPolicy Bypass -File "$repo_root/.agent/skills/manage-skills/scripts/validate-skill-links.ps1"
  fi
  if [[ -f "$repo_root/.agent/skills/manage-skills/scripts/validate-verify-registry.ps1" ]]; then
    run_check "validate verify registry sync" pwsh -NoProfile -ExecutionPolicy Bypass -File "$repo_root/.agent/skills/manage-skills/scripts/validate-verify-registry.ps1" -RepoRoot "$repo_root"
  fi
fi

if [[ -f "$workspace/package.json" ]] && command -v npm >/dev/null 2>&1; then
  run_check "npm lint --if-present" npm --prefix "$workspace" run lint --if-present
  run_check "npm test --if-present" npm --prefix "$workspace" run test --if-present
fi

if [[ -d "$workspace/app" ]] && command -v python >/dev/null 2>&1; then
  run_check "python compileall app" python -m compileall -q "$workspace/app"
fi

if [[ -d "$workspace/tests" ]] && command -v pytest >/dev/null 2>&1; then
  run_check "pytest -q" pytest -q "$workspace/tests"
fi

if [[ "$check_ran" -eq 0 ]]; then
  echo "[verify] no automated checks found; fallback to git status check"
  run_check "git status" git -C "$workspace" status --short
fi

"$script_dir/postflight.sh" "$workspace" "$agent_type"

if [[ "$check_failed" -gt 0 ]]; then
  echo "[verify] completed with failures: $check_failed"
  exit 1
fi

echo "[verify] completed successfully"
