# 증빙·반납·자동정산·환급 저니 — 시니어 리뷰

## 1. 현재 플로우

이 머니 저니는 **현재 Flutter 앱(`app/lib/features/*`)에 전혀 구현되어 있지 않다.** 앱은 5탭(auth·discover·home·my·showts·chat)뿐이고 escrow/settlement/receipt/return/refund 관련 화면·코드가 0건이다(grep 결과 무매칭). 전 저니가 **React 프로토타입에만** 존재한다.

프로토타입 화면 전이(총무 관점 메인 동선):

1. **TreasurerPayoutScreen** (`5b8ddc3c`) — LOCKED 배지 + "출금 가능한 모인 자금 480,000원". 출금 동의 현황 `agreed/total`(8명 중 7명), 미동의자에게 "동의 요청 보내기", 정산 데드라인 12:00:00 안내. 전원 동의 시에만 출금 버튼 활성 → 클릭 시 toast("출금 완료")  → `settleReturn`로 이동.
2. **PayoutConsentScreen** (부원 관점) — "총무가 출금을 요청했어요", 출금금액/내 예치금/안내. [거절] / [출금에 동의] 버튼. 응답 후 `notifications`로.
3. **SettleReturnScreen** — 영수증 촬영/업로드 → (탭하면) "OCR 인식 완료, 신뢰도 98%", 가게명·일시·인식금액 카드. 실지출은 OCR 값으로 **잠금(고정)**. 출금액(480,000) − 실지출(412,000) = **반납할 잔액 68,000P** 계산 카드. "반납하고 정산" → `settleAuto`.
4. **SettleAutoScreen** — "정산이 끝났어요! 반납금 68,000P를 8명에게 공평하게 나눴어요", 나의 환급 +8,500P, 부원별 환급 리스트(8명 균등). "환급 포인트 현금화하기" → `walletCashout`.
5. **SettlementDetailScreen** (`87338638`) — 정산 히스토리 상세(취합 400,000 / 실지출 360,000 / 잔액 1인당 +4,000, 지출 항목, 부원별 정산). 다른 모임 예시.
6. 부속: **WalletScreen / WalletCashoutScreen**(현금화), **NotificationsScreen**(출금 동의 요청·정산 완료 알림 → 화면 딥링크).

**전부 stub이다.** 상태는 React `useState`로 로컬 시뮬레이션(데모 버튼 "남은 N명 동의 처리", OCR 스캔도 `setScanned(true)` 하드코딩). 실제 API 호출·멱등·원장·타이머·패널티는 없다.

---

## 2. 갭·논리모순·누락 엣지케이스

**[CRITICAL] 출금 동의 거절 시 자금 영구 동결(데드락) — 탈출 경로 없음**
PayoutConsentScreen은 [거절]을 제공하고 payout-consent/vote도 `reject`를 받는다. 그런데 한 명이라도 reject면 `allAgreed`가 영원히 false → 총무 출금은 409 CONSENT_PENDING으로 막히고, 동시에 LOCKED라 부원 예치 취소도 409 LOCKED로 막힌다. **돈이 양방향으로 잠겨 어디로도 못 간다.** openapi 어디에도 거절·교착 해소 경로가 없다(grep: deadlock/timeout/dispute 무매칭). 예: 8명 중 1명이 총무 불신으로 거절하면, 나머지 7명 예치금까지 모두 무기한 동결. UX·자금 안전성 모두 치명적.

**[CRITICAL] 균등정산 나머지(원단위) 처리 미정 → DONE 시 에스크로 잔액 ≠ 0 (불변식 위반)**
프로토타입 두 예시가 **모두 나눠떨어지게 조작**되어 있다(68000÷8=8500, 40000÷10=4000). 실제로는 `floor(반납금 ÷ 인원)` 시 잔돈이 남는다. 예: 반납 68,001P ÷ 8 = floor 8,500 → 8,500×8=68,000, **1P가 에스크로에 갇힘**. docs/05 불변식 "DONE 시 에스크로 잔액=0, ESCROW 잔액 = ΣDEPOSIT − ΣPAYOUT − … "를 위반한다. 나머지를 총무에게 주면 사실상 수수료(§11 위반), 시스템이 흡수하면 잔액≠0. **결정적 분배 규칙(앞 R명에게 +1P, R=나머지)이 명세에 없다.**

