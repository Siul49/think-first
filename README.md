# skill-pack

Claude Code 기반 재사용 가능한 에이전트 스킬 번들.
다른 프로젝트에 설치하여 AI 에이전트 워크플로우를 표준화합니다.

## 왜 skill-pack인가?

- **스킬 자동 활성화**: 백엔드 작업이면 backend 스킬이, 버그면 debug 스킬이 알아서 켜집니다
- **복합 작업 자동 관리**: 큰 작업은 계획서 → 체크리스트 → 검증까지 자동으로 진행
- **컨텍스트 절약**: 필요한 리소스만 동적으로 로드하여 컨텍스트 낭비를 방지
- **설치 한 번이면 끝**: 스크립트 한 줄로 어떤 프로젝트든 적용 가능

## 포함된 스킬

| 스킬 | 유형 | 용도 |
|------|------|------|
| `backend` | 자동 | API, DB, 인증, 서버 로직 |
| `frontend` | 자동 | UI, 컴포넌트, 스타일링, 반응형 |
| `mobile` | 자동 | iOS, Android, Flutter, React Native |
| `debug` | 자동 | 버그 진단, 에러 추적, 핫픽스 |
| `qa` | 자동 | 보안/성능/접근성 전체 감사 |
| `review` | 자동 | diff 중심 빠른 코드 리뷰 |
| `pm` | 자동 | 기획, 태스크 분해, 스프린트 계획 |
| `commit` | 자동 | Conventional Commits 규격 커밋 |
| `research` | 자동 | 기술 조사, 선행 리서치, 비교 분석 |
| `document` | 자동 | 문서화, API 문서, 아키텍처 문서 |
| `context-builder` | 자동 | 프로젝트 컨텍스트 문서 자동 생성 |
| `verify-implementation` | 수동 | 통합 검증 파이프라인 |
| `manage-skills` | 수동 | 검증 스킬 자동 생성/관리 |

## 구조

```
.claude/
├── skills/                  # 스킬 정의 (SKILL.md + resources/)
│   ├── backend/             # API, DB, 서버 로직
│   ├── frontend/            # UI, 컴포넌트, 스타일링
│   ├── mobile/              # iOS, Android, Flutter
│   ├── debug/               # 버그 진단, 에러 추적
│   ├── qa/                  # 보안/성능/접근성 감사
│   ├── review/              # 코드 리뷰
│   ├── pm/                  # 기획, 태스크 분해
│   ├── commit/              # Conventional Commits
│   ├── research/            # 기술 조사, 선행 리서치
│   ├── document/            # 문서화, API/아키텍처 문서
│   ├── context-builder/     # 프로젝트 컨텍스트 자동 생성
│   ├── verify-implementation/  # 통합 검증 파이프라인
│   ├── manage-skills/       # 검증 스킬 자동 생성/관리
│   └── _shared/resources/   # 공유 리소스
├── agents/                  # 서브에이전트 (자동 위임)
│   ├── code-reviewer.md     # 코드 리뷰 (worktree 격리)
│   ├── task-planner.md      # 복합 작업 계획서
│   ├── test-runner.md       # 테스트 실행 (worktree 격리)
│   ├── doc-writer.md        # 문서 생성/갱신
│   └── security-auditor.md  # 보안 스캔 (worktree 격리)
├── hooks/                   # 이벤트 Hook 스크립트
│   ├── session-context-loader.sh  # SessionStart
│   ├── block-dangerous-commands.sh  # PreToolUse(Bash)
│   ├── auto-format.sh       # PostToolUse(Edit|Write)
│   ├── checklist-reminder.sh  # Stop
│   └── subagent-post-process.sh  # SubagentStop
├── settings.json            # Hook 등록, 권한 설정
└── context/                 # 복합 작업 문서 (런타임)
CLAUDE.md                    # 프로젝트 설정 템플릿
```

## 설치

### 스크립트로 설치

```bash
git clone https://github.com/Siul49/skill-pack.git
bash skill-pack/scripts/install.sh /path/to/your-project --with-claude-md
```

