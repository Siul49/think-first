# 작업 계획서

Task ID: hooks-subagents-20260309

## 목표

skill-pack에 Hooks와 Subagents를 도입하여, 설치한 프로젝트에서 자동화와 작업 위임이 즉시 동작하도록 한다.

## 성공 기준

1. `.claude/settings.json`에 Hooks 정의 → 설치 시 함께 복사됨
2. `.claude/agents/`에 Subagents 정의 → 스킬과 역할 분담 명확
3. install.sh가 hooks 설정과 agents를 함께 설치
4. README에 hooks/agents 사용법 안내

---

## Part 1: Hooks

### 도입할 Hook 목록

| Hook | 이벤트 | 동작 |
|------|--------|------|
| **자동 포매팅** | `PostToolUse(Edit\|Write)` | 변경된 파일에 프로젝트 포매터 실행 |
| **위험 명령 차단** | `PreToolUse(Bash)` | `rm -rf /`, `git push --force main` 등 차단 |
| **체크리스트 리마인더** | `Stop` | 복합 작업 중이면 미완료 항목 알림 |
| **커밋 전 검증** | `PreToolUse(Bash)` | `git commit` 시 lint/test 통과 확인 |

### 설정 파일

`.claude/settings.json`에 hooks 섹션 추가.
프로젝트별로 포매터 명령을 커스터마이징할 수 있도록 주석 안내.

### 주의사항

- hooks는 `.claude/settings.json`(팀 공유)에 정의
- 개인용 override는 `.claude/settings.local.json`에서 가능
- hook 스크립트가 필요하면 `.claude/hooks/` 디렉토리에 배치

---

## Part 2: Subagents

### 스킬 vs 서브에이전트 역할 분담

| 역할 | 스킬 (유지) | 서브에이전트 (신규) |
|------|------------|-------------------|
| **용도** | "어떻게 행동할지" 규칙 | "독립적으로 실행할 작업" 위임 |
| **예시** | backend 스킬: 아키텍처 규칙 | code-reviewer: 읽기 전용 리뷰 |
| **도구 제한** | 없음 (Claude 전체 도구) | 명시적 화이트리스트 |
| **컨텍스트** | 메인 컨텍스트 공유 | 독립 (fork) |

### 도입할 Subagent 목록

| 에이전트 | 모델 | 도구 | 용도 |
|---------|------|------|------|
| `code-reviewer` | sonnet | Read, Grep, Glob | diff 리뷰 (읽기 전용, 빠름) |
| `task-planner` | inherit | Read, Grep, Glob | 복합 작업 계획서 작성 |
| `test-runner` | haiku | Bash, Read, Grep | 테스트 실행 + 결과 요약 |
| `doc-writer` | sonnet | Read, Grep, Glob, Edit, Write | 문서 생성/갱신 |

### 디렉토리 구조

```
.claude/agents/
├── code-reviewer.md
├── task-planner.md
├── test-runner.md
└── doc-writer.md
```

### 스킬과의 연동

- review 스킬 → code-reviewer 에이전트에 위임 가능
- pm 스킬 → task-planner 에이전트 활용
- qa 스킬 → code-reviewer + test-runner 조합

---

## 실행 순서

### Phase 1: Hook 스크립트 작성
1. `.claude/hooks/` 디렉토리 생성
2. 위험 명령 차단 스크립트 작성
3. 체크리스트 리마인더 스크립트 작성

### Phase 2: Settings에 Hooks 등록
4. `.claude/settings.json` 생성 (hooks 섹션)

### Phase 3: Subagents 작성
5. code-reviewer.md
6. task-planner.md
7. test-runner.md
8. doc-writer.md

### Phase 4: install.sh 업데이트
9. agents/ 디렉토리 복사 추가
10. settings.json 복사 로직 추가 (덮어쓰기 방지)

### Phase 5: README 업데이트
11. hooks/agents 사용법 안내 추가

---

## 범위

### In scope
- Hook 정의 및 스크립트
- Subagent 4개 정의
- install.sh 업데이트
- README 업데이트

### Out of scope
- 기존 스킬 삭제/대체 (스킬은 유지, 에이전트는 추가)
- MCP 서버 설정
- Worktree isolation (다음 단계)
