# API 정합 — openapi.yaml 대비 갭 (통합)

> 6개 저니 §5의 API 정합을 통합. **신규 발명 최소화** — 기존 `openapi.yaml`(~80 엔드포인트)에 매핑하고, 부족분만 **NEW**, 보강분만 **MODIFY**로 도출.
> 모든 NEW는 `grep openapi.yaml`으로 부재 확인됨. 머니 op는 `Idempotency-Key` 헤더 필수. 권한 태그(`public·auth·verified·self·club.*·op.*`)는 `docs/03`을 따른다.
> 에러 포맷 `{ "error": { "code", "message", "details" } }` (CLAUDE.md §6).

---

## A. 신규 엔드포인트 (NEW)

| # | Method | URI | 권한 | 설명 | Request (샘플) | Response (샘플) |
|---|---|---|---|---|---|---|
| A1 | POST | `/me/legal/agreements` | self | 약관 개정 후 재동의 등 별도 기록(현재 GET만 존재) | `{"agreements":[{"code":"tos","version":"2026-06-01","agreed":true}]}` | `204 No Content` |
| A2 | GET | `/me/applications` | self | 내 동아리 가입신청 목록(대기/승인/거절/철회) | — | `{"items":[{"id":"japp_201","clubId":"club_sound","status":"pending","appliedAt":"2026-06-22T11:30:00.000Z"}],"nextCursor":null}` |
| A3 | DELETE | `/me/applications/{aid}` | self | 신청 철회(pending→withdrawn) | — | `204` · 이미처리 `409 CONFLICT` |
| A4 | POST | `/me/wallet/charge/{partnerOrderId}/approve` | verified · **Idem** | `moisho://` 복귀 후 pg_token 확정. webhook과 `partner_order_id` 기준 멱등 합류(CHARGE 1회 분개) | `H: Idempotency-Key: 6f..` `{"pgToken":"a1b2c3"}` | `200 {"partnerOrderId":"chg_88","status":"charged","balance":178400,"ledgerEntryId":"le_9002"}` |
| A5 | POST | `/me/bank-accounts` | verified | 현금화용 본인명의 계좌 등록 + 예금주 검증(§11 본인계좌-only) | `{"bankCode":"004","accountNo":"110234567890","holderName":"홍길동"}` | `201 {"id":"ba_1","accountNoMasked":"110-234-****90","ownerVerified":true}` |
| A6 | GET | `/me/bank-accounts` | self | 현금화 계좌 선택 목록 | — | `[{"id":"ba_1","bankName":"국민은행","accountNoMasked":"110-234-****90","ownerVerified":true}]` |
| A7 | POST | `/meetings/{id}/settlement/cancel-refund` | club.treasurer · **Idem** | 동의 거절·기한초과 시 전원 예치금 환불→DONE(데드락 탈출). REFUND_CANCEL 분개 | `{"reason":"전원 동의 실패"}` | `200 {"state":"REFUNDING","refunded":480000}` |
| A8 | POST | `/meetings/{id}/settlement/overdue` | system | 정산 타이머 초과 → PENALTY 분개(점수)·TrustProfile 차감 | `{}` | `200 {"payoutStatus":"penalized","trustDelta":-12}` |
| A9 | POST · DELETE | `/users/{id}/block` | auth | 차단/해제. 차단 시 팔로우·DM 자동 해제(신고와 별개) | — | `204` |
| A10 | POST | `/posts` | auth · club.member | 쇼 게시글 작성(ShowWrite 대상). bare `/posts:` 부재 확인 | `{"clubId":"club_sound","tag":"봄MT","text":"...","img":"https://.."}` | `201 {"id":"P-9003","status":"published"}` |
| A11 | GET | `/me/showts?status=pending` | self | 내 쇼츠 검수 상태·반려 사유 가시화 | — | `{"items":[{"id":"ST-777","status":"rejected","rejectReason":"저작권 음원"}],"nextCursor":null}` |
| A12 | POST | `/dm/threads` | auth | DM 시작(동일 2인 스레드 멱등 합류 — 중복 생성 금지) | `{"peerId":"u_parkjh"}` | `201 {"id":"dm_parkjh","peerId":"u_parkjh"}` |

