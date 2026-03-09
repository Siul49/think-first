#!/usr/bin/env bash
# SessionStart hook: 세션 시작 시 프로젝트 상태를 Claude에 주입
# exit 0 + stdout JSON → additionalContext로 전달

set -euo pipefail

# Git 정보 수집
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
RECENT_COMMITS=$(git log --oneline -5 2>/dev/null || echo "(커밋 없음)")

# 현재 태스크 확인
CONTEXT_DIR=".claude/context"
CURRENT_TASK=""
INCOMPLETE_ITEMS=""

if [[ -f "$CONTEXT_DIR/current-task.txt" ]]; then
  TASK_ID=$(cat "$CONTEXT_DIR/current-task.txt" 2>/dev/null | tr -d '[:space:]')
  if [[ -n "$TASK_ID" && -f "$CONTEXT_DIR/$TASK_ID/checklist.md" ]]; then
    CURRENT_TASK="$TASK_ID"
    INCOMPLETE=$(grep -c '^\- \[ \]' "$CONTEXT_DIR/$TASK_ID/checklist.md" 2>/dev/null || echo "0")
    COMPLETE=$(grep -c '^\- \[x\]' "$CONTEXT_DIR/$TASK_ID/checklist.md" 2>/dev/null || echo "0")
    INCOMPLETE_ITEMS="미완료 ${INCOMPLETE}건 / 완료 ${COMPLETE}건"
  fi
fi

# 컨텍스트 출력
CONTEXT="[프로젝트 상태]
- 브랜치: $BRANCH
- 미커밋 변경: ${UNCOMMITTED}건"

if [[ -n "$CURRENT_TASK" ]]; then
  CONTEXT="$CONTEXT
- 진행 중 태스크: $CURRENT_TASK ($INCOMPLETE_ITEMS)"
fi

CONTEXT="$CONTEXT
- 최근 커밋:
$RECENT_COMMITS"

echo "$CONTEXT" >&2
exit 0
