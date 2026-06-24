# 샘플 데이터 — 동아리 탐색·가입·승인 저니 — 프로덕트+핀테크 리뷰

화면을 바로 렌더할 수 있는 현실적 목데이터. 데이터정의서 스키마 준수, 시간=UTC ISO8601, 금액=정수(원).

```json
{
  "club": {
    "id": "club_sound",
    "name": "홍대 연합 밴드 '사운드'",
    "category": "문화·예술",
    "coverImg": "https://cdn.moisho.app/clubs/club_sound/cover.webp",
    "intro": "합주실 보유 · 월 2회 정기공연. 통기타부터 드럼까지 환영해요 🎸",
    "memberCount": 28,
    "capacity": 30,
    "openRecruit": true,
    "tags": ["#밴드", "#친목", "#공연"],
    "ledgerBalance": 1240000,
    "createdYear": "2023",
    "trust": { "grade": "A", "refundCompleteRate": 0.98, "avgSettleDays": 2.4, "budgetErrorRate": 0.01 }
  },

  "applicationForm": {
    "clubId": "club_sound",
    "title": "홍대 연합 밴드 '사운드' 가입 신청서",
    "desc": "밴드 동아리 가입을 희망하시는 분들을 위한 신청서입니다. 성실하게 작성해 주세요 😊",
    "builtIns": { "days": true, "motivation": true, "experience": false },
    "questions": [
      { "id": "q_part",  "type": "choice", "label": "담당 파트 (해당 시 선택)", "required": true,  "choices": ["🎸 기타", "🎹 키보드", "🎺 보컬", "🥁 드럼", "🎻 베이스", "🎷 관악기"] },
      { "id": "q_model", "type": "short",  "label": "현재 사용하는 악기 브랜드/모델", "required": false, "choices": [] },
      { "id": "q_exp",   "type": "choice", "label": "합주 경험 있으신가요?", "required": true,  "choices": ["있어요 (1년 미만)", "있어요 (1년 이상)", "없어요"] }
    ]
  },

  "myMembership": {
    "userId": "u_me",
    "clubId": "club_sound",
    "role": null,
    "active": false,
    "joinStatus": null
  },

  "myApplication": {
    "id": "japp_201",
    "applicantId": "u_me",
    "clubId": "club_sound",
    "status": "pending",
    "appliedAt": "2026-06-22T11:30:00Z",
    "note": "보컬 / 통기타 3년 차입니다.",
    "answers": [
      { "questionId": "q_part",  "label": "담당 파트 (해당 시 선택)", "value": "🎸 기타" },
      { "questionId": "q_model", "label": "현재 사용하는 악기 브랜드/모델", "value": "Taylor 314ce" },
      { "questionId": "q_exp",   "label": "합주 경험 있으신가요?", "value": "있어요 (1년 이상)" }
    ]
  },

  "pendingApplications": {
    "items": [
      {
        "id": "japp_301",
        "applicantId": "u_hong",
        "applicant": { "nickname": "홍길동", "age": 24, "photo": "https://cdn.moisho.app/u/hong.webp", "tags": ["밴드", "친목"], "temp": 37.2, "verified": true },
        "clubId": "club_sound",
        "status": "pending",
        "appliedAt": "2026-06-22T09:10:00Z",
        "note": "보컬 / 통기타 3년 차입니다.",
        "answers": [
          { "questionId": "q_part", "label": "담당 파트 (해당 시 선택)", "value": "🎺 보컬" },
          { "questionId": "q_exp",  "label": "합주 경험 있으신가요?", "value": "있어요 (1년 이상)" }
        ]
      },
      {
        "id": "japp_302",
        "applicantId": "u_ddang",
        "applicant": { "nickname": "이땡땡", "age": 22, "photo": "https://cdn.moisho.app/u/ddang.webp", "tags": ["밴드", "독서"], "temp": 36.9, "verified": true },
        "clubId": "club_sound",
        "status": "pending",
        "appliedAt": "2026-06-20T13:45:00Z",
        "note": "드럼 2년 차, 합주 경험 있어요.",
        "answers": [
          { "questionId": "q_part", "label": "담당 파트 (해당 시 선택)", "value": "🥁 드럼" },
          { "questionId": "q_exp",  "label": "합주 경험 있으신가요?", "value": "있어요 (1년 미만)" }
        ]
      }
    ],
    "nextCursor": null
  },

  "discoverClubs": {
    "items": [
      { "id": "club_sound",  "name": "홍대 연합 밴드 '사운드'", "category": "문화·예술", "coverImg": "https://cdn.moisho.app/clubs/club_sound/cover.webp", "intro": "합주실 보유 · 월 2회 정기공연", "memberCount": 28, "capacity": 30, "openRecruit": true,  "tags": ["#밴드", "#공연"], "trustGrade": "A" },
      { "id": "club_futsal", "name": "토요 풋살회 '풋살러'",   "category": "운동·스포츠", "coverImg": "https://cdn.moisho.app/clubs/club_futsal/cover.webp", "intro": "매주 토요일 영통 풋살", "memberCount": 14, "capacity": 14, "openRecruit": false, "tags": ["#풋살"], "trustGrade": "B" }
    ],
    "nextCursor": "eyJpZCI6ImNsdWJfZnV0c2FsIn0="
  }
}
```

주의: `Club.capacity`·`openRecruit`은 데이터정의서엔 있으나 openapi `Club` 응답 스키마(680~691행)엔 **빠져 있다** → §5 MODIFY 대상. `applicant`(닉네임·매너온도·verified) 객체와 `answers[].label`은 검토 화면 렌더에 필수이므로 응답에 동봉해야 한다.
