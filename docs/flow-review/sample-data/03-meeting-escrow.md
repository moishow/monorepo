# 샘플 데이터 — 모임·차수 펀딩·기간제한 에스크로 저니 리뷰

```json
{
  "meeting": {
    "id": "mtg_01HZX8K3",
    "type": "club",
    "clubId": "club_sound01",
    "hostId": "usr_treasurer",
    "title": "정기 합주 & 뒷풀이",
    "category": "music",
    "datetime": "2026-06-22T09:00:00.000Z",
    "fundingDeadline": "2026-06-21T14:00:00.000Z",
    "place": "홍대 사운드스튜디오",
    "description": "월례 정기 합주 후 뒷풀이",
    "coverImg": "https://cdn.moisho.app/m/mtg_01HZX8K3.jpg",
    "costBreakdown": [
      { "label": "합주실 대관료", "amount": 20000, "fixed": true },
      { "label": "뒷풀이 식비", "amount": 20000, "fixed": false }
    ],
    "perHead": 40000,
    "currentPeople": 8,
    "rounds": [
      { "id": "rnd_1", "label": "1차", "title": "정기 합주", "time": "18:00~20:00",
        "place": "사운드스튜디오 A", "cost": 25000, "min": 5, "max": 10, "cur": 8, "status": "recruiting" },
      { "id": "rnd_2", "label": "2차", "title": "뒷풀이", "time": "20:15~22:00",
        "place": "호프집", "cost": 15000, "min": null, "max": 10, "cur": 6, "status": "closing" }
    ],
    "rules": ["정시 참석", "악기 개인 지참", "회비 미예치 시 참석 불가"],
    "status": "recruiting"
  },
  "escrow": {
    "meetingId": "mtg_01HZX8K3",
    "state": "OPEN",
    "balance": 320000,
    "participants": 8,
    "lockAt": "2026-06-22T09:00:00.000Z",
    "settlementDeadline": null
  },
  "myWallet": {
    "id": "wal_usr_minji",
    "balance": 12000,
    "currency": "KRW",
    "accountLabel": "민지 지갑"
  },
  "myDeposit": {
    "id": "dep_01HZXA2",
    "roundId": "rnd_1",
    "userId": "usr_minji",
    "amount": 25000,
    "status": "deposited",
    "depositedAt": "2026-06-20T05:12:00.000Z"
  },
  "payoutConsent": {
    "meetingId": "mtg_01HZX8K3",
    "lockAt": "2026-06-22T09:00:00.000Z",
    "required": 8,
    "agreed": 6,
    "allAgreed": false,
    "items": [
      { "userId": "usr_minji", "name": "김민지", "vote": "agree",
        "reason": null, "votedAt": "2026-06-22T09:05:00.000Z" },
      { "userId": "usr_park", "name": "박소심", "vote": "pending",
        "reason": null, "votedAt": null },
      { "userId": "usr_choi", "name": "최부원", "vote": "reject",
        "reason": "금액 확인 필요", "votedAt": "2026-06-22T09:08:00.000Z" }
    ]
  },
  "ledgerSample": [
    { "id": "led_1", "ownerType": "user", "type": "charge", "roundId": null,
      "amount": 13000, "title": "카카오페이 충전(부족분)", "date": "2026-06-20T05:11:50.000Z" },
    { "id": "led_2", "ownerType": "user", "type": "deposit", "roundId": "rnd_1",
      "amount": -25000, "title": "1차 합주 예치", "date": "2026-06-20T05:12:00.000Z" },
    { "id": "led_3", "ownerType": "escrow", "type": "deposit", "roundId": "rnd_1",
      "amount": 25000, "title": "에스크로 적립(김민지)", "date": "2026-06-20T05:12:00.000Z" }
  ]
}
```

금액은 전부 정수(원=포인트), 시간은 UTC ISO8601, `roundId`/`userId`/`meetingId` 일관. `escrow.balance(320000) = Σ DEPOSIT − Σ PAYOUT + Σ RETURN − Σ SETTLE_REFUND` 불변식 성립.

---
