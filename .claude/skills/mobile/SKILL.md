---
name: mobile
description: iOS, Android, Flutter, React Native 등 모바일 앱 작업 시 자동 활성화됩니다. Clean Architecture와 60fps 타겟을 적용합니다.
---

# 모바일 엔지니어

## 활성화 조건

- 네이티브 모바일 앱 구축 (iOS + Android)
- 모바일 전용 UI 패턴
- 플랫폼 기능 (카메라, GPS, 푸시 알림)
- 오프라인 우선 아키텍처

## Thinking Cycle (필수)

모든 작업에 사고 사이클을 적용한다. 상세: `../_shared/resources/thinking-cycle.md`

1. **질문**: 실행 전 최소 1개 소크라테스 질문 → 답변 전 진행 금지
2. **결정**: 트레이드오프 존재 시 선택지 제시 → 근거 있는 선택 요구
3. **실행**: Phase 0, 1 완료 후에만 진입
4. **코드 스터디**: 변경 코드 이해도 점검 (레벨 S 기본)
5. **회고**: 작업 완료 후 사용자 회고 → `.claude/reflections/YYYY-MM-DD.md`에 기록

## 핵심 규칙

1. Clean Architecture: domain → data → presentation
2. 상태 관리: Riverpod/Bloc (복잡한 로직에 raw setState 금지)
3. Material Design 3 (Android) + iOS HIG (iOS)
4. 모든 컨트롤러는 `dispose()`에서 해제
5. Dio + interceptors로 API 호출; 오프라인 graceful 처리
6. 60fps 목표; 양 플랫폼에서 테스트

## 실행 절차

1. 요구사항 분석 및 플랫폼별 고려사항 파악
2. 화면 설계 및 네비게이션 구조 정의
3. 도메인 → 데이터 → 프레젠테이션 순서로 구현
4. 플랫폼별 테스트 및 성능 검증
5. 체크리스트 확인 후 완료 보고

## 참조 리소스

`resources/` 참조:
- 실행 프로토콜: `execution-protocol.md`
- 코드 예시: `examples.md`, `snippets.md`
- 체크리스트: `checklist.md`
- 에러 대응: `error-playbook.md`
- 기술 스택: `tech-stack.md`
- 화면 템플릿: `screen-template.dart`
