# 팀원 D — 크롤링 데이터 품질 검증 + 파싱 로직 고도화

> 예상 공수: **16~22h** · 데이터 검증 & 파싱 성공률 개선
>
> Supabase 대시보드 접근 필요

---

## Task 1: BE-DQ-1 · 서울 외 데이터 정리 (2~3h)

### 목표
DB에서 **서울 외 지역** 합주실 데이터를 식별하고 제거합니다.

### 서울 좌표 범위
```
위도(lat): 37.41 ~ 37.72
경도(lng): 126.76 ~ 127.18
```

### 작업 절차

**Step 1: 서울 외 branch 조회**
```sql
-- Supabase SQL Editor에서 실행
SELECT business_id, name, lat, lng
FROM branch
WHERE lat IS NOT NULL
  AND (lat < 37.41 OR lat > 37.72 OR lng < 126.76 OR lng > 127.18)
ORDER BY name;
```

**Step 2: 결과 확인 후 삭제**
```sql
-- ⚠️ 반드시 Step 1의 결과를 먼저 확인하고 실행!
-- 서울 외 branch에 연결된 room 먼저 삭제
DELETE FROM room
WHERE business_id IN (
    SELECT business_id FROM branch
    WHERE lat < 37.41 OR lat > 37.72 OR lng < 126.76 OR lng > 127.18
);

-- 그 다음 branch 삭제
DELETE FROM branch
WHERE lat < 37.41 OR lat > 37.72 OR lng < 126.76 OR lng > 127.18;
```

**Step 3: 좌표 없는 branch 확인**
```sql
SELECT business_id, name FROM branch WHERE lat IS NULL OR lng IS NULL;
```

### 완료 기준
- [ ] 서울 외 branch/room 데이터 제거
- [ ] 삭제 전 목록 스크린샷 보존
- [ ] 좌표 누락 branch 목록 정리

---

## Task 2: BE-DQ-2 · 파싱 실패 건 전수 조사 (4~5h)

### 목표
`MANUAL_REVIEW_FLAG(=100)`으로 표시된 레코드를 찾아 **실제 네이버 예약 페이지와 대조**합니다.

### 작업 절차

**Step 1: 파싱 실패 건 추출**
```sql
SELECT r.biz_item_id, r.business_id, r.name,
       r.max_capacity, r.recommend_capacity, r.price_per_hour,
       b.name as branch_name
FROM room r
JOIN branch b ON r.business_id = b.business_id
WHERE r.max_capacity = 100 OR r.recommend_capacity = 100
ORDER BY b.name, r.name;
```

**Step 2: 각 건별 실제 확인**
```
https://booking.naver.com/booking/13/bizes/{business_id}
```

**Step 3: 검증 결과를 스프레드시트에 기록**

| business_id | biz_item_id | room_name | DB값(max) | 실제값(max) | 보정 필요? |
|---|---|---|---|---|---|

### 완료 기준
- [ ] `max_capacity=100` 또는 `recommend_capacity=100`인 전 건 조사
- [ ] 대조 스프레드시트 작성
- [ ] 보정 필요 건수 파악

---

## Task 3: BE-DQ-3 · 수기 보정 (3~4h)

### 목표
BE-DQ-2에서 식별된 보정 필요 건을 **DB에서 직접 수정** (30건 이내 예상)

```sql
UPDATE room
SET max_capacity = {실제값},
    recommend_capacity = {실제값}
WHERE biz_item_id = '{biz_item_id}';
```

### 완료 기준
- [ ] 보정 필요 건 전부 수정 완료
- [ ] 수정 후 `max_capacity=100` 건이 0건

---

## Task 4: BE-DQ-4 · Ollama 파싱 성공률 80%+ 달성 (5~7h) 🆕

### 현재 파싱 파이프라인

```
Level 1: 키워드 매칭 — "대형" → 15명 (즉시 확정)
Level 2: 정규표현식 — "최대 10인" 패턴 매칭
Level 3: Ollama LLM (llama3.1:8b) ← 여기를 개선
Level 4: 정규식 결과 그대로 사용 (실패 시 max_capacity=100 저장)
```

**핵심 문제**: 배포 서버(Cloud Run)에 GPU가 없어 Ollama가 안 돌아가는 상태. Level 1+2(정규식)만 작동 중.

### 개선 전략 (목표: 파싱 성공률 80% 이상)

#### 전략 1: 배포 환경에서 Ollama 돌리기

