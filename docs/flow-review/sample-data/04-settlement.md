# 샘플 데이터 — 증빙·반납·자동정산·환급 저니 — 시니어 리뷰

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
