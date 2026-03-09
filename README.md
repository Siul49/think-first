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
.claude/skills/              # 스킬 정의 (SKILL.md + resources/)
├── backend/                 # API, DB, 서버 로직
├── frontend/                # UI, 컴포넌트, 스타일링
├── mobile/                  # iOS, Android, Flutter
├── debug/                   # 버그 진단, 에러 추적
├── qa/                      # 보안/성능/접근성 감사
├── review/                  # 코드 리뷰
├── pm/                      # 기획, 태스크 분해
├── commit/                  # Conventional Commits
├── research/                # 기술 조사, 선행 리서치
├── document/                # 문서화, API/아키텍처 문서
├── context-builder/         # 프로젝트 컨텍스트 자동 생성
├── verify-implementation/   # 통합 검증 파이프라인
├── manage-skills/           # 검증 스킬 자동 생성/관리
└── _shared/resources/       # 공유 리소스
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