| 방법 | 설명 | 난이도 |
|------|------|--------|
| **외부 Ollama 서버** | 개인 PC나 별도 서버에 Ollama를 띄우고, Cloud Run에서 `.env`의 `OLLAMA_URL`로 호출 | ⭐ |
| **CPU 경량 모델** | `llama3.2:3b` 등 경량 모델을 Cloud Run CPU에서 직접 돌리기 (메모리 제한 확인 필요) | ⭐⭐ |

```bash
# 외부 서버 방식 — 개인 PC에서 Ollama 실행 후
# Cloud Run의 .env에 아래 설정
OLLAMA_URL=http://{공인IP_또는_도메인}:11434/api/generate
OLLAMA_MODEL=llama3.1:8b
```

#### 전략 2: 프롬프트 튜닝

현재 프롬프트가 Few-shot 3개만 포함. 실패 패턴을 분석해서 프롬프트를 보강합니다:

```python
# 현재: Few-shot 3개
# 개선: DQ-2에서 발견한 실패 패턴을 프롬프트 예시에 추가
# 예: 자연어 표현, 띄어쓰기 변형, 이모지 포함 등

# 추가할 예시 후보
Example 4: "레드룸", "밴드 합주 열 명까지 사용 가능합니다"
→ max_capacity: 10

Example 5: "스튜디오B", "🎸 4인 기준 / 추가 인원 3,000원"  
→ base_capacity: 4, extra_charge: 3000
```

#### 전략 3: 정규식 패턴 보강

DQ-2 조사에서 발견한 **반복 실패 패턴**을 정규식에 추가:

```python
# 예: "열 명", "다섯 명" 같은 한글 숫자 → 아라비아 숫자 변환
KOREAN_NUMBERS = {"한": 1, "두": 2, "세": 3, "네": 4, "다섯": 5,
                  "여섯": 6, "일곱": 7, "여덟": 8, "아홉": 9, "열": 10}

# 예: "N인룸" (붙여쓰기) 패턴 추가
re.search(r'(\d+)인룸', text)
```

#### 전략 4: 검증 루프 (Validate & Retry)

LLM 파싱 결과가 검증 실패 시, **프롬프트에 피드백을 추가해서 한 번 더 시도**:

```python
# 1차 시도 실패 시 → 피드백 포함 재시도
retry_prompt = f"""이전 결과가 잘못되었습니다.
원본: "{name}", "{desc}"
잘못된 결과: {first_result}
다시 추출해주세요. max_capacity는 반드시 숫자여야 합니다."""
```

### 성공률 측정 방법

DQ-2에서 만든 스프레드시트(실제 값)를 **정답지**로 활용:

```
1. DQ-3 수기 보정 완료된 DB = 정답 데이터
2. 해당 룸들의 원본 텍스트(name, desc)로 파싱 재실행
3. 파싱 결과 vs 정답 비교 → 성공률 계산
4. 목표: 80% 이상
```

### 완료 기준
- [ ] 배포 환경에서 Ollama 접근 가능하도록 구성
- [ ] 프롬프트 개선 (실패 패턴 기반 Few-shot 추가)
- [ ] 정규식 패턴 보강 (DQ-2 피드백 반영)
- [ ] 파싱 성공률 80% 이상 달성
- [ ] 80% 미달 시 → OpenAI API 전환 검토 (Plan B)

---

## Task 5: BE-DQ-5 · 검증 리포트 작성 (2~3h)

### 포함 항목
```markdown
## 데이터 품질 검증 리포트

### 1. 서울 외 정리 결과
- 삭제된 branch/room 수

### 2. 파싱 검증 결과
- 파싱 실패(100) 건수 → 보정 건수

### 3. LLM 고도화 결과
- 변경 전: 정규식만 동작 (성공률 N%)
- 변경 후: GPT-4o-mini 도입 (성공률 N%)
- 비용 분석

### 4. 반복 실패 패턴 (팀원 C에게 피드백)
```

### 완료 기준
- [ ] 리포트 작성 완료
- [ ] 팀 내 공유

---

## ⚠️ 의존성 & 주의사항
- **BE-DQ-1 → DQ-2 → DQ-3 → DQ-4 → DQ-5** 순서
- DQ-1~3(데이터 정리)을 먼저 해야 DQ-4(LLM 고도화) 후 재파싱 시 깨끗한 데이터로 테스트 가능
- 서울 외 데이터 삭제 전 favorites 테이블 연관 확인:
  ```sql
  SELECT * FROM favorites
  WHERE biz_item_id IN (
      SELECT biz_item_id FROM room
      WHERE business_id IN (
          SELECT business_id FROM branch
          WHERE lat < 37.41 OR lat > 37.72 OR lng < 126.76 OR lng > 127.18
      )
  );
  ```
- OpenAI API Key는 `.env`와 GitHub Secrets 모두에 추가 필요
