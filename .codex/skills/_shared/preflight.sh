#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <workspace> <agent-type>" >&2
  exit 2
fi

workspace="$1"
agent_type="$2"
protected_regex="${PROTECTED_FILE_REGEX:-^(\\.env|\\.env\\.|secrets/|.*\\.pem$|.*\\.key$)}"

if [[ ! -d "$workspace" ]]; then
  echo "[preflight] workspace not found: $workspace" >&2
  exit 1
fi

if ! git -C "$workspace" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[preflight] not a git workspace: $workspace" >&2
  exit 1
fi

echo "[preflight] agent=$agent_type workspace=$workspace"

changed_files="$(git -C "$workspace" diff --name-only HEAD 2>/dev/null || true)"
if [[ -n "$changed_files" ]]; then
  blocked="$(printf "%s\n" "$changed_files" | grep -E "$protected_regex" || true)"
  if [[ -n "$blocked" ]]; then
    echo "[preflight] blocked protected file changes detected:" >&2
    printf "%s\n" "$blocked" >&2
    exit 1
  fi
fi

if command -v rg >/dev/null 2>&1; then
  conflict_hits="$(git -C "$workspace" diff --name-only HEAD | xargs -r rg -n '<<<<<<<|=======|>>>>>>>' 2>/dev/null || true)"
  if [[ -n "$conflict_hits" ]]; then
    echo "[preflight] merge conflict markers found in changed files:" >&2
    printf "%s\n" "$conflict_hits" >&2
    exit 1
  fi
fi

echo "[preflight] pass"
