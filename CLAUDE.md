# CLAUDE.md — 모이쇼 프로젝트 규칙

> Claude Code는 매 세션 이 파일을 먼저 읽는다. 이 파일은 **모이쇼 풀스택 레포의 단일 규칙서**다.
> 설계 근거는 `docs/`(설계 문서 4종)와 `openapi.yaml`. 충돌 시 우선순위: **openapi.yaml > docs > 이 파일의 예시 코드**.

---

## 1. 제품 한 줄 요약

동아리·소모임의 회비/펀딩을 모으고 → 예산을 짜고 → 투명하게 정산하는 핀테크. 콘셉트 "신뢰감을 주는 활기찬 핀테크". 자금은 **앱 포인트 기반 기간 제한형 에스크로**로 흐르고(카카오페이는 충전·현금화 레일), 잔액은 **포인트 원장(LedgerEntry)** 분개로 표현된다.

## 2. 기술 스택 (확정)

- **백엔드**: Spring Boot 3.x · **Kotlin** · Gradle(Kotlin DSL) · Java 21
- **DB**: MySQL 8.x · Flyway 마이그레이션 · JPA/Hibernate(+ 복잡 쿼리는 QueryDSL 또는 native)
- **앱**: Flutter (Dart 3) · Riverpod(상태) · go_router(라우팅) · dio(네트워크) · freezed/json_serializable(모델)
- **API**: REST · JSON · 계약은 `openapi.yaml`(OpenAPI 3.1)
- **인증**: JWT (access 15m / refresh 30d)
- **결제**: 앱 포인트 기반 기간 제한형 에스크로. 카카오페이는 포인트 충전·현금화 레일로만 사용 — `PaymentProvider` 인터페이스 뒤로 추상화. 상세 `docs/05`.

## 3. 레포 구조

```
moisho/
├── CLAUDE.md  openapi.yaml  docs/
├── backend/   # Spring Boot (Kotlin)
│   └── src/main/kotlin/app/moisho/{auth,user,trust,club,meeting,
│       payment,settlement,ledger,social,notification,admin,common}
└── app/       # Flutter
    └── lib/{core,features/*}
```

도메인 패키지 = `docs/02_데이터정의서.html`의 7개 그룹. 새 코드는 항상 올바른 도메인 패키지에 둔다.

## 4. 절대 규칙 (Money & Integrity)

1. **금액은 정수(원)** — Kotlin `Long`, MySQL `BIGINT`, Dart `int`. 부동소수점 금지.
2. **시간은 UTC** — 저장/전송 ISO8601 UTC(`DATETIME(6)`), 표시만 KST 변환.
3. **원장은 append-only** — `LedgerEntry`는 수정·삭제 금지. 정정은 반대 분개로.
4. **잔액 = 분개 합** — 캐시된 잔액은 항상 LedgerEntry 합으로 재계산 가능해야 한다.
5. **충전·현금화·예치·출금·반납은 멱등** — `Idempotency-Key` 헤더 필수. 카카오페이 충전은 partner_order_id 기준 멱등 합류(approve+webhook 이중 확정 금지).
6. **차수(Round)가 최소 거래 단위** — 예치·취소·락·반납·정산·환급 모두 차수별로 분개. 모임/동아리는 집계.
   - 기간 제한형 에스크로: 만남시각 전 취소·환불 자유(총무 출금 잠김) → 만남시각 락(취소 차단·출금 활성) → 총무 출금(정산 타이머) → OCR 증빙·잔액 반납 → 자동 균등 정산·현금화. 상세 `docs/05`.
   - 회원 간 송금 API 금지·포인트는 모임 정산 목적 외 사용 불가·충전·출금 수수료 0원 (선불업 등록 유예 전제 — 이 4가지는 반드시 유지).
7. **금융 행위는 verified 게이트** — 미인증 호출은 `403 KYC_REQUIRED`.
8. **민감 작업은 AuditLog** — 지급 승인·정지·정책 변경·역할 위임 등은 before/after 기록.

## 5. 권한(RBAC) 적용 방식