**[HIGH] 차수(Round) 단위 원칙 vs 모임 단위 단일 균등정산 — 구조 모순**
CLAUDE.md §4·docs/04는 "예치·취소·락·반납·정산·환급 모두 **차수별** Deposit·LedgerEntry로 분개"라 못 박는데, `/settlement/auto`는 모임 단위로 `반납금 ÷ 참여인원` 한 번만 한다. 한 모임에 차수 A(합주실, 5명, 10,000원), 차수 B(뒷풀이, 8명, 30,000원)가 섞이면 — A에만 참여한 사람과 B에만 참여한 사람의 환급액이 달라야 하는데 모임 전체 균등으로 뭉개진다. 차수별 참여 스냅샷이 다른데 단일 `참여인원`으로 나누면 **부당 환급**이 발생한다.

**[HIGH] 정산 데드라인 만료 → 패널티 트리거가 명세에 없음(스케줄러 공백)**
docs/05는 `WITHDRAWN(타이머) → overdue → penalized`, PENALTY 원장(금액이동 없음, 점수만), TrustProfile 차감을 정의하지만 **이를 발생시키는 엔드포인트가 openapi에 없다**(grep: penalty/overdue 무매칭, lock처럼 system 스케줄러 호출이어야 함). Payout.status에 `overdue/penalized` enum만 존재. 화면에도 "타이머 초과 시 차감" 문구만 있고 overdue 상태 UI·부원 측 "총무 미정산" 가시화가 없다. 미정산 모임이 영원히 SETTLING에 머문다.

**[HIGH] OCR 실패·불일치·다중 영수증 경로 전무**
422 OCR_MISMATCH가 명세에 있고 `receiptIds`는 **배열**(docs/04 "다중 영수증 합산")인데, SettleReturnScreen은 영수증 1장·신뢰도 98%·`setScanned(true)` 해피패스만 있다. 누락: ① 저신뢰도/인식 실패 재촬영, ② 여러 영수증 합산 UI(대관+뒷풀이 2건), ③ 실지출 > 출금액(422 SETTLEMENT_INVALID) 처리, ④ OCR 합계 ≠ 입력 시 반려 흐름. 강제매핑이 "위조 차단"의 핵심 장치인데 실패 분기가 없으면 총무가 정산을 진행할 수 없다.

**[MEDIUM] RETURN 분개의 출처 불명확 — 총무는 현금을 받았는데 무엇을 반납하나 (추정)**
PAYOUT_TREASURER(−)는 에스크로→총무 **은행계좌(현금)**로 자금을 뺐다. 그런데 RETURN(+)은 "잔액 **포인트** 반납"이다. 총무가 이미 현금화한 뒤 남은 68,000원을 **다시 포인트로 충전해서 반납**하는 것인지, 아니면 출금이 회계적 분개일 뿐 실제 미사용분은 에스크로에 남아있는 것인지 명세가 모호하다(추정: 후자라면 "총무 본인 계좌 출금"이라는 문구와 충돌). 반납 시 총무 지갑/계좌에서 68,000P가 실제로 차감되는지 UI에 없어 **총무가 사비로 반납**하는 함정 가능.

