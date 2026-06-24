# 모이쇼 플로우 정합 리뷰 — 종합 (Overview)

> 목업 기반 화면들의 **기능 간 정합성·흐름**을 리뷰하고, 고도화된 유저 플로우·샘플 데이터·API를 도출한 결과 묶음.
> 작성 기준: `openapi.yaml`(계약) · `docs/02~05`(데이터·권한·에스크로 정본) · 빌드된 Flutter 5탭 · 디코드된 프로토타입 전체 화면.
> **불변 제약**: CLAUDE.md §4(금액 정수·시간 UTC·원장 append-only·멱등·차수단위·verified 게이트)·§11(회원간 송금/수수료/포인트 정산외 금지).

## 이 폴더 구성 (3대 산출물)
| 파일 | 내용 |
|---|---|
| `00-overview.md` | 본 문서 — 요약·§4/§11 준수 매트릭스·교차정합·인덱스 |
| `01-auth-kyc.md` ~ `06-social-trust.md` | **[산출물1]** 저니별 ①현재플로우 ②갭·엣지케이스 ③개선 유저플로우(상태머신) ④샘플JSON ⑤API정합 |
| `sample-data/*.md` | **[산출물2]** 저니별 샘플 데이터(JSON) 모음 (각 저니 §4 발췌) |
| `99-api-gaps.md` | **[산출물3]** openapi 대비 **신규(NEW)·수정(MODIFY)** API 통합 명세 `[Method·URI·설명·Req·Res]` |

## 6개 유저 저니
| # | 저니 | 핵심 진단 |
|---|---|---|
| 01 | 가입·KYC·verified 게이트 | 온보딩이 **KYC를 통째로 건너뛰고** 홈으로 보냄. 약관이 단일 bool. |
| 02 | 동아리 탐색·가입·승인 | 신청서 `answers` 스키마 3중 불일치, **정원 가드·철회 상태 부재**. |
| 03 | 모임·차수 펀딩·기간제한 에스크로 | 프로토타입이 **에스크로가 아니라 "카카오 모임통장 자동수취"** + 출금동의 단계 누락. |
| 04 | 증빙·반납·자동정산·환급 | **동의 거절 시 자금 영구 동결(데드락)** + 균등정산 나머지 처리 미정(잔액≠0). |
| 05 | 포인트 지갑·충전·현금화 | **충전 approve(딥링크 복귀) 단계가 계약에 없어 충전이 완결 안 됨** + 출금계좌 검증 누락. |
| 06 | 소셜·신뢰점수 | **신뢰점수·매너온도 클라이언트 하드코딩(§11 위반)** + 쇼 작성/DM시작/차단 엔드포인트 부재. |

## 가장 시급한 CRITICAL (머니규칙·정합성 정면 충돌)
1. **[03] 에스크로 우회** — 프로토타입 카피가 "총무 통장 자동 수취"로 자금을 흘림 = 회원↔직접송금 성격. → **앱 포인트 기간제한 에스크로**(예치→락→동의→출금)로 교정.
2. **[06] 신뢰점수 클라 산출** — `getGrade`/`_mannerHero` 등 등급 컷이 클라이언트에 박힘(§11 "산식 클라 노출 금지"). → `/me/trust`·`PublicProfile.trust` **서버값만 렌더**.
3. **[04] 정산 데드락 + 나머지 미정** — 동의 거절/기한초과 시 탈출 경로 없음, 균등정산 나머지(원단위) 미배분 시 DONE인데 에스크로 잔액≠0(잔액=분개합 불변식 위반). → `settlement/cancel-refund`·`overdue` 신설 + **나머지 앞 R명 +1P 배분**.
4. **[05] 충전 미완결** — 카카오 결제 후 `moisho://` 복귀 시 pg_token을 확정할 endpoint 부재. → `POST /me/wallet/charge/{partnerOrderId}/approve` + **webhook과 partner_order_id 기준 멱등 합류**.
5. **[01] verified 게이트 우회** — 미인증 유저가 홈에서 금융 진입점 노출. → KYC를 온보딩이 아니라 **금융 액션 직전 just-in-time**(403 KYC_REQUIRED→KYC→원래 액션 복귀).
6. **[06] §11 트랩** — "쇼 이벤트 → 커피 기프티콘" 보상을 **앱 포인트로 주면 위반**. → 외부 기프티콘 등 **오프-원장** 처리(LedgerEntry 분개 금지).

