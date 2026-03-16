# 스킬 생성 실행 프로토콜

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
