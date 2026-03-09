# Skill-Pack — Claude Code 프로젝트 설정

재사용 가능한 에이전트 스킬 번들. 다른 프로젝트에 설치하여 AI 에이전트 워크플로우를 표준화한다.

## 사용자 환경

- 언어: 한국어 (ko)
- 호칭: `경수님`
- 문체: 친근하되 정중한 한국어. 실행 규칙은 간결한 지시형.
- 시간대: Asia/Seoul
- 보고 형식: 주요 작업은 `What`, `Why`, `Result` 포함

## 핵심 원칙

1. **간결 우선**: 요청 범위에 맞는 최소 구현. 추측성 추상화 금지.
2. **외과적 변경**: 관련 없는 리팩터링 금지. 변경은 surgical diff로.
3. **가정 표면화**: 모호한 경우 코딩 전에 가정과 트레이드오프를 먼저 공유.
4. **성공 기준 선행**: 먼저 성공 기준을 정의하고, 구현 후 검증.
5. **DRY + KISS + SOLID**: 비즈니스 로직은 Service, 데이터 접근은 Repository.

## Skills

커스텀 스킬은 `.claude/skills/`에 정의되어 있다. 맥락에 따라 자동 활성화된다.

### 도메인 스킬 (자동 활성화)

| 스킬 | 용도 |
|------|------|
| `backend` | API, DB, 인증, 서버 사이드 로직 |
| `frontend` | UI, 컴포넌트, 스타일링, 반응형 |
| `mobile` | iOS, Android, Flutter, React Native |
| `debug` | 버그 진단, 에러 추적, 핫픽스 |
| `qa` | 보안/성능/접근성 전체 감사 |
| `pm` | 기획, 태스크 분해, 스프린트 계획 |
| `commit` | Conventional Commits 규격 커밋 |
| `review` | diff 중심 빠른 코드 리뷰 |
| `research` | 기술 조사, 선행 리서치, 라이브러리 비교 |
| `document` | 문서화, API 문서, 아키텍처 문서 생성/갱신 |
| `context-builder` | 프로젝트 컨텍스트 문서 자동 생성, CLAUDE.md 갱신 |

### 검증 및 관리 스킬 (수동 호출)

| 스킬 | 용도 |
|------|------|
| `verify-implementation` | 등록된 verify 스킬을 순차 실행, 통합 검증 보고서 생성 |
| `manage-skills` | 변경사항 분석 → 검증 스킬 누락 탐지 → 자동 생성/업데이트 |

## 작업 실행 프로토콜

### 규모 판단 (작업 시작 전 필수)

아래 조건 중 **하나라도 해당하면 복합 작업**:

| 조건 | 예시 |
|------|------|
| 수정 파일 3개 이상 예상 | 새 API + UI + 테스트 |
| 2개 이상 도메인 연동 | backend + frontend |
| 새로운 아키텍처/패턴 도입 | 인증 시스템, 상태관리 전환 |
| 단계별 순서 의존성 존재 | DB 마이그레이션 → API → UI |
| 사용자가 명시적으로 계획 요청 | "설계해줘", "분석해줘" |

**단순** → 바로 실행. 계획서 없이 구현 후 결과 보고.
**복합** → 아래 4단계 절차 진입.

### 복합 작업 절차

#### Phase 1: 계획서 (승인 전 구현 금지)

`.claude/context/{task-id}/`에 문서 생성 (`task-id`: `{설명}-{YYYYMMDD}`):

| 파일 | 내용 |
|------|------|
| `plan.md` | 목표, 성공 기준, 범위(In/Out), 마일스톤 |
| `checklist.md` | 단계별 실행 체크리스트 (`- [ ]`) |
| `context.md` | 배경, 제약, 결정사항, 리스크 |

`.claude/context/current-task.txt`에 task-id 기록. **사용자 승인 후 Phase 2 진입.**

#### Phase 2: 실행

스킬 라우팅에 따라 실행. 단계 완료마다 `checklist.md` 해당 항목 체크 (`[x]`).

#### Phase 3: 검증

`checklist.md` 미완료 항목 + `plan.md` 성공 기준 대조. 실패 시 수정 후 재검증.

#### Phase 4: 보고

```
**What**: 무엇을 했는지
**Why**: 왜 이렇게 했는지
**Result**: 결과 + 미완료 항목 (있다면)
```

### 복합 요청 스킬 라우팅

| 패턴 | 순서 |
|------|------|
| 풀스택 기능 개발 | pm → (backend + frontend) 병렬 → qa |
| 모바일 앱 개발 | pm → (backend + mobile) 병렬 → qa |
| 버그 수정 후 리뷰 | debug → qa |
| 기능 추가 후 테스트 | pm → 해당 에이전트 → qa |
| 새 기술 도입 | research → pm → 구현 → qa |
| 대규모 변경 후 문서화 | 구현 → document → context-builder |

## 서브에이전트 자동 위임

다음 상황에서 해당 서브에이전트를 자동으로 호출한다:

| 상황 | 서브에이전트 | 비고 |
|------|-------------|------|
| 코드 수정 완료 후 | `code-reviewer` | worktree 격리, 변경 diff 리뷰 |
| 복합 작업 감지 시 | `task-planner` | 계획서/체크리스트/컨텍스트 자동 생성 |
| 구현 완료 후 | `test-runner` | worktree 격리, 백그라운드 테스트 |
| 기능 완료 후 | `doc-writer` | README, API 문서 갱신 |
| 인증/권한/입력검증 코드 변경 시 | `security-auditor` | worktree 격리, 보안 취약점 스캔 |

### Worktree 격리 전략

읽기 전용 에이전트(`code-reviewer`, `test-runner`, `security-auditor`)는 `isolation: worktree`로 실행한다.
메인 트리에 직접 쓰기가 필요한 에이전트(`task-planner`, `doc-writer`)는 격리하지 않는다.

## 커밋 규칙

- Conventional Commits 형식: `<type>(<scope>): <description>`
- 타입: feat, fix, refactor, docs, test, chore, style, perf
- 커밋 전 반드시 사용자 확인
- `git add -A` 또는 `git add .` 금지 — 파일명 명시
- 비밀 파일(.env, credentials 등) 커밋 금지
- Co-Authored-By: First Fluke <our.first.fluke@gmail.com>

## 한국어 문서 기준

- 제목, 섹션명, 설명, 보고 형식: 한국어 기본
- 식별자, 파일 경로, 키 이름, 명령어, 기술 약어(MCP, API, DTO 등): 영어 유지
- 용어 통일: workflow→워크플로우, verify→검증, review→리뷰, checklist→체크리스트
- 상세 가이드: `.claude/korean-docs-style-guide.md`

## 프로젝트 구조

```
.claude/
├── skills/                  # 스킬 정의 (자동 활성화)
├── skills/_shared/          # 공유 리소스 (추론 템플릿, 스킬 라우팅 등)
├── agents/                  # 서브에이전트 (자동 위임, worktree 격리)
├── hooks/                   # 이벤트 Hook 스크립트
├── settings.json            # Hook 등록, 권한 설정
└── context/                 # 복합 작업 문서 (plan, checklist, context)
```
