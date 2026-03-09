# Context-Builder 실행 프로토콜

## 1단계: 프로젝트 스캔

자동 감지 대상:

```
패키지 매니저:
- package.json → Node.js 프로젝트, 의존성
- pyproject.toml / requirements.txt → Python 프로젝트
- build.gradle / pom.xml → Java/Kotlin 프로젝트
- Cargo.toml → Rust 프로젝트
- go.mod → Go 프로젝트

프레임워크 감지:
- next.config.* → Next.js
- nuxt.config.* → Nuxt
- angular.json → Angular
- vite.config.* → Vite
- manage.py → Django
- main.py + FastAPI import → FastAPI

코드 스타일:
- .eslintrc* / eslint.config.* → ESLint 규칙
- .prettierrc* → Prettier 설정
- ruff.toml / pyproject.toml [tool.ruff] → Ruff 규칙
- tsconfig.json → TypeScript 설정

인프라:
- Dockerfile / docker-compose.yml → 컨테이너
- .github/workflows/ → GitHub Actions
- vercel.json / netlify.toml → 배포 플랫폼
```

## 2단계: 기존 컨텍스트 확인

1. CLAUDE.md 존재 여부 확인
2. `.claude/context/` 디렉토리 확인
3. 기존 문서가 있으면 diff 기반 업데이트 준비
4. README.md 내용 참고

## 3단계: 컨텍스트 문서 생성

우선순위:
1. CLAUDE.md — 없으면 생성, 있으면 보강 제안
2. `.claude/context/architecture.md` — 디렉토리 구조 + 역할
3. `.claude/context/tech-stack.md` — 감지된 기술 스택
4. `.claude/context/conventions.md` — 코드 스타일 규칙

### 생성 규칙
- 자동 감지된 정보만 기입
- 불확실한 부분은 `[확인 필요]` 표시
- CLAUDE.md의 기존 내용은 절대 삭제하지 않음
- 토큰 효율을 위해 간결하게 작성

## 4단계: 검증 및 보고

```
검증 체크리스트:
□ package.json 등 설정 파일과 기술 스택 일치
□ 디렉토리 구조가 실제와 일치
□ [확인 필요] 항목 목록 작성
□ CLAUDE.md 기존 내용 보존 확인
```
