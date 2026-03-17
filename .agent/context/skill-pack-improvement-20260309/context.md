# 작업 배경

Task ID: think-first-improvement-20260309

## 배경

think-first는 원래 Codex(`.agent/`) 기반으로 개발되었고, Claude Code(`.claude/`)로 마이그레이션 중이다. SKILL.md는 마이그레이션되었으나 resources/ 파일과 context 경로가 아직 레거시 상태.

## 제약

- `.agent/` 디렉토리는 삭제하지 않음 (레거시 참조용)
- 기존 스킬의 핵심 동작을 변경하지 않음
- install.sh의 하위 호환성 유지

## 결정사항

- context 경로: `.claude/context/`로 통일 (`.claude/` 아래 일관성)
- qa/review: review는 diff 중심 빠른 리뷰, qa는 전체 감사로 분리
- resources: 바이너리/템플릿 코드 파일도 포함하여 복사

## 리스크

- resources 파일 중 Codex 전용 문법이 있을 수 있음 → 복사 후 확인
- qa/review 분리 시 기존 사용자 혼란 가능 → SKILL.md description에 명확한 구분 기술