**[MEDIUM] 노쇼·고정비(CostItem.fixed)와 균등정산 충돌**
SettlementDetailScreen 부원 명단에 "한노쇼"가 포함되는데 자동정산은 무조건 `÷ 참여인원` 균등이다. CostItem.fixed("노쇼 환불 불가")가 정의돼 있으나 환급 계산에 반영 안 됨. 예: 고정비(대관료) 부담자와 노쇼한 사람을 똑같이 나누면, 노쇼자가 고정비 손실을 회피하고 정상 참여자가 손해. 차수 deposited/locked/settled_refund 상태 구분이 환급 모수에 들어가야 한다.

**[MEDIUM] 환급(포인트) vs 현금화(계좌) 경로 — 적립 옵션 누락**
docs/03은 "환불=즉시 계좌 환불(account) **또는** 포인트 적립(ledger, 다음 모임 자동 차감) 중 **선택**"이라 했는데, 프로토타입은 SETTLE_REFUND로 지갑 적립 후 무조건 "현금화하기" 한 길만 제시. 동아리 정기모임에서 다음 회비로 이월하려는 사용자의 선택지가 사라진다.

---

## 3. 개선된 유저 플로우

상태머신(openapi `Escrow.state` 정본과 일치):

```
stateDiagram-v2
    [*] --> OPEN: 차수 예치(DEPOSIT)
    OPEN --> OPEN: 예치 취소(REFUND_CANCEL)
    OPEN --> LOCKED: 만남시각 도달(system /lock, LOCK 분개)
    LOCKED --> CONSENT: 총무 동의요청(payout-consent/request)
    CONSENT --> CONSENT: vote(agree/reject) 멱등
    CONSENT --> WITHDRAWN: allAgreed=true + 총무 출금(PAYOUT_TREASURER)\n→ 정산타이머 시작(+12h)
    CONSENT --> REFUNDING: [NEW] reject 교착 or 동의기한 만료\n→ 전원 예치금 자동 환불(REFUND_CANCEL)
    REFUNDING --> DONE: 에스크로 0
    WITHDRAWN --> SETTLING: 영수증 OCR + 실지출 입력 + 잔액 반납(RETURN)
    WITHDRAWN --> OVERDUE: [NEW system] 타이머 초과\n→ PENALTY(점수만), TrustProfile 차감
    OVERDUE --> SETTLING: 지연 반납(RETURN, 패널티 확정)
    SETTLING --> DONE: 자동 균등정산(SETTLE_REFUND)\n나머지 결정분배 → 에스크로=0
    DONE --> [*]: 부원 환급 적립/현금화(CASHOUT)
```

**총무 동선 (추가/순서변경):**
1. (LOCKED) **출금 동의 현황** 화면 — 기존. 추가: reject한 부원 표시 + "거절 사유 보기"(채팅 딥링크), **"동의 기한 D-1"** 카운트다운.
2. **[추가] 동의 교착 해소 시트** — reject 있거나 동의기한 초과 시: "전원 동의가 안 됐어요. ① 재요청 ② 모임 취소(전원 환불)" 선택. ②는 REFUNDING으로 전원 예치금 자동 환불.
3. (WITHDRAWN) **출금 완료 + 정산 타이머** 화면 — 출금 직후 광고 대기(3~5초), "남은 11:59:00 내 영수증·잔액 반납" CTA.
4. **증빙·반납** 화면 개선 — 영수증 **다중 업로드**(receiptIds 배열), 각 OCR 카드 + **합계** 표시. 실지출 = OCR 합계(강제). 분기 추가: 저신뢰도 재촬영, 실지출>출금액 422 경고. 반납 시 **"내 지갑/계좌에서 차감 아님 — 미사용 에스크로 반납"** 명시(MEDIUM 갭 해소).
5. **[추가] 차수별 정산 미리보기** — 모임에 차수 ≥2면 차수별 반납금·참여 스냅샷·1인당을 분리 표시 후 합산(차수 단위 원칙 준수).

