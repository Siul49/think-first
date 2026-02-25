# 팀원 3 — 수집 파이프라인 안정화

> 예상 공수: **6~8h** · 크롤링 운영 안정성
> 우선순위: 🔴 P0

---

## Task 1: BE-32 · `RoomCollectionService` 병렬 + 실패 격리 (5~6h)

### 왜 배포 전 필수인가?
현재 합주실 수집이 **순차적(하나씩)** 처리되어 매우 느리고,
하나의 수집 실패가 전체 흐름에 영향을 줄 수 있습니다. 실패 건에 대한 상세 리포트도 없습니다.

### 현재 수집 파이프라인
```
[수집 흐름]
1. NaverMapCrawler: 네이버 지도에서 "합주실" 검색 → business_id 목록 수집
2. NaverRoomFetcher: 각 업체의 세부 정보(이름, 가격, 이미지 등) 가져오기
3. RoomParserService: LLM/정규식으로 설명문에서 인원수/가격 구조화
4. _save_to_db: Supabase에 저장
```

### 수정 대상 파일
| 파일 | 작업 |
|------|------|
| `app/services/room_collection_service.py` | 청크 단위 병렬 + `return_exceptions=True`로 실패 격리 |

### 구현 가이드
```python
async def collect_by_query(self, query: str) -> Dict:
    search_results = await self.map_crawler.search_rehearsal_rooms(query)
    
    semaphore = asyncio.Semaphore(3)  # 동시 3개까지만
    
    async def process_item(item):
        async with semaphore:
            try:
                await self.collect_by_id(item["id"])
                return {"id": item["id"], "status": "success"}
            except Exception as e:
                logger.error(f"Failed {item['id']}: {e}")
                return {"id": item["id"], "status": "failed", "error": str(e)}
    
    # 전부 동시에 시작하되, semaphore가 3개씩만 통과시킴
    results = await asyncio.gather(*[process_item(item) for item in search_results])
    
    success = [r for r in results if r["status"] == "success"]
    failed = [r for r in results if r["status"] == "failed"]
    return {"success": len(success), "failed": len(failed), "failures": failed}
```

### 완료 기준
- [ ] 개별 실패가 전체를 중단시키지 않음
- [ ] 실패 건 상세 리포트 반환
- [ ] 동시 처리로 수집 속도 향상

---

## Task 2: BE-23 연동 · `crawler_type` 통합 테스트 (2~3h)

### 목표
팀원 2의 **BE-23(crawler_type DB화)** 완료 후, 실제로 크롤러가 DB 기반 매핑으로 정상 라우팅되는지 검증하는 통합 테스트를 작성합니다.

### 수정 대상 파일
| 파일 | 작업 |
|------|------|
| `tests/` | `test_crawler_type_routing.py` 신규 생성 |

### 테스트 시나리오
```python
# 1. DB에 crawler_type="naver"인 room이 있을 때, NaverCrawler가 호출되는지 확인
# 2. DB에 crawler_type="groove"인 room이 있을 때, GrooveCrawler가 호출되는지 확인
# 3. crawler_type이 없는(NULL) room은 어떻게 처리되는지 확인
```

### 완료 기준
- [ ] crawler_type별 라우팅 정상 동작 검증
- [ ] NULL 케이스 처리 검증
- [ ] 테스트 통과

---

## ⚠️ 의존성 & 주의사항
- **Task 1(BE-32)은 독립적** → 즉시 착수 가능
- **Task 2는 팀원 2의 BE-23 완료 후** 진행 (의존성 있음)
- `room_collection_service.py`는 이 팀원만 수정 (충돌 없음)
