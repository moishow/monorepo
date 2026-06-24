# 샘플 데이터 — 가입·KYC·verified 게이트 저니 리뷰

```json
{
  "authToken_afterOAuth_newUser": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.access.signature",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.refresh.signature",
    "needsOnboarding": true,
    "user": {
      "id": "u_8fK2pQ",
      "nickname": null,
      "email": "hong@kakao.com",
      "photo": "https://cdn.moisho.app/oauth/kakao/8fK2pQ.jpg",
      "bio": null,
      "interests": [],
      "verified": false,
      "provider": "kakao",
      "createdAt": "2026-06-24T05:12:30.000Z"
    }
  },

  "user_afterOnboarding_unverified": {
    "id": "u_8fK2pQ",
    "nickname": "홍길동",
    "email": "hong@kakao.com",
    "phone": null,
    "photo": "https://cdn.moisho.app/oauth/kakao/8fK2pQ.jpg",
    "bio": "주말 풋살 좋아합니다",
    "interests": ["#풋살", "#사진"],
    "verified": false,
    "provider": "kakao",
    "createdAt": "2026-06-24T05:12:30.000Z"
  },

  "user_afterKyc_verified": {
    "id": "u_8fK2pQ",
    "nickname": "홍길동",
    "email": "hong@kakao.com",
    "phone": "+821012345678",
    "photo": "https://cdn.moisho.app/oauth/kakao/8fK2pQ.jpg",
    "bio": "주말 풋살 좋아합니다",
    "interests": ["#풋살", "#사진"],
    "verified": true,
    "provider": "kakao",
    "createdAt": "2026-06-24T05:12:30.000Z"
  },

  "kycResponse": {
    "verified": true,
    "wallet": {
      "id": "w_8fK2pQ",
      "balance": 0,
      "currency": "KRW",
      "accountLabel": "홍길동의 포인트"
    }
  },

  "trustProfile_seed": {
    "score": 0,
    "grade": "seed",
    "temp": 36.5,
    "manner": { "praises": 0, "punctual": 0, "noshow": 0, "response": 0 },
    "receiptRate": 0,
    "hosted": 0,
    "joined": 0,
    "delays": 0
  },

  "legalAgreements_recorded": [
    { "code": "tos",            "version": "2026-05-01", "required": true,  "agreed": true, "agreedAt": "2026-06-24T05:13:10.000Z" },
    { "code": "privacy",        "version": "2026-05-01", "required": true,  "agreed": true, "agreedAt": "2026-06-24T05:13:10.000Z" },
    { "code": "efin_transaction","version": "2026-05-01","required": true,  "agreed": true, "agreedAt": "2026-06-24T05:13:10.000Z" },
    { "code": "marketing",      "version": "2026-05-01", "required": false, "agreed": false, "agreedAt": null }
  ],

  "notificationPrefs_default": { "funding": true, "show": true, "member": true },

  "paymentAccounts_beforeConnect": [],

  "paymentAccounts_afterKakaoConnect": [
    {
      "id": "pa_kakao_8fK2pQ",
      "provider": "kakao",
      "label": "카카오페이",
      "maskedAccount": "kakaopay-****12",
      "connectedAt": "2026-06-24T05:20:00.000Z"
    }
  ],

  "gateError_depositWhileUnverified": {
    "error": {
      "code": "KYC_REQUIRED",
      "message": "본인인증 후 이용할 수 있어요.",
      "details": { "resumeAction": "deposit", "meetingId": "m_77a1", "roundId": "r_3" }
    }
  }
}
```

> 참고(추정): `legalAgreements[]`의 `code`/`version`/`required` 필드 구조는 데이터정의서가 `agreedTerms: bool`만 명시하므로 본 리뷰의 제안 스키마다. `phone` 포맷은 E.164로 가정.

---
