# 배경 및 컨텍스트

## 배경 (Why)

Antigravity 생태계가 2025-2026년에 급격히 확장됨:
- 공식 `anthropics/skills` 저장소에 17개 스킬 공개
- Hooks가 5→18개 이벤트, 4가지 핸들러 타입으로 확장
- 서브에이전트에 memory, skills, background 등 새 필드 추가
- 플러그인 시스템 도입으로 `/plugin install` 배포 가능

skill-pack이 이 변화에 대응하지 않으면 생태계 표준과 괴리가 발생한다.

## 제약 조건

- 기존 13개 스킬, 5개 에이전트의 동작을 깨뜨리지 않아야 함
- 한국어 문서 기준 유지
- install.sh 하위 호환성 보장 (기존 `--antigravity`, `--codex` 모드)
- 플러그인 형식은 공식 스펙(`anthropics/antigravity-plugins-official`) 준수

## 결정사항

1. 새 스킬은 공식 `anthropics/skills`를 참고하되, skill-pack의 한국어 + resources/ 구조에 맞게 재작성
2. HTTP 핸들러는 외부 의존성이 있어 이번 범위에서 제외
3. Agent Teams는 실험 단계이므로 제외
4. 플러그인 패키징은 병렬로 진행 가능 (스킬/에이전트 변경과 독립)

## 리스크

| 리스크 | 완화 방안 |
|--------|-----------|
| 새 훅 이벤트가 구버전 Antigravity에서 무시됨 | 훅 스크립트에 버전 체크 없이 graceful fail 처리 |
| memory 필드가 일부 환경에서 미지원 | 선택적 필드로 처리, 없어도 에이전트 동작에 영향 없음 |
| 플러그인 스펙 변경 가능성 | 최소 메타데이터만 정의, 확장은 추후 |
