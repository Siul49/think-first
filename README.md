# skill-pack

Claude Code 기반 재사용 가능한 에이전트 스킬 번들.
다른 프로젝트에 설치하여 AI 에이전트 워크플로우를 표준화합니다.

## 왜 skill-pack인가?

Claude Code는 강력하지만, 프로젝트마다 스킬/훅/에이전트를 매번 설정하는 건 반복 작업입니다.
skill-pack은 이 설정을 **한 번 만들고, 어디서든 재사용**할 수 있게 합니다.

- **16개 스킬 자동 활성화**: 백엔드 작업이면 backend, 버그면 debug, MCP 서버면 mcp-builder가 알아서 켜집니다
- **5개 서브에이전트 자동 위임**: 코드 리뷰, 테스트, 보안 감사를 독립 에이전트가 worktree 격리 환경에서 처리
- **10개 이벤트 훅 + 3가지 핸들러**: command, prompt(LLM 판단), agent(에이전트 분석)으로 보안 감지, 품질 점검, 컨텍스트 보존까지 자동화
- **복합 작업 자동 관리**: 큰 작업은 계획서 → 체크리스트 → 검증 → 보고까지 워크플로우가 잡혀있습니다
- **스크립트 한 줄 설치**: 어떤 프로젝트든 `install.sh` 한 줄로 적용 가능

## 포함된 스킬 (16개)

### 자동 활성화

| 스킬 | 용도 |
|------|------|
| `backend` | API, DB, 인증, 서버 로직 |
| `frontend` | UI, 컴포넌트, 스타일링, 반응형 |
| `mobile` | iOS, Android, Flutter, React Native |
| `debug` | 버그 진단, 에러 추적, 핫픽스 |
| `qa` | 보안/성능/접근성 전체 감사 |
| `review` | diff 중심 빠른 코드 리뷰 |
| `pm` | 기획, 태스크 분해, 스프린트 계획 |
| `commit` | Conventional Commits 규격 커밋 |
| `research` | 기술 조사, 선행 리서치, 비교 분석 |
| `document` | 문서화, API 문서, 아키텍처 문서 |
| `context-builder` | 프로젝트 컨텍스트 문서 자동 생성 |
| `skill-creator` | 새 스킬 작성 가이드, SKILL.md 표준 형식 |
| `mcp-builder` | MCP 서버/도구 개발, Model Context Protocol 연동 |
| `webapp-testing` | E2E/통합/컴포넌트 테스트 전략 및 작성 |

### 수동 호출

| 스킬 | 용도 |
|------|------|
| `verify-implementation` | 통합 검증 파이프라인 |
| `manage-skills` | 검증 스킬 자동 생성/관리 |

## 설치

### 방법 1: 스크립트로 설치 (권장)

```bash
git clone https://github.com/Siul49/skill-pack.git
bash skill-pack/scripts/install.sh /path/to/your-project --claude --with-config
```

### 방법 2: 수동 설치

```bash
git clone https://github.com/Siul49/skill-pack.git
cp -r skill-pack/.claude/skills/ your-project/.claude/skills/
cp -r skill-pack/.claude/agents/ your-project/.claude/agents/
cp -r skill-pack/.claude/hooks/ your-project/.claude/hooks/
cp skill-pack/.claude/settings.json your-project/.claude/settings.json
```

### 방법 3: 플러그인으로 설치 (실험적)

> Claude Code 플러그인 시스템이 아직 안정화되지 않아 설치가 불완전할 수 있습니다.

```
/plugin marketplace add Siul49/skill-pack
/plugin install skill-pack
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
bash scripts/install.sh /path/to/your-project --claude
```

스킬/에이전트/훅만 덮어쓰고 `CLAUDE.md`는 건드리지 않습니다.

## 구조