### 수동 설치

```bash
cp -r skill-pack/.claude/skills/ your-project/.claude/skills/
cp skill-pack/CLAUDE.md your-project/CLAUDE.md
```

### 설치 후 할 일

1. `CLAUDE.md`를 프로젝트에 맞게 수정
   - `사용자 환경`: 호칭, 문체, 시간대
   - `커밋 규칙`: Co-Authored-By 이메일
   - 불필요한 스킬 디렉토리 삭제 (예: 모바일 미사용 시 `mobile/` 삭제)
2. `manage-skills` 스킬로 프로젝트에 맞는 `verify-*` 스킬 생성

## 업데이트

```bash
cd skill-pack && git pull
bash scripts/install.sh /path/to/your-project
```

스킬만 덮어쓰고 `CLAUDE.md`는 건드리지 않습니다.

## 스킬 동작 방식

- **도메인 스킬** (backend, frontend 등): 맥락에 따라 자동 활성화
- **검증 스킬** (verify-implementation, manage-skills): 수동 호출 시 실행
- 각 스킬은 `SKILL.md`(규칙)와 `resources/`(상세 리소스)로 구성

## 서브에이전트

독립 컨텍스트에서 전문화된 작업을 위임합니다. 상황에 따라 자동으로 호출되며, 읽기 전용 에이전트는 worktree 격리로 안전하게 실행됩니다.

| 에이전트 | 모델 | 용도 | Worktree | 자동 호출 조건 |
|---------|------|------|----------|---------------|
| `code-reviewer` | sonnet | 코드 리뷰 | YES | 코드 수정 완료 후 |
| `task-planner` | inherit | 복합 작업 계획서 | NO | 복합 작업 감지 시 |
| `test-runner` | haiku | 테스트 실행/분석 | YES | 구현 완료 후 |
| `doc-writer` | sonnet | 문서 생성/갱신 | NO | 기능 완료 후 |
| `security-auditor` | sonnet | 보안 취약점 스캔 | YES | 인증/보안 코드 변경 시 |

### Worktree 격리

읽기 전용 에이전트는 `isolation: worktree`로 독립된 git worktree에서 실행됩니다.
메인 작업과 충돌 없이 병렬 실행이 가능하며, 완료 후 자동으로 정리됩니다.

## Hooks

파일 수정, 명령 실행, 세션 시작/종료 등의 이벤트에 자동으로 반응합니다.

| Hook | 이벤트 | 동작 |
|------|--------|------|
| 세션 컨텍스트 로더 | `SessionStart` | 브랜치, 미커밋 변경, 진행 중 태스크 상태 주입 |
| 위험 명령 차단 | `PreToolUse(Bash)` | `rm -rf /`, `git push --force main` 등 차단 |
| 자동 포매팅 | `PostToolUse(Edit\|Write)` | 파일 수정 후 프로젝트 포매터 자동 실행 |
| 체크리스트 리마인더 | `Stop` | 복합 작업 중 미완료 항목 목록 알림 |
| 서브에이전트 후처리 | `SubagentStop` | 서브에이전트 완료 후 다음 단계 안내 |

Hook 스크립트는 `.claude/hooks/`에 위치하며, `.claude/settings.json`에서 등록합니다.

## 복합 작업 프로토콜

파일 3개 이상 수정, 도메인 2개 이상 연동 등 큰 작업은 자동으로:

1. **계획서 작성** → `.claude/context/{task-id}/`에 plan, checklist, context 생성
2. **실행** → 스킬 라우팅에 따라 진행, 체크리스트 자동 업데이트
3. **검증** → 체크리스트 + 성공 기준 대조
4. **보고** → What / Why / Result 형식

## 기여

이슈와 PR을 환영합니다. 기여 시 다음을 지켜주세요:

- Conventional Commits 형식으로 커밋
- 한국어 문서 기본 (식별자, 명령어는 영어 유지)
- 새 스킬 추가 시 `SKILL.md` + `resources/` 구조 준수

## 라이선스

[Apache License 2.0](LICENSE)