### 신규 에러코드
| 코드 | HTTP | 발생 |
|---|---|---|
| `CLUB_FULL` | 409 | 정원(capacity) 도달 후 가입 승인 시도 |
| `INSUFFICIENT_AVAILABLE` | 409 | 현금화 `amount > available`(예치중 금액 출금 시도) |
| `NOT_PARTICIPANT` | 403 | 락 스냅샷 비참여자의 출금동의 투표 |
> 기존 표준코드(`KYC_REQUIRED`·`ROUND_FULL`·`DEADLINE_PASSED`·`ALREADY_PAID`·`SETTLEMENT_INVALID`·`INSUFFICIENT_POINTS`·`LOCKED`·`CONSENT_PENDING`)는 `docs/04` 사용.

---

## B. 수정 엔드포인트 (MODIFY)

| # | Method | URI | 변경 내용 | Request/Response 변경 샘플 |
|---|---|---|---|---|
| B1 | POST | `/auth/signup/profile` | `agreedTerms: bool` → **`agreements[]`** 배열(코드·버전·필수/선택·타임스탬프 기록) | `{"nickname":"홍길동","interests":["#풋살"],"agreements":[{"code":"efin_transaction","version":"2026-05-01","agreed":true},{"code":"marketing","agreed":false}]}` |
| B2 | GET | `/discover/clubs` | `cursor·limit·status` 필터 + 응답 스키마 명시 | `?q=밴드&category=문화·예술&status=recruiting&cursor=&limit=20` → `{"items":[Club],"nextCursor":"eyJ.."}` |
| B3 | GET | `/clubs/{id}` | `Club`에 `capacity·openRecruit·viewerState`(내 멤버십/신청상태) 추가 | `{"capacity":30,"openRecruit":true,"viewerState":{"membership":null,"applicationStatus":null}}` |
| B4 | GET | `/clubs/{id}/application-form` | 권한 `club.staff`→**신청자(verified)도 읽기** 허용(동적 폼 렌더) | — |
| B5 | POST | `/clubs/{id}/applications/{aid}/decision` | **정원 가드** 추가: `memberCount≥capacity` 시 `409 CLUB_FULL` | `{"decision":"approve"}` → `409 {"error":{"code":"CLUB_FULL"}}` |
| B6 | GET | `/clubs/{id}/applications` | 응답에 `applicant{nickname,temp,verified}`·`answers[].label` 동봉(검토 화면용) | `{"items":[{"id":"japp_301","applicant":{"nickname":"홍길동","temp":37.2,"verified":true},"answers":[{"label":"담당 파트","value":"보컬"}]}]}` |
| B7 | POST | `/meetings/{id}/rounds/{rid}/deposit` | `Deposit`에 `chargedAmount`(이번 충전된 부족분) 선택 필드 추가(영수증 정확) | `201 {"id":"dep_01","amount":25000,"chargedAmount":13000,"status":"deposited"}` |
| B8 | DELETE | `/meetings/{id}/rounds/{rid}/deposit` | OPEN 취소 응답에 `refundedAmount`(고정비 제외 실환불액) 명시 | `200 {"status":"refunded","refundedAmount":22000}` |
| B9 | POST | `/meetings/{id}/settlement/auto` | system 유지 + **나머지 결정분배 규칙**(반납금÷인원, 나머지 앞 R명 +1P)·**차수별 분개** 명시 | `200 {"perHeadRefund":8500,"remainderTo":["u_a","u_b"],"refunds":[..]}` |
| B10 | GET | `/me/refunds` | 응답 스키마 정의(현재 빈 `200:OK`) | `{"items":[{"settlementId":"stl_77c2","amount":8500,"status":"settled"}],"nextCursor":null}` |
| B11 | GET | `/me/wallet` | `Wallet`에 **`available·locked·lockedBreakdown`** 추가(현재 `balance`만) | `{"balance":128400,"available":83400,"locked":45000,"lockedBreakdown":[{"meetingId":"mtg_01","amount":25000}]}` |
| B12 | POST | `/me/wallet/charge` | `ChargeReady`에 `partnerOrderId·returnScheme·status:"ready"` 추가 | `200 {"tid":"T123","partnerOrderId":"chg_88","redirectUrl":"..","returnScheme":"moisho://wallet/charge/return?orderId=chg_88","status":"ready"}` |
| B13 | POST | `/me/wallet/cashout` | 권한 `self`→**`verified`**, `amount ≤ available` 검증, `409 INSUFFICIENT_AVAILABLE` | `H: Idempotency-Key` `{"amount":30000,"bankAccountId":"ba_1"}` |
| B14 | GET | `/users/{id}/followers` · `/following` | `limit` 파라미터 + `{items,nextCursor}` 응답 명시, 항목에 `isFollowing` | `?cursor=&limit=20` → `{"items":[{"id":"u_hong","nickname":"홍길동","isFollowing":false}],"nextCursor":null}` |
| B15 | GET | `/feed` | `limit` 파라미터 추가(커서 페이지네이션) | `?cursor=&limit=20` → `{"items":[..],"nextCursor":".."}` |
| B16 | GET | `/showts` | `limit` + **승인분(status=approved)만** 노출 | `?cursor=&limit=10` → `{"items":[{"id":"ST-501","status":"approved"}],"nextCursor":null}` |
| B17 | POST | `/showts/{id}/like` | **DELETE(좋아요 취소) 추가** — Post와 비대칭 해소 | `DELETE /showts/ST-501/like` → `204` |
| B18 | POST | `/showts/{id}/comments` | **GET(댓글 조회) 추가** — 현재 작성만 가능 | `GET /showts/ST-501/comments` → `{"items":[..],"nextCursor":null}` |
| B19 | GET | `/dm/threads` | `cursor·limit` 파라미터 추가 | `?cursor=&limit=20` → `{"items":[{"id":"dm_kimhj","peerId":"u_kimhj","unread":2}],"nextCursor":null}` |
| B20 | GET·PATCH | `/me/notification-prefs` | `payout_consent·settlement·penalty`는 **강제수신(토글 불가)** + `Notification.kind` enum 확정 | `{"funding":false,"show":true,"member":true}` (금융/거버넌스 kind는 항상 on) |
| B21 | POST | `/showts` | 권한 **`verified`**(403 KYC_REQUIRED) 명시 + 검수 큐(status=pending) 진입 | `{"caption":"..","tag":"공연","videoUrl":"..","ledgerTag":"set_.."}` → `201 {"id":"ST-777","status":"pending"}` |

