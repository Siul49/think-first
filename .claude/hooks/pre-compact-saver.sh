#!/usr/bin/env bash
# Hook: PreCompact
# 컨텍스트 압축 전 현재 작업 상태 보존

set -euo pipefail

CONTEXT_DIR=".claude/context"
CURRENT_TASK_FILE="$CONTEXT_DIR/current-task.txt"

if [[ ! -f "$CURRENT_TASK_FILE" ]]; then
  exit 0
fi

TASK_ID=$(head -1 "$CURRENT_TASK_FILE" | tr -d '[:space:]')

if [[ -z "$TASK_ID" ]]; then
  exit 0
fi

CHECKLIST="$CONTEXT_DIR/$TASK_ID/checklist.md"

if [[ ! -f "$CHECKLIST" ]]; then
  exit 0
fi

# 현재 진행 상태 요약
TOTAL=$(grep -c '^\s*- \[' "$CHECKLIST" 2>/dev/null || echo "0")
DONE=$(grep -c '^\s*- \[x\]' "$CHECKLIST" 2>/dev/null || echo "0")
REMAINING=$(grep '^\s*- \[ \]' "$CHECKLIST" 2>/dev/null | head -5 | sed 's/- \[ \] /  · /' || true)

echo "[컨텍스트 압축 전 알림] 현재 작업: $TASK_ID ($DONE/$TOTAL 완료)"
if [[ -n "$REMAINING" ]]; then
  echo "다음 미완료 항목:"
  echo "$REMAINING"
fi

exit 0
