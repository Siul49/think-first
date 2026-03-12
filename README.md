# Skill-Pack

**AI가 대신 해주는 도구가 아니라, 사고를 강제하는 도구.**

## 이 프로젝트는 뭔가요?

Skill-Pack은 Claude Code 위에서 동작하는 에이전트 스킬 번들입니다.
하지만 단순한 자동화 도구가 아닙니다.

보통 AI 코딩 도구는 "대신 해주는 것"에 집중합니다. 빠르게 코드를 생성하고, 알아서 구조를 잡아주고, 질문하면 바로 답을 줍니다. 편리하지만, 그 과정에서 **개발자가 생각할 기회를 잃습니다.**

Skill-Pack은 반대 방향을 선택했습니다.

## 철학: 사고 강제 (Thinking Cycle)

모든 작업에 **질문 → 결정 → 실행 → 회고** 사이클을 적용합니다.

- "이거 해줘" → AI가 먼저 **질문**합니다. "왜 이 방식인가요? 다른 선택지는 고려했나요?"
- 트레이드오프가 있으면 선택지를 제시하고, **결정**을 사용자에게 맡깁니다
- 실행은 사용자가 생각하고 결정한 **이후에만** 시작됩니다
- 작업이 끝나면 **회고**를 통해 배운 것을 기록합니다

심지어 "이게 뭐야?"라고 물어도, 먼저 "본인이 이해한 대로 설명해보세요"라고 되묻습니다.
불편할 수 있지만, 그게 핵심입니다. **불편함이 학습입니다.**

## 왜 만들었나?

AI와 함께 코드를 짜면서도 **개발자로서 성장하고 싶었습니다.**

AI가 답을 줄 때마다 내가 직접 고민할 기회가 사라진다는 걸 느꼈습니다. 코드는 완성되지만 머릿속에 남는 게 없었습니다. 그래서 AI를 "실행자"가 아닌 "사고 파트너"로 만들기로 했습니다.

이 프로젝트 자체가 그 실험입니다. Skill-Pack을 만드는 과정에서도 Thinking Cycle을 적용하며, **학습하면서 프로젝트를 만들고, 프로젝트를 만들면서 학습합니다.**

## 구성 요소

| 구분 | 내용 |
|------|------|
| **16개 스킬** | backend, frontend, debug, qa, commit 등 — 작업 맥락에 따라 자동 활성화 |
| **5개 서브에이전트** | 코드 리뷰, 테스트, 보안 감사를 worktree 격리 환경에서 자동 위임 |
| **10개 이벤트 훅** | 위험 명령 차단, 자동 포매팅, 보안 변경 감지, 컨텍스트 보존 등 |
| **복합 작업 프로토콜** | 큰 작업은 계획서 → 체크리스트 → 검증 → 보고 워크플로우 자동 적용 |
| **회고 시스템** | 작업 완료 후 `.claude/reflections/`에 학습 기록 축적 |

## 설치

### 스크립트 설치 (권장)

```bash
git clone https://github.com/Siul49/skill-pack.git
bash skill-pack/scripts/install.sh /path/to/your-project --claude --with-config
```

### 수동 설치

```bash
git clone https://github.com/Siul49/skill-pack.git
cp -r skill-pack/.claude/skills/ your-project/.claude/skills/
cp -r skill-pack/.claude/agents/ your-project/.claude/agents/
cp -r skill-pack/.claude/hooks/ your-project/.claude/hooks/
cp skill-pack/.claude/settings.json your-project/.claude/settings.json
```

### 설치 후

1. `CLAUDE.md`를 프로젝트에 맞게 수정 (호칭, 문체, Co-Authored-By 등)
2. 불필요한 스킬 디렉토리 삭제 (예: 모바일 미사용 시 `mobile/` 삭제)
3. `manage-skills` 스킬로 프로젝트에 맞는 검증 스킬 생성

## 업데이트

```bash
cd skill-pack && git pull
bash scripts/install.sh /path/to/your-project --claude
```

스킬/에이전트/훅만 덮어쓰고 `CLAUDE.md`는 건드리지 않습니다.

## 프로젝트 구조

```
.claude/
├── skills/              # 스킬 정의 (SKILL.md + resources/)
├── skills/_shared/      # 공유 리소스 (Thinking Cycle, 추론 템플릿)
├── agents/              # 서브에이전트 (자동 위임, worktree 격리)
├── hooks/               # 이벤트 Hook 스크립트
├── reflections/         # 회고 기록 (날짜별)
├── settings.json        # Hook 등록, 권한 설정
└── context/             # 복합 작업 문서 (런타임)
```

## 기여

이슈와 PR을 환영합니다.

- Conventional Commits 형식으로 커밋
- 한국어 문서 기본 (식별자, 명령어는 영어 유지)
- 새 스킬 추가 시 `SKILL.md` + `resources/` 구조 준수

## 라이선스

[Apache License 2.0](LICENSE)
