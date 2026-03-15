# 스킬 생성 실행 프로토콜

## Step -1: Thinking Cycle (이해도 점검 + 질문 + 결정)
1. **이해도 사전 점검** — 코드 수정 시 `../code-reading/SKILL.md` 사전 점검 수행
   - 사용자가 수정 대상 코드를 이해하고 있는지 확인
   - 이해 부족 시 설명 요구 → 설명 후 진행
2. **질문** — `../_shared/resources/thinking-cycle.md` Phase 0 수행
   - 작업 복잡도에 맞는 소크라테스 질문 선정
   - 사용자 답변 대기 (답변 전 진행 금지)
3. **결정** — 트레이드오프 존재 시 Phase 1 수행
   - 선택지 제시 + 근거 요구
   - 근거 없는 선택은 재질문

## Phase 1: 요구사항 분석

1. 사용자 요청에서 스킬 용도 파악
2. 기존 스킬 목록과 중복 여부 확인 (`ls .claude/skills/`)
3. 자동 활성화 vs 수동 호출 결정
4. 필요한 리소스 파일 목록 작성

## Phase 2: 스킬 구조 생성

```bash
# 디렉토리 생성
mkdir -p .claude/skills/{name}/resources

# 필수 파일 작성
# 1. SKILL.md (frontmatter + 본문)
# 2. resources/execution-protocol.md
```

## Phase 3: SKILL.md 작성 체크리스트

- [ ] frontmatter: name (kebab-case)
- [ ] frontmatter: description (한국어 30-100자)
- [ ] H1 제목 (역할 명사)
- [ ] 활성화 조건 (불릿 리스트, 키워드 포함)
- [ ] 유사 스킬 차이점 (해당 시)
- [ ] 실행 절차 (Step 1, 2, 3...)
- [ ] 핵심 규칙 (번호 목록)
- [ ] 보고 형식 (코드블록 템플릿)
- [ ] 참조 리소스 (resources/ 파일 목록)

## Phase 4: 등록

1. CLAUDE.md의 스킬 테이블에 추가
2. 수동 호출이면 "검증 및 관리 스킬" 테이블에 추가
3. install.sh 변경 필요 여부 확인

## 안티패턴

- description에 영어만 사용 → 한국어 필수
- 리소스 없는 스킬 → 최소 execution-protocol.md 권장
- 기존 스킬과 겹치는 활성화 조건 → 차이점 섹션 필수
- CamelCase 또는 snake_case 이름 → kebab-case만 사용

## Pre-Final Step: 코드 리딩 (Thinking Cycle Phase 3)
1. `../code-reading/SKILL.md` 사후 점검 수행
2. 변경된 코드에 대해 레벨 C(기본) 질문 → 사용자 답변 평가
3. 코드 변경이 없는 작업은 생략

## Final Step: 회고 (Thinking Cycle Phase 4)
1. `../_shared/resources/thinking-cycle.md` Phase 4 수행
2. 회고 질문 제시 → 사용자 답변을 `.claude/reflections/YYYY-MM-DD.md`에 기록
3. 회고 없이 작업 종료 금지
