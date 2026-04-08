# 실행 체크리스트

## M1: 새 스킬 3종

- [x] `skill-creator/SKILL.md` 작성
- [x] `skill-creator/resources/` 리소스 파일 작성 (execution-protocol.md, skill-template.md)
- [x] `mcp-builder/SKILL.md` 작성
- [x] `mcp-builder/resources/` 리소스 파일 작성 (execution-protocol.md, server-template.md, error-playbook.md)
- [x] `webapp-testing/SKILL.md` 작성
- [x] `webapp-testing/resources/` 리소스 파일 작성 (execution-protocol.md, test-patterns.md, error-playbook.md)

## M2: Hooks 확장

- [x] `hooks/subagent-start-logger.sh` 작성 (SubagentStart)
- [x] `hooks/task-completed-reporter.sh` 작성 (TaskCompleted)
- [x] `hooks/tool-failure-handler.sh` 작성 (PostToolUseFailure)
- [x] `hooks/instructions-validator.sh` 작성 (InstructionsLoaded)
- [x] `hooks/pre-compact-saver.sh` 작성 (PreCompact)
- [x] prompt 핸들러 훅 추가 (보안 변경 감지 — PostToolUse Edit|Write)
- [x] agent 핸들러 훅 추가 (코드 품질 분석 — Stop)
- [x] `settings.json` 훅 등록 업데이트 (5→10 이벤트)

## M3: 에이전트 강화

- [x] `code-reviewer.md` — memory: [project], skills: [review]
- [x] `task-planner.md` — memory: [project], skills: [pm, research]
- [x] `test-runner.md` — memory: [project], skills: [webapp-testing]
- [x] `doc-writer.md` — memory: [project], skills: [document, context-builder]
- [x] `security-auditor.md` — memory: [project], skills: [qa]

## M4: 플러그인 패키징

- [x] `.agent-plugin/plugin.json` 메타데이터 작성
- [x] `install.sh`에 `--plugin` 모드 추가
- [x] 플러그인 구조 antigravity.md에 문서화

## M5: antigravity.md 갱신

- [x] 새 스킬 3종 테이블에 추가
- [x] 훅 이벤트 목록 (Hooks 섹션 신설)
- [x] 에이전트 기능 설명 업데이트 (서브에이전트 기능 테이블)
- [x] 프로젝트 구조에 `.agent-plugin/` 추가
