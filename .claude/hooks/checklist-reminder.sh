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

# 미완료 항목 수집
INCOMPLETE_COUNT=$(grep -c '^\- \[ \]' "$CHECKLIST" 2>/dev/null || echo "0")

if [[ "$INCOMPLETE_COUNT" -gt 0 ]]; then
  ITEMS=$(grep '^\- \[ \]' "$CHECKLIST" 2>/dev/null | head -10 | sed 's/^- \[ \] /  · /')
  {
    echo "[체크리스트 리마인더] 작업 '$TASK_ID'에 미완료 항목 ${INCOMPLETE_COUNT}건:"
    echo "$ITEMS"
    if [[ "$INCOMPLETE_COUNT" -gt 10 ]]; then
      echo "  ... 외 $((INCOMPLETE_COUNT - 10))건"
    fi
    echo "파일: $CHECKLIST"
  } >&2
  exit 2
fi

exit 0
