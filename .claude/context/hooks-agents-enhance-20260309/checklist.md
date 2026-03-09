# 실행 체크리스트

Task ID: hooks-agents-enhance-20260309

## Phase 1: 새 Hook 스크립트

- [x] `auto-format.sh` — PostToolUse(Edit|Write), 프로젝트 포매터 자동 감지/실행
- [x] `session-context-loader.sh` — SessionStart, 세션 시작 시 프로젝트 상태 주입
- [x] `subagent-post-process.sh` — SubagentStop, 서브에이전트 완료 후 다음 단계 안내

## Phase 2: 기존 Hook 업그레이드

- [x] `block-dangerous-commands.sh` — jq 지원 + 패턴 추가 (chmod 777, sudo rm 등)
- [x] `checklist-reminder.sh` — 미완료 항목 목록까지 출력

## Phase 3: Subagent 고도화

- [x] `code-reviewer.md` — isolation: worktree, maxTurns: 15, skills: [review]
- [x] `task-planner.md` — maxTurns: 20, skills: [pm]
- [x] `test-runner.md` — isolation: worktree, maxTurns: 10
- [x] `doc-writer.md` — maxTurns: 15, skills: [document, context-builder]
- [x] `security-auditor.md` — 신규 생성 (worktree, plan 모드, skills: [qa])

## Phase 4: 자동 위임 규칙

- [x] CLAUDE.md에 서브에이전트 자동 위임 규칙 섹션 추가
- [x] skill-routing.md에 서브에이전트 위임 매핑 추가

## Phase 5: settings.json + 문서

- [x] settings.json에 SessionStart, PostToolUse, SubagentStop 이벤트 추가
- [x] README.md 업데이트 (Hooks 5개, Subagents 5개, 구조 갱신)