## §4/§11 머니규칙 준수 매트릭스
개선안이 6개 저니 전반에서 불변 규칙을 지키는지 종합(각 저니 §5 "자체검증" + 본 종합 검증):

| 규칙 (CLAUDE.md) | 프로토타입 현재 | 개선안 |
|---|---|---|
| 금액=정수(원), 시간=UTC ISO8601 | ⚠ 화면 하드코딩 일부 KST | ✅ 전 샘플 정수·UTC |
| 원장 append-only(정정=반대분개) | — (원장 미구현) | ✅ 취소=REFUND_CANCEL·반납=RETURN·실패=반대분개(+). 수정·삭제 0 |
| 잔액 = 분개 합 | ❌ [04] 나머지 누락 시 위반 | ✅ 나머지 +1P 배분으로 에스크로 잔액 0 보장 |
| 멱등(충전·현금화·예치·출금·반납) | ❌ [05] approve↔webhook 미정의 | ✅ 머니 op 전부 `Idempotency-Key` + partner_order_id 합류 |
| 차수(Round) 최소 거래 단위 | ⚠ [04] 모임 단일 균등정산과 혼선 | ✅ 차수별 분개 명시 권고 |
| 기간제한 에스크로(취소→락→출금→증빙→정산) | ❌ [03] 자동수취·동의 누락 | ✅ OPEN→LOCKED→WITHDRAWN→SETTLING 상태머신 일치 |
| verified 게이트(미인증 403 KYC_REQUIRED) | ❌ [01] 온보딩 우회 | ✅ 머니 엔드포인트 서버단 강제 + JIT KYC |
| 회원간 송금 API 금지 | ❌ [03] 직접송금 성격 카피 | ✅ 신규 API 전수 점검 — 송금 경로 0 |
| 포인트 정산 외 용도 금지 | ❌ [06] 포인트 보상 트랩 | ✅ 콘텐츠 보상 오프-원장 |
| 충전·출금 수수료 0원 | ✅ | ✅ fee 필드 미도입 |
| 민감작업 AuditLog | — | ✅ payout·return·decision·overdue before/after 권고 |

## 교차 저니 정합 (cross-journey)
- **verified 게이트 체인**: [01]이 정의한 JIT KYC를 [03]예치·[05]충전/현금화·[06]쇼츠업로드가 동일하게 참조(403 KYC_REQUIRED→복귀).
- **지갑 단일성**: [01] KYC 시 지갑 1회 개설 ↔ [05] `available/locked` 스키마 ↔ [03] 예치 시 locked 증가 ↔ [04] 정산 시 환급 — 하나의 Wallet/LedgerEntry 모델로 일관.
- **에스크로 상태 연속성**: [03] OPEN→LOCKED→WITHDRAWN → [04] SETTLING→DONE/REFUNDING. payout-consent는 [03](요청·투표)·[04](현황·교착해소)가 공유.
- **신뢰점수 단일 출처**: [06]이 서버 산출로 못박고, [02]승인화면(신청자 temp)·[04]정산준수율·노쇼 패널티가 동일 `TrustProfile`를 갱신.
- **페이지네이션 통일**: 목록(`/feed`·`/showts`·`/dm/threads`·`/me/applications`·followers 등)은 전부 커서 `?cursor=&limit=` → `{items,nextCursor}`.

## 읽는 순서 (권장)
1. 본 문서로 전체 그림 + CRITICAL 파악
2. 관심 저니 `0X-*.md`의 ②갭 → ③개선플로우
3. 구현 시 `99-api-gaps.md`로 백엔드 변경분 확인 → `openapi.yaml` 패치
4. 화면 목업/프론트는 `sample-data/`의 JSON으로 렌더

## 검증 메모
- 모든 **[NEW]** 엔드포인트는 `openapi.yaml` grep으로 부재 확인됨(`/me/applications`·`/me/bank-accounts`·`settlement/cancel-refund`·`settlement/overdue`·`/users/{id}/block`·`POST /posts`·`/me/showts`·`POST /dm/threads`·`charge/{orderId}/approve`).
- 각 저니 §5에 §4/§11 자체검증 포함. 추정 구간은 "추정"으로 표기(미확인 프로토타입 화면 본문 등).
- 본 리뷰는 **기획/스펙 산출물**이며 프로덕션 코드는 변경하지 않음.