---

## C. openapi.yaml 패치 가이드 (요약)
1. **Auth**: `SignupProfileReq.agreedTerms` 제거 → `agreements: [Agreement]`; `POST /me/legal/agreements` 추가.
2. **Club**: `Club` 스키마 `capacity·openRecruit·viewerState`; `ApplicationStatus` enum에 `withdrawn` 추가; `/me/applications`(GET)·`/me/applications/{aid}`(DELETE) path 추가; `CLUB_FULL` 코드.
3. **Escrow/Settlement**: `Deposit.chargedAmount`·`refundedAmount`; `settlement/auto` 나머지 분배 스키마; `/meetings/{id}/settlement/cancel-refund`·`/overdue` path; `/me/refunds` 응답 스키마.
4. **Wallet**: `Wallet.available/locked/lockedBreakdown`; `ChargeReady.partnerOrderId/returnScheme/status`; `/me/wallet/charge/{partnerOrderId}/approve` path; `/me/bank-accounts`(GET/POST) path; `cashout` 권한 verified + `INSUFFICIENT_AVAILABLE`.
5. **Show/Social**: `POST /posts`; `/me/showts`; `/dm/threads`(POST); `/users/{id}/block`(POST/DELETE); `showts/{id}/like`(DELETE)·`comments`(GET); 목록 cursor/limit 표준화; `Notification.kind` enum.

> 모든 변경은 기존 태그(Auth·Club·Meeting·Escrow·Settlement·Wallet·Social·Show) 안에서 이뤄지며, 새 태그·도메인은 만들지 않는다. 구현 순서는 README 마일스톤(M1 계정 → M2 동아리 → M3 모임·펀딩 → M4 결제 → M5 정산·환불 → M6 소셜)을 따른다.
