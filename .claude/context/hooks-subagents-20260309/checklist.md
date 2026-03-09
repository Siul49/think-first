# 실행 체크리스트

Task ID: hooks-subagents-20260309

## Phase 1: Hook 스크립트 작성

- [x] `.claude/hooks/` 디렉토리 생성
- [x] `block-dangerous-commands.sh` — 위험 명령 차단
- [x] `checklist-reminder.sh` — 복합 작업 체크리스트 리마인더

## Phase 2: Settings에 Hooks 등록

- [x] `.claude/settings.json` 생성 (hooks 섹션)
- [x] PreToolUse(Bash): 위험 명령 차단
- [x] Stop: 체크리스트 리마인더

## Phase 3: Subagents 작성

- [x] `.claude/agents/code-reviewer.md`
- [x] `.claude/agents/task-planner.md`
- [x] `.claude/agents/test-runner.md`
- [x] `.claude/agents/doc-writer.md`

## Phase 4: install.sh 업데이트

- [x] agents/ 디렉토리 복사 추가
- [x] hooks/ 디렉토리 복사 추가
- [x] settings.json 복사 로직 추가
- [x] Codex 모드 대응

## Phase 5: README 업데이트

- [x] Hooks 섹션 추가
- [x] Subagents 섹션 추가