```
.claude/
├── skills/                     # 스킬 정의 (SKILL.md + resources/)
│   ├── backend/                # API, DB, 서버 로직
│   ├── frontend/               # UI, 컴포넌트, 스타일링
│   ├── mobile/                 # iOS, Android, Flutter
│   ├── debug/                  # 버그 진단, 에러 추적
│   ├── qa/                     # 보안/성능/접근성 감사
│   ├── review/                 # 코드 리뷰
│   ├── pm/                     # 기획, 태스크 분해
│   ├── commit/                 # Conventional Commits
│   ├── research/               # 기술 조사, 선행 리서치
│   ├── document/               # 문서화, API/아키텍처 문서
│   ├── context-builder/        # 프로젝트 컨텍스트 자동 생성
│   ├── skill-creator/          # 새 스킬 작성 가이드
│   ├── mcp-builder/            # MCP 서버/도구 개발
│   ├── webapp-testing/         # E2E/통합/컴포넌트 테스트
│   ├── verify-implementation/  # 통합 검증 파이프라인
│   ├── manage-skills/          # 검증 스킬 자동 관리
│   └── _shared/resources/      # 공유 리소스
├── agents/                     # 서브에이전트 (자동 위임)
│   ├── code-reviewer.md        # 코드 리뷰 (worktree 격리)
│   ├── task-planner.md         # 복합 작업 계획서
│   ├── test-runner.md          # 테스트 실행 (worktree 격리)
│   ├── doc-writer.md           # 문서 생성/갱신
│   └── security-auditor.md     # 보안 스캔 (worktree 격리)
├── hooks/                      # 이벤트 Hook 스크립트 (10개)
├── settings.json               # Hook 등록, 권한 설정
└── context/                    # 복합 작업 문서 (런타임)
.claude-plugin/
├── plugin.json                 # 플러그인 메타데이터
└── marketplace.json            # 마켓플레이스 배포 설정
```

## 서브에이전트

독립 컨텍스트에서 전문화된 작업을 위임합니다. 모든 에이전트는 `memory: [project]`로 세션 간 학습을 유지합니다.

| 에이전트 | 모델 | 용도 | Worktree | 프리로드 스킬 |
|---------|------|------|----------|--------------|
| `code-reviewer` | sonnet | 코드 리뷰 | YES | review |
| `task-planner` | inherit | 복합 작업 계획서 | NO | pm, research |
| `test-runner` | haiku | 테스트 실행/분석 | YES | webapp-testing |
| `doc-writer` | sonnet | 문서 생성/갱신 | NO | document, context-builder |
| `security-auditor` | sonnet | 보안 취약점 스캔 | YES | qa |

## Hooks (10개 이벤트)

3가지 핸들러 타입: `command` (쉘), `prompt` (LLM 판단), `agent` (에이전트 분석)

| Hook | 이벤트 | 타입 | 동작 |
|------|--------|------|------|
| 세션 컨텍스트 로더 | `SessionStart` | command | 브랜치, 태스크 상태 주입 |
| 위험 명령 차단 | `PreToolUse(Bash)` | command | 위험 명령 차단 |
| 자동 포매팅 | `PostToolUse(Edit\|Write)` | command | 프로젝트 포매터 실행 |
| 보안 변경 감지 | `PostToolUse(Edit\|Write)` | prompt | 보안 관련 코드 변경 시 알림 |
| 도구 실패 힌트 | `PostToolUseFailure` | command | 도구 실패 시 디버그 가이드 |
| 인스트럭션 검증 | `InstructionsLoaded` | command | CLAUDE.md 유효성 확인 |
| 서브에이전트 로깅 | `SubagentStart` | command | 서브에이전트 시작 기록 |
| 서브에이전트 후처리 | `SubagentStop` | command | 완료 후 다음 단계 안내 |
| 태스크 완료 보고 | `TaskCompleted` | command | 체크리스트 진행률 보고 |
| 컨텍스트 압축 보존 | `PreCompact` | command | 압축 전 작업 상태 보존 |
| 체크리스트 리마인더 | `Stop` | command | 미완료 항목 알림 |
| 코드 품질 점검 | `Stop` | agent | 변경 파일 품질 자동 분석 |

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