**부원 동선:**
1. **출금 동의 요청** 화면 — 기존. agree/reject(reason).
2. **[추가] 정산 진행 상태** 화면 — WITHDRAWN/SETTLING/OVERDUE를 부원도 본다. 총무 OVERDUE면 "총무 미정산" 배지 + 신뢰점수 영향 안내.
3. **자동 정산 완료** 화면 개선 — 나머지 1P 분배 받은 사람 "+8,501P" 표기. **[추가] 환급 처리 선택**: "① 계좌로 현금화 ② 포인트 적립(다음 회비)".
4. **정산 상세**(투명 장부) — 취합·출금·실지출·반납·1인당 + 영수증 썸네일 + 차수별. Showts `ledgerTag`로 자랑 가능.

---

## 4. 백엔드 의존 데이터 — 샘플 JSON

```json
{
  "escrow": {
    "meetingId": "mtg_8f21",
    "state": "WITHDRAWN",
    "balance": 68000,
    "participants": 8,
    "lockAt": "2026-06-22T12:00:00.000Z",
    "settlementDeadline": "2026-06-23T00:30:00.000Z"
  },
  "payout": {
    "id": "po_3a90",
    "meetingId": "mtg_8f21",
    "amount": 480000,
    "bankAccountId": "ba_treasurer_01",
    "status": "withdrawn",
    "withdrawnAt": "2026-06-22T12:30:00.000Z",
    "settlementDeadline": "2026-06-23T00:30:00.000Z"
  },
  "payoutConsent": {
    "meetingId": "mtg_8f21",
    "lockAt": "2026-06-22T12:00:00.000Z",
    "required": 8,
    "agreed": 8,
    "allAgreed": true,
    "items": [
      { "userId": "usr_001", "name": "김회장", "vote": "agree", "reason": null, "votedAt": "2026-06-22T12:04:00.000Z" },
      { "userId": "usr_006", "name": "장열심", "vote": "agree", "reason": null, "votedAt": "2026-06-22T12:41:00.000Z" }
    ]
  },
  "ocrResults": [
    { "receiptId": "rcpt_a1", "amount": 320000, "store": "하남돼지집 영통점", "paidAt": "2026-06-22T12:34:00.000Z", "confidence": 0.98, "imageUrl": "https://cdn.moisho.app/r/rcpt_a1.jpg" },
    { "receiptId": "rcpt_a2", "amount": 92000, "store": "GS25 영통점", "paidAt": "2026-06-22T13:02:00.000Z", "confidence": 0.94, "imageUrl": "https://cdn.moisho.app/r/rcpt_a2.jpg" }
  ],
  "settlement": {
    "id": "stl_77c2",
    "status": "done",
    "collected": 480000,
    "withdrawn": 480000,
    "spent": 412000,
    "returned": 68000,
    "perHeadRefund": 8500,
    "refunds": [
      { "userId": "usr_001", "amount": 8500, "status": "settled" },
      { "userId": "usr_002", "amount": 8500, "status": "settled" },
      { "userId": "usr_003", "amount": 8500, "status": "settled" },
      { "userId": "usr_004", "amount": 8500, "status": "settled" },
      { "userId": "usr_005", "amount": 8500, "status": "settled" },
      { "userId": "usr_006", "amount": 8500, "status": "settled" },
      { "userId": "usr_007", "amount": 8500, "status": "settled" },
      { "userId": "usr_008", "amount": 8500, "status": "settled" }
    ]
  },
  "settlementWithRemainder_example": {
    "id": "stl_88d3",
    "status": "done",
    "collected": 480001, "withdrawn": 480001, "spent": 412000, "returned": 68001,
    "perHeadRefund": 8500,
    "remainderRule": "floor(68001/8)=8500, 나머지 1P를 앞 1명에게 +1 → ΣSETTLE_REFUND=68001, 에스크로=0",
    "refunds": [
      { "userId": "usr_001", "amount": 8501, "status": "settled" },
      { "userId": "usr_002", "amount": 8500, "status": "settled" }
    ]
  },
  "ledgerEntries": [
    { "id": "le_01", "ownerType": "escrow", "type": "payout_treasurer", "roundId": "rnd_01", "amount": -480000, "title": "총무 출금 — 정기 합주 & 뒷풀이", "date": "2026-06-22T12:30:00.000Z" },
    { "id": "le_02", "ownerType": "escrow", "type": "return", "roundId": "rnd_01", "amount": 68000, "title": "미사용 잔액 반납", "date": "2026-06-22T14:10:00.000Z" },
    { "id": "le_03", "ownerType": "user", "type": "settle_refund", "roundId": "rnd_01", "amount": 8500, "title": "정산 환급 — 정기 합주 & 뒷풀이", "date": "2026-06-22T14:10:05.000Z" }
  ],
  "myRefunds": {
    "items": [
      { "settlementId": "stl_77c2", "meetingTitle": "정기 합주 & 뒷풀이", "amount": 8500, "status": "settled", "settledAt": "2026-06-22T14:10:05.000Z" }
    ],
    "nextCursor": null
  }
}
```

