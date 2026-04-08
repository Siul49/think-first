# Context: Antigravity 심화 개조 (Hooks/Sub-agents 제거 및 Workflow 전환)

**배경 (Background)**
- 1차 포팅으로 기본 디렉토리 구조 및 스킬 인식은 완료되었으나, Antigravity 특유의 로직(쉘 인터셉트 Hook, CLI 백그라운드 스폰 기반 서브에이전트)은 Antigravity에서 무용지물 상태임.
- 잔존하는 `antigravity`, `.agent` 문자열들이 가이드 문서와 내부 스크립트에 남아있어 구조적 혼란을 줌.

**결정사항 (Decisions)**
- 사용가치 없는 기존 훅 스크립트(.agent/hooks)는 폐기하고 Git Hook 및 프롬프트 기반 가드레일로 방향을 전환.
- 서브에이전트 구동 파일들(.agent/agents)은 삭제하거나, Antigravity의 글로벌 `/workflows/` 체계와 연동되게끔 가이드 텍스트를 개조.
- 전체 코드베이스 내 잔여 식별자를 `antigravity` 기반으로 클렌징.

**제약 및 리스크 (Constraints & Risks)**
- `install.sh` 등 쉘 스크립트 내부에서 사용되는 변수명/경로명 변경 시 띄어쓰기나 경로 유실 주의.
- 정규식 치환 시 불필요한 URL 등까지 파괴하지 않도록 정밀 타격 필요.