- 토큰 클레임(플랫폼 역할 + 운영자 세부 역할) **＋** 리소스 멤버십(동아리 역할)으로 평가.
- Spring: 메서드 시큐리티(`@PreAuthorize`) + 동아리 역할은 커스텀 권한 평가기(`@clubAuth.has(#clubId,'treasurer')` 형태).
- 권한 매트릭스는 `docs/03_API_권한설계서.html` 가 정본. 엔드포인트별 권한 태그(`public·auth·verified·self·club.*·op.*`)를 그대로 따른다.

## 6. API 컨벤션

- Base URL `…/v1`. 에러 포맷 `{ "error": { "code", "message", "details" } }`.
- 표준 에러 코드는 `docs/04_API_상세명세서.html` 표 사용(`KYC_REQUIRED`·`ROUND_FULL`·`DEADLINE_PASSED`·`ALREADY_PAID`·`SETTLEMENT_INVALID` 등).
- 목록은 커서 페이지네이션 `?cursor=&limit=` → `{ items, nextCursor }`.
- **openapi.yaml이 계약**: 엔드포인트 추가/변경 시 먼저 `openapi.yaml`을 고치고 코드를 맞춘다. 가능하면 스펙에서 DTO/Flutter 클라이언트를 생성.

## 7. 백엔드(Spring/Kotlin) 컨벤션

- 레이어: `controller → service → repository`. 도메인 엔티티와 API DTO 분리(매퍼).
- 트랜잭션: 금전 변경은 `@Transactional` 경계 명확히. 결제 확정·정산 마감은 단일 트랜잭션 + 멱등.
- 검증: 요청 DTO에 Bean Validation. 비즈니스 규칙은 service에서 도메인 예외 → 표준 에러 매핑(`@RestControllerAdvice`).
- 마이그레이션: 스키마 변경은 반드시 Flyway 파일로(수기 DDL 금지).
- 테스트: 결제·정산·환불·원장 정합성은 통합 테스트 필수(Testcontainers + MySQL).

## 8. 앱(Flutter) 컨벤션

- 아키텍처: feature-first. 각 feature = `presentation / application(notifier) / data(repo, dto) / domain(model)`.
- 상태: Riverpod. 모델: freezed. 네트워크: dio + openapi 생성 클라이언트(또는 retrofit).
- 디자인 토큰 → `core/theme`의 `ThemeData`로 1:1 매핑(색·타이포·라운드·섀도). 값은 `docs` README 6절 / `design/tokens` 참고. 금액 텍스트는 tabular figures.
- 디자인 레퍼런스(`design/prototype-app/`)는 **그대로 복사 금지** — 외관·동작만 재현.
- 라우팅: go_router. 딥링크(알림·카카오페이 복귀 스킴 `moisho://`) 지원.

## 9. Definition of Done (기능 1개)

- [ ] `openapi.yaml`에 계약 반영
- [ ] 백엔드: 엔드포인트 + 권한 + 검증 + 도메인 로직 + 마이그레이션 + 테스트
- [ ] 금전 관련이면: 멱등·원장 분개·정합성 테스트
- [ ] 앱: 화면 + 상태 + API 연동 + 디자인 토큰 적용 + 에러/로딩 상태
- [ ] 디자인 레퍼런스와 시각 비교(하이파이 픽셀 근접)

## 10. 빌드 순서 (마일스톤)

M0 기반 → M1 계정 → M2 동아리 → M3 모임·펀딩 → M4 결제 → M5 정산·환불 → M6 소셜 → M7 어드민.
각 단계는 백엔드 먼저, 그다음 앱. 상세는 README 4절.

## 11. 하지 말 것

- 금액을 실수로 다루기 / 원장 레코드 수정·삭제 / 멱등 없는 결제·환불.
- **회원 간 송금 API 추가 / 포인트를 모임 정산 외 용도로 사용 / 충전·출금 수수료 부과** (선불업 등록 유예 위반).
- openapi.yaml 없이 엔드포인트 추가 / 권한 매트릭스 무시.
- 프로토타입 코드(React/JSX) 복붙 / 디자인 토큰 임의 변경(새 색·간격 발명 금지).
- 신뢰점수 산식을 클라이언트에 노출 / 하드코딩.
