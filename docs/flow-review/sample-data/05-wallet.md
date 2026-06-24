# 샘플 데이터 — 포인트 지갑·충전·현금화 저니 리뷰

```json
{
  "wallet": {
    "id": "wlt_u1",
    "balance": 128400,
    "available": 83400,
    "locked": 45000,
    "currency": "KRW",
    "accountLabel": "홍길동님 포인트",
    "lockedBreakdown": [
      { "meetingId": "m_101", "roundLabel": "1·2차", "title": "정기 합주 & 뒷풀이", "amount": 40000, "lockAt": "2026-06-25T10:00:00Z" },
      { "meetingId": "m_102", "roundLabel": "1차", "title": "파이썬 스터디 번개", "amount": 5000, "lockAt": "2026-06-24T10:00:00Z" }
    ]
  },
  "paymentAccounts": [
    { "id": "pa_kakao_1", "provider": "kakao", "label": "카카오페이", "linkedAt": "2026-05-01T02:11:00Z", "primary": true }
  ],
  "bankAccounts": [
    { "id": "ba_1", "bankCode": "004", "bankName": "국민은행", "accountNoMasked": "110-234-****90", "holderName": "홍길동", "ownerVerified": true, "verifiedAt": "2026-05-01T02:20:00Z" }
  ],
  "ledgerPage": {
    "items": [
      { "id": "le_9001", "ownerType": "user", "type": "settle_refund", "roundId": "r_77", "amount": 4200,  "title": "정기 합주 정산 환급", "date": "2026-06-16T12:03:00Z" },
      { "id": "le_9000", "ownerType": "user", "type": "deposit",       "roundId": "r_71", "amount": -40000, "title": "정기 합주 차수 예치", "date": "2026-06-13T09:22:00Z" },
      { "id": "le_8999", "ownerType": "user", "type": "charge",        "roundId": null,   "amount": 50000,  "title": "포인트 충전",        "date": "2026-06-13T09:20:00Z" },
      { "id": "le_8998", "ownerType": "user", "type": "refund_cancel", "roundId": "r_60", "amount": 5000,   "title": "번개 예약금 취소 환불","date": "2026-06-10T03:40:00Z" },
      { "id": "le_8997", "ownerType": "user", "type": "cashout",       "roundId": null,   "amount": -30000, "title": "계좌 현금화",        "date": "2026-06-02T00:12:00Z" }
    ],
    "nextCursor": "eyJpZCI6Imxlitg5OTcifQ"
  },
  "chargeReady": {
    "tid": "T1234567890",
    "partnerOrderId": "chg_88",
    "redirectUrl": "https://online-pay.kakao.com/mockup/v1/.../info",
    "appScheme": "kakaotalk://kakaopay/pg?url=...",
    "returnScheme": "moisho://wallet/charge/return?orderId=chg_88",
    "amount": 50000,
    "status": "ready"
  },
  "cashout": {
    "id": "co_55",
    "amount": 30000,
    "bankAccountId": "ba_1",
    "status": "requested",
    "requestedAt": "2026-06-24T01:30:00Z"
  }
}
```

---