검증: `escrow.balance(68000) = ΣDEPOSIT(480000) − ΣPAYOUT(480000) + ΣRETURN(68000) − ΣSETTLE_REFUND(0, 아직)`. DONE 후 ΣSETTLE_REFUND=68000 → 잔액=0. 금액 전부 정수, 시간 전부 UTC ISO8601, id/roundId 일관.

---

## 5. API 정합 (요청 형식)

| 플로우 스텝 | 상태 | Method | URI | 설명 | Request 샘플 | Response 샘플 |
|---|---|---|---|---|---|---|
| 출금 동의 현황 | **EXISTS** (openapi:301) | GET | `/meetings/{id}/payout-consent` | 동의 N/N·명단 (club.member) | — | `{"required":8,"agreed":8,"allAgreed":true,"items":[…]}` |
| 부원 동의/거절 | **EXISTS** (openapi:307) | POST | `/meetings/{id}/payout-consent/vote` | 락 스냅샷 참여자만(self·participant) | `{"vote":"agree"}` / `{"vote":"reject","reason":"영수증 먼저"}` | `{"agreed":7,"allAgreed":false,…}` |
| 총무 출금 | **EXISTS** (openapi:321) | POST | `/meetings/{id}/payout` | LOCKED+전원동의만, 타이머 시작 (club.treasurer). **Idempotency-Key 필수** | `{"bankAccountId":"ba_treasurer_01"}` | `{"id":"po_3a90","amount":480000,"status":"withdrawn","settlementDeadline":"2026-06-23T00:30:00.000Z"}` |
| 영수증 OCR | **EXISTS** (openapi:336) | POST | `/meetings/{id}/settlement/receipts` | 영수증→OCR 강제매핑 (club.treasurer) | `multipart: file=<binary>` | `{"receiptId":"rcpt_a2","amount":92000,"store":"GS25","confidence":0.94}` |
| 실지출+잔액 반납 | **EXISTS** (openapi:344) | POST | `/meetings/{id}/settlement/return` | 다중 receiptIds 합산 (club.treasurer). **Idempotency-Key 필수** | `{"actualSpent":412000,"receiptIds":["rcpt_a1","rcpt_a2"]}` | `{"id":"stl_77c2","status":"returned","returned":68000}` |
| 자동 균등정산 | **MODIFY** (openapi:356) — system 호출 유지하되 **나머지 결정분배 규칙·차수별 분개 명시** 필요 | POST | `/meetings/{id}/settlement/auto` | 반납금÷인원, 나머지 앞 R명 +1P (system) | `{}` (스케줄러) | `{"id":"stl_77c2","status":"done","perHeadRefund":8500,"refunds":[…]}` |
| 정산 상세(투명장부) | **EXISTS** (openapi:364) | GET | `/settlements/{id}` | 취합·출금·실지출·반납·1인당 (club.member) | — | `{"collected":480000,"spent":412000,"returned":68000,"perHeadRefund":8500}` |
| 내 환급 내역 | **EXISTS** (openapi:366) — 단 응답스키마 미정의(빈 `200: OK`) | GET | `/me/refunds` | 내 정산 환급 (self) | — | `{"items":[{"settlementId":"stl_77c2","amount":8500,"status":"settled"}],"nextCursor":null}` |
| 환급→현금화 | **EXISTS** (openapi:cashout) | POST | `/me/wallet/cashout` | 포인트→본인계좌, 수수료0 (self). **Idempotency-Key 필수** | `{"amount":8500,"bankAccountId":"ba_me_01"}` | `{"id":"co_1","amount":8500,"status":"requested"}` |
| 환급 포인트 적립(이월) | **MODIFY** `/me/refunds` 또는 SETTLE_REFUND 기본동작 — 적립이 디폴트이므로 **별도 API 불필요**, 현금화는 위 cashout. 선택 UI만 클라이언트 | — | — | docs/03 "account or ledger 선택" UI 반영. 송금 아님(지갑 적립). | — | — |
| **동의 교착/기한만료 해소** | **NEW** (grep 무매칭) | POST | `/meetings/{id}/settlement/cancel-refund` | reject·기한초과 시 전원 예치금 환불→DONE (club.treasurer). **Idempotency-Key 필수** | `{"reason":"전원 동의 실패"}` | `{"state":"REFUNDING","refunded":480000}` (REFUND_CANCEL 분개) |
| **정산 타이머 만료 패널티** | **NEW** (grep 무매칭, system 스케줄러) | POST | `/meetings/{id}/settlement/overdue` | 타이머 초과→PENALTY 분개(점수만)·TrustProfile 차감 (system) | `{}` | `{"payoutStatus":"penalized","trustDelta":-12}` |

