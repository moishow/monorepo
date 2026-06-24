# 샘플 데이터 — 소셜·신뢰점수 저니 리뷰 — 쇼/쇼츠/DM/팔로우/신고 + 매너온도·정산준수율

```json
{
  "myTrust": {
    "_endpoint": "GET /me/trust  (self)",
    "score": 88,
    "grade": "good",
    "temp": 37.8,
    "manner": { "praises": 31, "punctual": 97, "noshow": 0, "response": 95 },
    "receiptRate": 95,
    "hosted": 3,
    "joined": 12,
    "delays": 0
  },

  "publicProfile": {
    "_endpoint": "GET /users/u_parkjh  (auth)",
    "id": "u_parkjh",
    "nickname": "박지훈",
    "photo": "https://cdn.moisho.app/u/u_parkjh.jpg",
    "bio": "와인과 요리, 주말엔 홈파티. 정산은 칼같이.",
    "interests": ["와인", "요리", "맛집투어", "홈파티"],
    "verified": true,
    "followers": 142,
    "following": 38,
    "trust": {
      "score": 91,
      "grade": "best",
      "temp": 38.4,
      "manner": { "praises": 31, "punctual": 97, "noshow": 0, "response": 95 },
      "receiptRate": 96,
      "hosted": 5,
      "joined": 21,
      "delays": 0
    }
  },

  "followers": {
    "_endpoint": "GET /users/u_parkjh/followers?cursor=&limit=20  (auth)",
    "items": [
      { "id": "u_hong", "nickname": "홍길동", "photo": "https://cdn.moisho.app/u/u_hong.jpg",
        "verified": true, "trust": { "grade": "good", "temp": 37.8 }, "isFollowing": false },
      { "id": "u_leemj", "nickname": "이민준", "photo": "https://cdn.moisho.app/u/u_leemj.jpg",
        "verified": true, "trust": { "grade": "trust", "temp": 37.1 }, "isFollowing": true }
    ],
    "nextCursor": "eyJpZCI6InVfbGVlbWoifQ"
  },

  "feed": {
    "_endpoint": "GET /feed?cursor=&limit=10  (auth)",
    "items": [
      { "id": "P-9001", "type": "post", "clubId": "club_sound",
        "clubName": "홍대 연합 밴드 '사운드'", "authorId": "u_jeongd", "authorName": "정디자",
        "tag": "봄MT", "text": "펜션 도착! 바베큐 준비 완료 🔥",
        "img": "https://cdn.moisho.app/p/P-9001.jpg",
        "likes": 24, "comments": 6, "liked": false,
        "time": "2026-06-24T05:30:00Z" },
      { "id": "P-9002", "type": "post", "clubId": "club_frame",
        "clubName": "서울 사진 동아리 '프레임'", "authorId": "u_leemj", "authorName": "이민준",
        "tag": "출사", "text": "한강 야경 출사. 오늘 빛이 예뻤어요 🌇",
        "img": "https://cdn.moisho.app/p/P-9002.jpg",
        "likes": 15, "comments": 4, "liked": true,
        "time": "2026-06-24T04:10:00Z" }
    ],
    "nextCursor": "eyJpZCI6IlAtOTAwMiJ9"
  },

  "showts": {
    "_endpoint": "GET /showts?cursor=&limit=5  (auth, 승인분만)",
    "items": [
      { "id": "ST-501", "authorId": "u_jeongs", "handle": "@sound_band",
        "clubId": "club_sound",
        "caption": "정기 대관 연습 찢었다.. 뒷풀이까지 완벽 #밴드 #홍대",
        "videoUrl": "https://cdn.moisho.app/v/ST-501.mp4", "duration": "0:25",
        "likes": 3200, "comments": 142, "liked": false,
        "ledgerTag": "set_2026_06_sound_r1", "status": "approved",
        "funding": { "active": true, "title": "06/15 정기 대관 연습", "dday": 2 } }
    ],
    "nextCursor": null
  },

  "myShowts": {
    "_endpoint": "GET /me/showts?status=pending  (self · 신규)",
    "items": [
      { "id": "ST-777", "caption": "이번 출사 하이라이트 #프레임",
        "videoUrl": "https://cdn.moisho.app/v/ST-777.mp4", "status": "pending",
        "rejectReason": null, "submittedAt": "2026-06-24T03:00:00Z" }
    ],
    "nextCursor": null
  },

  "dmThreads": {
    "_endpoint": "GET /dm/threads?cursor=&limit=20  (auth)",
    "items": [
      { "id": "dm_kimhj", "peerId": "u_kimhj", "peerName": "김회장",
        "peerRole": "president", "clubId": "club_sound",
        "online": true, "unread": 2,
        "lastMsg": "이번 주 합주실 예약했어요!", "lastTime": "2026-06-24T01:44:00Z" }
    ],
    "nextCursor": null
  },

  "dmMessages": {
    "_endpoint": "GET /dm/threads/dm_kimhj/messages?cursor=&limit=30  (auth)",
    "items": [
      { "id": "m_1", "senderId": "u_kimhj", "text": "이번 주 합주 참석 가능하세요?",
        "time": "2026-06-24T01:05:00Z" },
      { "id": "m_2", "senderId": "u_hong", "text": "네! 토요일 오후 2시 맞죠?",
        "time": "2026-06-24T01:07:00Z" }
    ],
    "nextCursor": null
  },

  "notifications": {
    "_endpoint": "GET /me/notifications?cursor=&limit=20  (self)",
    "items": [
      { "id": "N-1", "kind": "payout_consent", "title": "총무 출금 동의 요청",
        "body": "정기 합주 & 뒷풀이 — 총무가 480,000원 출금 동의를 요청했어요.",
        "action": "moisho://meetings/mt_sound_0615/payout-consent",
        "unread": true, "time": "2026-06-24T05:55:00Z" },
      { "id": "N-2", "kind": "settlement", "title": "정산 완료 — 잔액 적립",
        "body": "정기 대관 연습 정산 완료! +4,000P 적립.",
        "action": "moisho://meetings/mt_sound_0608/settlement",
        "unread": false, "time": "2026-06-21T09:00:00Z" },
      { "id": "N-3", "kind": "show", "title": "새 쇼 게시글",
        "body": "정디자님이 '봄MT 현장'을 올렸어요.",
        "action": "moisho://posts/P-9001", "unread": false,
        "time": "2026-06-24T03:30:00Z" }
    ],
    "nextCursor": null
  },

  "notificationPrefs": {
    "_endpoint": "GET /me/notification-prefs  (self)",
    "funding": true, "show": true, "member": true,
    "_locked": ["payout_consent", "settlement", "penalty"]
  }
}
```

---
