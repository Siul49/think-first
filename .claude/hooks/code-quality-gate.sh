#!/usr/bin/env bash
# Stop hook: 소스 코드 변경이 있을 때만 품질 점검 피드백 전달
# .md, .txt, .json 등 설정/문서만 변경된 경우 스킵
# exit 0 = 스킵, exit 2 = Claude에 피드백

set -euo pipefail

# 커밋 안 된 변경만 확인 (staged + unstaged, 커밋 후에는 스킵)
CHANGED_FILES=$(git diff --name-only 2>/dev/null || true)
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || true)
CHANGED_FILES=$(printf "%s\n%s" "$CHANGED_FILES" "$STAGED_FILES" | sort -u | grep -v '^$' || true)

if [[ -z "$CHANGED_FILES" ]]; then
  exit 0
fi

# 소스 코드 파일만 필터링
CODE_FILES=$(echo "$CHANGED_FILES" | grep -E '\.(ts|tsx|js|jsx|py|go|rs|java|kt|swift|dart|vue|svelte|css|scss|sh|sql)$' || true)

if [[ -z "$CODE_FILES" ]]; then
  exit 0
fi

# 이미 보고한 파일 세트와 동일하면 스킵 (반복 경고 방지)
REPORT_HASH=$(echo "$CODE_FILES" | md5sum | cut -d' ' -f1)
HASH_FILE="/tmp/.code-quality-gate-last-hash"
if [[ -f "$HASH_FILE" ]] && [[ "$(cat "$HASH_FILE")" == "$REPORT_HASH" ]]; then
  exit 0
fi
echo "$REPORT_HASH" > "$HASH_FILE"

FILE_COUNT=$(echo "$CODE_FILES" | wc -l | tr -d ' ')

{
  echo "[코드 품질 점검 권장] 소스 코드 ${FILE_COUNT}개 파일 변경 감지:"
  echo "$CODE_FILES" | head -5 | sed 's/^/  · /'
  if [[ "$FILE_COUNT" -gt 5 ]]; then
    echo "  ... 외 $((FILE_COUNT - 5))개"
  fi
  echo "중복 코드, 미사용 임포트, 명백한 로직 오류를 점검하세요."
} >&2
exit 2
