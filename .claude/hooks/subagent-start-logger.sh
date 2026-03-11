#!/usr/bin/env bash
# Hook: SubagentStart
# 서브에이전트 시작 시 로깅

set -euo pipefail

# stdin에서 JSON 읽기
INPUT=$(cat)

AGENT_NAME=$(echo "$INPUT" | grep -o '"agent_name":"[^"]*"' | head -1 | cut -d'"' -f4 2>/dev/null || echo "unknown")
SESSION_ID=$(echo "$INPUT" | grep -o '"session_id":"[^"]*"' | head -1 | cut -d'"' -f4 2>/dev/null || echo "unknown")

# 로그 디렉토리 생성
LOG_DIR=".claude/context/.logs"
mkdir -p "$LOG_DIR"

# 로그 기록
echo "[$(date '+%Y-%m-%d %H:%M:%S')] SubagentStart: $AGENT_NAME (session: $SESSION_ID)" >> "$LOG_DIR/subagent-activity.log"

exit 0
