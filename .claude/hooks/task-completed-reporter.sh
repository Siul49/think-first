#!/usr/bin/env bash
# Hook: TaskCompleted
# 태스크 완료 시 체크리스트 진행률 보고

set -euo pipefail

CONTEXT_DIR=".claude/context"
CURRENT_TASK_FILE="$CONTEXT_DIR/current-task.txt"

# 현재 작업 확인
if [[ ! -f "$CURRENT_TASK_FILE" ]]; then
  exit 0
fi

TASK_ID=$(head -1 "$CURRENT_TASK_FILE" | tr -d '[:space:]')
CHECKLIST="$CONTEXT_DIR/$TASK_ID/checklist.md"

if [[ ! -f "$CHECKLIST" ]]; then
  exit 0
fi

# 체크리스트 진행률 계산
TOTAL=$(grep -c '^\s*- \[' "$CHECKLIST" 2>/dev/null || echo "0")
DONE=$(grep -c '^\s*- \[x\]' "$CHECKLIST" 2>/dev/null || echo "0")

if [[ "$TOTAL" -gt 0 ]]; then
  PCT=$(( DONE * 100 / TOTAL ))
  echo "[태스크 완료 보고] 작업 '$TASK_ID': $DONE/$TOTAL 완료 (${PCT}%)"

  if [[ "$DONE" -eq "$TOTAL" ]]; then
    echo "  모든 항목 완료! Phase 4 보고로 진행하세요."
  fi
fi

exit 0
