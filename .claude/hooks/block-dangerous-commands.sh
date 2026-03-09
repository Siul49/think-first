#!/usr/bin/env bash
# PreToolUse(Bash) hook: 위험한 명령어 차단
# exit 0 = 허용, exit 2 = 차단 (stderr가 Claude에 피드백)

set -euo pipefail

# stdin에서 JSON 입력 읽기
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | grep -o '"command":"[^"]*"' | head -1 | sed 's/"command":"//;s/"$//' 2>/dev/null || echo "")

# 차단 패턴 목록
BLOCKED_PATTERNS=(
  "rm -rf /"
  "rm -rf /*"
  "git push --force main"
  "git push --force master"
  "git push -f origin main"
  "git push -f origin master"
  "git reset --hard"
  "git clean -fd"
  "DROP TABLE"
  "DROP DATABASE"
  "truncate "
  "> /dev/sda"
  "mkfs."
  ":(){ :|:& };:"
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qi "$pattern" 2>/dev/null; then
    echo "차단됨: '$pattern' 패턴이 감지되었습니다. 이 명령은 실행할 수 없습니다." >&2
    exit 2
  fi
done

exit 0