권한 태그·게이트: payout/receipts/return = **club.treasurer + verified**(KYC_REQUIRED 403), vote = **self·participant**(NOT_PARTICIPANT 403), auto/overdue = **system**, cashout = **self·verified**. 멱등 머니 op(payout·return·cashout·cancel-refund)는 모두 `Idempotency-Key` 헤더. 민감작업(payout·return·overdue·cancel-refund)은 **AuditLog before/after**.

### §4/§11 자체검증
- **회원 간 송금 금지**: ✅ 모든 환급은 SETTLE_REFUND(시스템→지갑 적립)·CASHOUT(지갑→본인계좌). 신규 cancel-refund도 REFUND_CANCEL(에스크로→본인 지갑). 회원↔회원 직접 송금 API 없음.
- **포인트 모임 정산 외 용도 금지**: ✅ 환급·반납·적립 모두 모임 에스크로 정산 범위. 나머지 1P도 동일 모임 SETTLE_REFUND.
- **충전·출금 수수료 0원**: ✅ 나머지(remainder)를 총무/시스템이 흡수하지 않고 부원에게 +1P 분배 → 사실상 수수료 0 유지. cashout 수수료 미수취.
- **원장 수정·삭제 금지(append-only)**: ✅ 교착 해소·패널티 모두 신규 분개(REFUND_CANCEL·PENALTY)로 처리, 기존 PAYOUT_TREASURER 정정도 반대분개. 기존 레코드 mutation 없음.
- **멱등 누락 없음**: ✅ payout·return·cashout·cancel-refund 전부 Idempotency-Key 명시. auto/overdue는 system 멱등(모임 단위 직렬화 락).
- **verified 게이트 누락 없음**: ✅ payout·receipts·return·cashout 모두 verified 필수(미인증 403 KYC_REQUIRED), 열람(escrow·settlements·refunds)은 club.member/self.

(추정 표기: RETURN 분개의 자금 출처 해석(§2 MEDIUM), 적립 디폴트 동작은 명세 모호분으로 "추정". 교착·패널티 엔드포인트는 openapi 미존재 확인 후 [NEW].)
