#!/usr/bin/env bash
# Hook: InstructionsLoaded
# CLAUDE.md 등 인스트럭션 파일 로딩 시 기본 유효성 검증

set -euo pipefail

# CLAUDE.md 존재 여부 확인
if [[ ! -f "CLAUDE.md" ]]; then
  echo "[인스트럭션 검증] CLAUDE.md가 없습니다. 프로젝트 설정이 필요할 수 있습니다."
  exit 0
fi

# 필수 섹션 확인
MISSING_SECTIONS=""
for section in "핵심 원칙" "Skills" "커밋 규칙"; do
  if ! grep -q "$section" "CLAUDE.md" 2>/dev/null; then
    MISSING_SECTIONS="$MISSING_SECTIONS $section,"
  fi
done

if [[ -n "$MISSING_SECTIONS" ]]; then
  echo "[인스트럭션 검증] CLAUDE.md에 누락된 섹션: ${MISSING_SECTIONS%, }"
fi

# 스킬 디렉토리와 CLAUDE.md 동기화 확인
if [[ -d ".claude/skills" ]]; then
  SKILL_COUNT=$(find .claude/skills -maxdepth 1 -mindepth 1 -type d ! -name '_shared' 2>/dev/null | wc -l | tr -d ' ')
  DOC_SKILL_COUNT=$(grep -c '| `[a-z]' "CLAUDE.md" 2>/dev/null || echo "0")

  if [[ "$SKILL_COUNT" -ne "$DOC_SKILL_COUNT" && "$SKILL_COUNT" -gt 0 ]]; then
    echo "[인스트럭션 검증] 스킬 수 불일치: 디렉토리 ${SKILL_COUNT}개 vs CLAUDE.md ${DOC_SKILL_COUNT}개"
  fi
fi

exit 0
