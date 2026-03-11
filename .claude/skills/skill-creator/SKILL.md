---
name: skill-creator
description: 새로운 Claude Code 스킬을 작성할 때 자동 활성화됩니다. SKILL.md 표준 형식과 리소스 구조를 가이드하여 일관된 스킬을 생성합니다. "스킬 만들어줘", "커맨드 추가", "새 스킬" 요청에 반응합니다.
---

# 스킬 생성기

## 활성화 조건

- "스킬 만들어줘", "새 스킬", "커맨드 추가" 요청
- `.claude/skills/` 하위에 새 디렉토리 생성이 필요한 경우
- 기존 스킬의 구조 개선/재작성 요청

## 다른 스킬과의 차이

- **skill-creator**: 스킬 자체를 만드는 메타 스킬. SKILL.md 표준을 강제.
- **manage-skills**: 기존 스킬의 검증 스킬 관리. skill-creator는 새 스킬 생성.

## 실행 절차

### Step 1: 스킬 요구사항 수집

사용자와 확인:
- 스킬 이름 (`kebab-case`)
- 용도와 활성화 조건
- 자동 활성화 vs 수동 호출 (`disable-model-invocation`)
- 필요한 리소스 (템플릿, 체크리스트, 프로토콜 등)

### Step 2: SKILL.md 작성

```yaml
---
name: {스킬-이름}
description: {한국어 30-100자. 언제 활성화 + 무엇을 하는지}
---
```

필수 섹션:
1. **H1 제목**: 스킬의 역할 (예: "# 리서처", "# QA 검수자")
2. **활성화 조건**: 불릿 리스트로 트리거 키워드/상황
3. **다른 스킬과의 차이**: 유사 스킬과 구분 (해당 시)
4. **실행 절차**: Step별로 구조화
5. **핵심 규칙**: 번호 목록으로 반드시 지켜야 할 사항
6. **보고 형식**: 출력 템플릿 (코드블록으로)
7. **참조 리소스**: `resources/` 파일 목록

### Step 3: 리소스 파일 작성

`resources/` 디렉토리에 필요한 파일 생성:

| 파일 | 용도 | 필수 |
|------|------|------|
| `execution-protocol.md` | 단계별 상세 프로토콜 | 권장 |
| `checklist.md` | 검증 체크리스트 | 권장 |
| `error-playbook.md` | 에러 대응 가이드 | 선택 |
| `examples.md` | 실제 사용 예시 | 선택 |
| `snippets.md` | 코드 템플릿 | 선택 |

### Step 4: 등록 및 검증

1. CLAUDE.md 스킬 테이블에 추가
2. 스킬이 올바르게 활성화되는지 확인
3. 리소스 파일 경로가 유효한지 확인

## 핵심 규칙

1. **kebab-case 네이밍**: 스킬 이름과 디렉토리명 통일
2. **한국어 description**: frontmatter의 description은 한국어 30-100자
3. **최소 리소스**: 최소한 `execution-protocol.md` 포함 권장
4. **기존 스킬과 중복 방지**: 유사 스킬이 있으면 차이점 명시
5. **수동 호출 스킬**: `disable-model-invocation: true` 설정, `argument-hint` 포함

## SKILL.md 고급 frontmatter

```yaml
---
name: my-skill
description: 설명
# 선택적 필드
disable-model-invocation: true    # 수동 호출만 (/my-skill)
argument-hint: "[대상 경로]"       # 사용자 입력 힌트
context: fork                      # 격리된 서브에이전트에서 실행
agent: Explore                     # 특정 에이전트 타입으로 실행
model: sonnet                      # 모델 지정 (sonnet/opus/haiku)
allowed-tools:                     # 허용 도구 제한
  - Read
  - Grep
  - Glob
---
```

## 보고 형식

```
## 스킬 생성 완료

### 생성된 파일
- `.claude/skills/{name}/SKILL.md`
- `.claude/skills/{name}/resources/execution-protocol.md`
- [추가 리소스 파일 목록]

### CLAUDE.md 업데이트
- 스킬 테이블에 `{name}` 추가됨

### 다음 단계
- [스킬 테스트 방법]
```

## 참조 리소스

`resources/` 참조:
- 실행 프로토콜: `execution-protocol.md`
- 스킬 템플릿: `skill-template.md`
