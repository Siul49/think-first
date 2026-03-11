#!/usr/bin/env bash
# Hook: PostToolUseFailure
# 도구 실행 실패 시 디버그 힌트 제공

set -euo pipefail

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | grep -o '"tool_name":"[^"]*"' | head -1 | cut -d'"' -f4 2>/dev/null || echo "unknown")
ERROR_MSG=$(echo "$INPUT" | grep -o '"error":"[^"]*"' | head -1 | cut -d'"' -f4 2>/dev/null || echo "")

# 도구별 디버그 힌트
case "$TOOL_NAME" in
  Bash)
    echo "[도구 실패 힌트] Bash 명령 실패. 확인 사항: 경로 존재 여부, 권한, 명령어 구문"
    ;;
  Edit)
    echo "[도구 실패 힌트] Edit 실패. 확인 사항: old_string이 파일에 정확히 존재하는지, 유니크한지"
    ;;
  Write)
    echo "[도구 실패 힌트] Write 실패. 확인 사항: 파일을 먼저 Read했는지, 디렉토리가 존재하는지"
    ;;
  Read)
    echo "[도구 실패 힌트] Read 실패. 확인 사항: 파일 경로가 절대 경로인지, 파일이 존재하는지"
    ;;
  *)
    if [[ -n "$ERROR_MSG" ]]; then
      echo "[도구 실패 힌트] $TOOL_NAME 실패: $ERROR_MSG"
    fi
    ;;
esac

exit 0
