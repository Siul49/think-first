# 배경 및 컨텍스트

Task ID: hooks-agents-enhance-20260309

## 배경

Hooks와 Subagents가 구현되었으나 활용도가 낮다:
- Hook 2개만 사용 (PreToolUse, Stop)
- Subagent는 수동 요청 시에만 실행
- Worktree 격리 미적용

## Worktree 격리 전략

| 에이전트 | Worktree | 이유 |
|---------|----------|------|
| code-reviewer | YES | 읽기 전용, 진행 중 편집과 충돌 방지 |
| task-planner | NO | .claude/context/에 직접 쓰기 필요 |
| test-runner | YES | 안정적 스냅샷에서 테스트, 자동 정리 |
| doc-writer | NO | 문서 파일이 메인 트리에 즉시 반영되어야 함 |
| security-auditor | YES | 읽기 전용 스캔, 격리 환경에서 안전 |

## 제약

- Hook 스크립트는 bash + 표준 유틸리티만 (jq는 fallback 지원)
- auto-format.sh는 포매터 미설치 시 무시 (no-op)
- 크로스 플랫폼: Git Bash (Windows) 호환
- 프로젝트 특정 의존성 금지 (범용 스킬팩)

## 리스크

| 리스크 | 대응 |
|--------|------|
| auto-format이 편집 속도 저하 | 단일 파일만 처리, 10초 타임아웃 |
| 자동 위임 과잉 트리거 | description에 조건 명시, Claude 판단에 위임 |
| worktree 생성 지연 | 읽기 전용 에이전트만 적용 (자동 정리) |
