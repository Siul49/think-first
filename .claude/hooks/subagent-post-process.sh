#!/usr/bin/env bash
# SubagentStop hook: 서브에이전트 완료 후 다음 단계 안내
# exit 0 = 통과, exit 2 = Claude에 피드백

set -euo pipefail

INPUT=$(cat)

# 에이전트 이름 추출 (jq 우선, grep fallback)
if command -v jq &>/dev/null; then
  AGENT_NAME=$(echo "$INPUT" | jq -r '.agent_name // .agentName // empty' 2>/dev/null || echo "")
else
  AGENT_NAME=$(echo "$INPUT" | grep -o '"agent_name":"[^"]*"' | head -1 | sed 's/"agent_name":"//;s/"$//' 2>/dev/null || echo "")
  if [[ -z "$AGENT_NAME" ]]; then
    AGENT_NAME=$(echo "$INPUT" | grep -o '"agentName":"[^"]*"' | head -1 | sed 's/"agentName":"//;s/"$//' 2>/dev/null || echo "")
  fi
fi

if [[ -z "$AGENT_NAME" ]]; then
  exit 0
fi

# 에이전트별 후속 안내
case "$AGENT_NAME" in
  code-reviewer)
    echo "[후속 안내] 코드 리뷰 완료. 발견 사항이 있으면 수정 후 다시 리뷰를 실행하세요." >&2
    ;;
  test-runner)
    echo "[후속 안내] 테스트 완료. 실패한 테스트가 있으면 수정이 필요합니다." >&2
    # 복합 작업 중이면 체크리스트 업데이트 안내
    if [[ -f ".claude/context/current-task.txt" ]]; then
      TASK_ID=$(cat ".claude/context/current-task.txt" 2>/dev/null | tr -d '[:space:]')
      if [[ -n "$TASK_ID" ]]; then
        echo "[체크리스트] 테스트 단계를 체크리스트에 반영하세요: .claude/context/$TASK_ID/checklist.md" >&2
      fi
    fi
    ;;
  doc-writer)
    echo "[후속 안내] 문서 갱신 완료. 변경된 문서를 확인하고 커밋에 포함하세요." >&2
    ;;
  security-auditor)
    echo "[후속 안내] 보안 감사 완료. Critical/High 이슈가 있으면 즉시 수정이 필요합니다." >&2
    ;;
  task-planner)
    echo "[후속 안내] 계획서 작성 완료. 사용자 승인 후 실행을 시작하세요." >&2
    ;;
esac

exit 0
