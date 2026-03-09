#!/usr/bin/env bash
# Stop hook: 복합 작업 중이면 체크리스트 미완료 항목 알림
# exit 0 = 알림 없음, exit 2 = Claude에 피드백

set -euo pipefail

# .claude/context/current-task.txt 확인
CONTEXT_DIR=".claude/context"
CURRENT_TASK_FILE="$CONTEXT_DIR/current-task.txt"

if [[ ! -f "$CURRENT_TASK_FILE" ]]; then
  exit 0
fi

TASK_ID=$(cat "$CURRENT_TASK_FILE" 2>/dev/null | tr -d '[:space:]')
if [[ -z "$TASK_ID" ]]; then
  exit 0
fi

CHECKLIST="$CONTEXT_DIR/$TASK_ID/checklist.md"
if [[ ! -f "$CHECKLIST" ]]; then
  exit 0
fi

# 미완료 항목 카운트
INCOMPLETE=$(grep -c '^\- \[ \]' "$CHECKLIST" 2>/dev/null || echo "0")

if [[ "$INCOMPLETE" -gt 0 ]]; then
  echo "[체크리스트 리마인더] 작업 '$TASK_ID'에 미완료 항목 ${INCOMPLETE}건이 있습니다. $CHECKLIST를 확인하세요." >&2
  exit 2
fi

exit 0
