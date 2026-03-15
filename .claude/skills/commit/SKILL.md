---
name: commit
description: 커밋 요청 시 활성화됩니다. Conventional Commits 규격으로 커밋을 생성하며, 반드시 사용자 확인 후 실행합니다.
---

# 커밋 담당자

## 활성화 조건

- "커밋해줘", "변경사항 저장", "commit" 요청

## 커밋 타입

| 타입 | 설명 | 브랜치 프리픽스 |
|------|------|----------------|
| feat | 새 기능 | feature/ |
| fix | 버그 수정 | fix/ |
| refactor | 코드 개선 | refactor/ |
| docs | 문서 변경 | docs/ |
| test | 테스트 추가/수정 | test/ |
| chore | 빌드, 설정 등 | chore/ |
| style | 코드 스타일 변경 | style/ |
| perf | 성능 개선 | perf/ |

## 커밋 메시지 형식

```
<type>(<scope>): <description>

[optional body]

Co-Authored-By: Siul49 <kksu149@gmail.com>
```

## 실행 절차

### Step 1: 변경 분석
```bash
git status
git diff --staged
git log --oneline -5
```

### Step 2: 커밋 분리 판단
변경 파일이 여러 기능/도메인에 걸쳐 있으면 기능별로 분리.

**분리 기준:** 다른 scope, 다른 type, 논리적으로 독립적인 변경.
**분리하지 않을 때:** 단일 기능, 5개 이하 파일, 사용자가 단일 커밋 요청.

### Step 3: 타입 및 설명 작성
- 72자 이내, 명령형, 소문자 시작, 마침표 없음

### Step 4: 사용자 확인
커밋 메시지 미리보기 → **반드시 확인 받기**

### Step 5: 커밋 실행
HEREDOC으로 멀티라인 메시지 전달.

## Thinking Cycle (필수)

모든 작업에 사고 사이클을 적용한다. 상세: `../_shared/resources/thinking-cycle.md`

1. **질문**: 실행 전 최소 1개 소크라테스 질문 → 답변 전 진행 금지
2. **결정**: 트레이드오프 존재 시 선택지 제시 → 근거 있는 선택 요구
3. **실행**: Phase 0, 1 완료 후에만 진입
4. **코드 리딩**: 변경 코드 이해도 점검 (레벨 C 기본)
5. **회고**: 작업 완료 후 사용자 회고 → `.claude/reflections/YYYY-MM-DD.md`에 기록

## 절대 규칙

- **절대** 사용자 확인 없이 커밋하지 않는다
- **절대** `git add -A` 또는 `git add .`를 사용하지 않는다
- **절대** 비밀 파일(.env, credentials 등)을 커밋하지 않는다
- **항상** 파일명을 명시하여 스테이징한다
