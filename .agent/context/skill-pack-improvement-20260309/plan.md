# 작업 계획서

Task ID: think-first-improvement-20260309

## 목표

think-first의 `.claude/` 마이그레이션을 완성하고, 구조적 문제를 해결하여 설치 대상 프로젝트에서 모든 스킬이 정상 동작하도록 한다.

## 성공 기준

1. 모든 스킬의 `resources/` 참조가 실제 파일과 일치
2. context 경로가 `.claude/context/`로 통일
3. qa/review 역할이 명확히 분리
4. `_shared/resources/`에 핵심 공유 리소스 존재
5. install.sh가 resources, context 디렉토리를 포함하여 설치

## 범위

### In scope

- resources/ 파일을 `.agent/` → `.claude/skills/*/resources/`로 마이그레이션
- CLAUDE.md, install.sh의 context 경로를 `.claude/context/`로 통일
- qa/review 스킬 역할 재정의
- `_shared/resources/` 보강
- install.sh 업데이트

### Out of scope

- `.agent/` 레거시 디렉토리 삭제 (참조용 유지)
- 새로운 스킬 추가
- 스킬 내용 자체의 대폭 개편

## 마일스톤

1. resources/ 마이그레이션 완료
2. context 경로 통일 완료
3. qa/review 분리 완료
4. _shared/ 보강 완료
5. install.sh 업데이트 완료
