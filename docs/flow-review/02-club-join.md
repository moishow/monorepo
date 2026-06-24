# 동아리 탐색·가입·승인 저니 — 프로덕트+핀테크 리뷰

> 정본 대조: `openapi.yaml`(164~238행 discover/clubs), `docs/02·03·04`, Flutter `discover_screen.dart`, 프로토타입 5종(ClubDetail·MemberApproval·ClubJoinApply·ClubFormBuilder·CreateClub).
> 이 저니는 **포인트 이동이 없는 비-머니 저니**다. 따라서 에스크로 상태(OPEN/LOCKED)·멱등·원장분개는 해당 없음(§5 자체검증에 명시). 단 `POST applications`의 **verified 게이트**는 실재한다.

## 1. 현재 플로우

지금 구현/목업의 화면 전이는 다음과 같다.

```
[탐색 탭(DiscoverScreen)] ──카드 tap──> _stub() "준비 중인 화면이에요"
        │
        │ (프로토타입에만 존재, Flutter 미구현)
        ▼
[ClubDetailScreen] ── isMember 토글로 회원/비회원 뷰 분기
        │  ├ 비회원: "가입 신청" 버튼 → onNavigate("clubJoinApply")
        │  └ 회원: "모임방 입장" → onNavigate("clubRoom")
        ▼
[ClubJoinApplyScreen] ── 악기/요일/동기(하드코딩 builtIn) + 한줄소개 + 약관동의
        │  canSubmit = 악기≥1 && 요일≥1 && 소개≥20자 && 약관
        │  제출 → 토스트 "신청서 제출 완료 🎉" → 1.8s 뒤 clubDetail 복귀
        ▼
[운영진 측: MemberApprovalScreen]
        │  신청자 목록(status: pending) → 신청자 검토(매너온도·답변)
        │  act(i, 'approved'|'rejected') → 로컬 status 변경
        ▼
(승인 시 Membership 생성 — 프로토타입엔 후속 연결 없음)

[운영진 폼 설정: ClubFormBuilderScreen]
        builtIns{days,motivation,experience} 토글 + questions[] CRUD(추가/삭제/이동/선택지)
[개설: CreateClubScreen] name·cat·intro·capacity(기본30)·openRecruit(기본 true)
```

**구현 상태**
- **Flutter 실제 구현**: 탐색 탭(`DiscoverScreen`)의 **모임(Meeting) 탐색**만. 필터(카테고리·거리·상태·검색·위치 시/도→시군구 시트)는 동작. 단 **동아리(Club) 탐색은 없음** — 탭은 모임만 보여주고, 모든 카드 `onTap`은 `_stub`(준비 중). FAB의 "동아리 모임 생성"·"개인 번개 생성"도 `_stub`.
- **프로토타입(React)에만 존재, Flutter 미이식**: ClubDetail·ClubJoinApply·MemberApproval·ClubFormBuilder·CreateClub 전부. 즉 **이 저니의 동아리 가입·승인 동선은 Flutter에 한 줄도 없다(전부 stub).**
- **목업 한계(전부 로컬 state, 백엔드 미연동)**: `isMember`는 버튼 토글, 승인은 배열 in-place 변경, 신청서 builtIn 질문은 하드코딩(폼빌더의 동적 questions와 분리), 정원·중복·verified 가드 전무.

## 2. 갭·논리모순·누락 엣지케이스

**[CRITICAL] `answers` 스키마 3중 불일치 — 운영진 검토 화면이 깨진다**
세 레이어가 서로 다른 형식을 쓴다.
- openapi `JoinApplicationCreate.answers` = `[{questionId, value}]` (질문 ID 참조형)
- 데이터정의서 `JoinApplication.answers` = `[[질문, 답변]]` (label–답변 쌍)
- 프로토타입: ClubJoinApply는 builtIn 질문을 **하드코딩**해 questionId를 아예 생성하지 않고, MemberApproval은 `[["지원 동기","..."]]` label-쌍으로 렌더.
→ API는 `questionId`만 보내라는데 저장·검토 레이어는 사람이 읽는 label이 필요하다. questionId만 저장하면 운영진 검토 화면이 "q_1: 통기타 3년"처럼 의미불명이 되고, 총무가 폼을 수정(질문 삭제/문구 변경)하면 과거 신청의 label-쌍은 깨지거나 dangling 참조가 된다. **데이터정합 위반.** 예시: 신청 시 폼이 "담당 파트"였는데 승인 대기 중 총무가 그 질문을 지우면, MemberApproval은 `[["담당 파트","기타"]]`를 보여줄 근거를 잃는다.

**[HIGH] `POST applications`는 verified 게이트인데 신청 화면에 KYC 분기 없음**
openapi·docs/03 모두 가입 신청을 `verified` 태그로 명시(`403 KYC_REQUIRED`). 그러나 프로토타입 ClubJoinApply의 `canSubmit`은 악기·요일·소개·약관만 검사하고 **본인인증 여부를 보지 않는다.** 미인증 사용자가 신청서를 다 채우고 제출 버튼을 눌러야 비로소 403을 맞는다. → 헛수고 UX + 머니규칙(§4-7 verified 게이트) 우회 시도 노출. 가입 단계에서 KYC를 강제하는 건 "동아리 가입=장부·회비 흐름 진입"이라 합당하나, 화면이 사전 차단/안내를 안 한다.

**[HIGH] 정원(capacity) 가드 부재 — 승인 시 초과 가입 가능**
Club에 `capacity`(예 30)와 `memberCount`가 있고 CreateClub에서 설정하지만, 가입/승인 어디에도 `memberCount ≥ capacity` 체크가 없다. MemberApproval의 `act(i,'approved')`는 무조건 승인. docs/04는 정원초과를 `409 ROUND_FULL`로 정의했지만 그건 **차수(Round) 전용**이고 동아리 가입엔 매핑이 없다. → 정원 31명째가 승인돼도 막을 표준 에러가 없다. **데이터정합·UX 갭.** 예시: 정원 30 동아리에 15명이 동시 pending인데 총무가 전부 approve.

**[HIGH] 신청 "철회(withdraw)" 상태·엔드포인트 부재**
태스크가 명시한 상태(대기/승인/거절/**철회**)인데, `JoinApplication.status` enum은 `pending·approved·rejected`뿐이고 openapi `/clubs/{id}/applications/{aid}`에 **DELETE/PATCH가 없다**(212~215행 확인). → 신청자가 마음을 바꿔도 신청을 취소할 길이 없다. 신청자 본인이 자기 신청 상태를 보는 엔드포인트(`/me/applications` 류)도 **없음**(`GET applications`는 club.staff 전용). 신청 후 신청자는 자기 신청이 어디 있는지조차 못 본다.

**[MEDIUM] `openRecruit=false`의 의미가 미정의 — 비공개/모집중단/초대제 구분 없음**
데이터정의서 `openRecruit bool 가입 신청 받기(승인제)`. CreateClub 기본 true. 그러나 false일 때 동작이 스펙에 없다: (a) 신청 버튼 숨김(모집중단), (b) 비공개(상세 자체 숨김), (c) 초대제(링크/코드) 중 무엇인지 미정의. `POST applications`도 openRecruit=false를 거부하는 규칙이 없다. → 모집 마감한 동아리에 신청이 들어오는 논리구멍. 참고: openapi엔 **instant-join(자유가입) 엔드포인트가 없으므로 현재 제품은 "승인제 단일 모델"**이며, 자유가입은 별도 NEW 기능이다(발명 금지, 갭으로만 제안).

**[MEDIUM] 중복·재신청 정책의 경계 모호**
docs/04는 `409 = "이미 신청/회원"`으로 중복신청을 차단한다(EXISTS). 하지만 **거절(rejected)된 사람의 재신청**, **나갔다가(active=false) 재가입** 케이스가 미정의. rejected도 "이미 신청"으로 409면 영구 차단, 아니면 무한 재신청 가능. → 정책 공백.

**[MEDIUM] 신청서 builtIn 응답이 폼빌더 동적 questions와 미연결**
ClubFormBuilder는 `builtIns{days,motivation,experience}` 토글 + `questions[]`(동적)을 만드는데, ClubJoinApply는 악기/요일/동기를 **하드코딩**한다. 즉 총무가 폼에서 "experience"를 켜거나 질문을 추가해도 신청 화면에 반영 안 됨. application-form API(`GET /clubs/{id}/application-form`)를 신청 화면이 호출해 동적 렌더해야 하는데 그 연결이 설계에 없다. → 폼빌더 기능이 사실상 死기능.

**[MEDIUM] 동아리 탐색 자체가 빈약 + Flutter 미구현**
`GET /discover/clubs`는 `q`·`category`만 받고 **cursor/limit 페이지네이션·정렬·상태(모집중/마감) 필터가 없다**(181~182행). 응답 스키마도 미정의(`200 OK`만). 게다가 Flutter 탐색 탭은 동아리를 아예 안 보여준다. → 저니의 출발점(탐색→상세)이 끊겨 있다.

## 3. 개선된 유저 플로우

### 화면 추가·순서 변경
1. **탐색 탭에 "모임 / 동아리" 세그먼트 추가** — 현재 모임만 보이는 `DiscoverScreen`에 토글. 동아리 모드는 `GET /discover/clubs`(페이지네이션·status 필터 추가본) 사용. (Flutter 신규 구현)
2. **ClubDetail 가입 버튼을 상태기반으로 분기** — `isMember` 토글을 제거하고 서버의 내 멤버십/신청상태로 버튼 결정: 비회원·신청가능 → "가입 신청", 신청중 → "신청 검토중(철회)", 회원 → "모임방 입장", openRecruit=false → "현재 모집을 받지 않아요"(비활성).
3. **ClubJoinApply를 동적 폼으로 전환** — 진입 시 `GET /clubs/{id}/application-form`을 로드해 builtIns+questions를 렌더. 진입 직전 **verified 가드**: 미인증이면 신청서 대신 "본인인증 후 가입할 수 있어요" + KYC 화면 라우팅.
4. **신청자용 "내 신청 현황" 화면 신설** — 마이페이지에 `GET /me/applications`(NEW)로 대기/승인/거절 리스트 + **철회** 버튼.
5. **MemberApproval에 정원 게이지 + 승인 가드** — 헤더에 `memberCount/capacity` 표시, 정원 도달 시 approve 버튼 비활성 + "정원이 가득 찼어요".

### 상태머신 — JoinApplication (포인트 이동 없음)

```
stateDiagram-v2
    [*] --> PENDING : POST /clubs/{id}/applications (verified, openRecruit=true)
    PENDING --> APPROVED : decision=approve (club.staff) [memberCount<capacity]
    PENDING --> REJECTED : decision=reject (club.staff)
    PENDING --> WITHDRAWN : DELETE /me/applications/{aid} (self) [NEW]
    APPROVED --> [*] : Membership(joinStatus=승인, role=member) 생성 + 알림
    REJECTED --> PENDING : 재신청(정책 허용 시, 쿨다운 후)
    WITHDRAWN --> PENDING : 재신청
    note right of APPROVED
      memberCount==capacity 이면
      decision=approve 시 409 CLUB_FULL(NEW)
    end note
```

### Membership 연동 (승인의 결과)
```
APPROVED(JoinApplication) ──> Membership{ joinStatus:승인, role:member, active:true }
                                memberCount += 1  (재계산 가능)
```
역할(member→staff/treasurer/leader)은 이후 `PATCH /clubs/{id}/members/{uid}`(club.leader)로 위임 — 가입 저니 범위 밖.

## 4. 백엔드 의존 데이터 — 샘플 JSON

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

## 5. API 정합 (요청 형식)

각 행은 `openapi.yaml` grep으로 존재 여부를 확인해 표기했다(164~238행).

| 플로우 스텝 | 상태 | Method | URI | 설명 | Request 샘플 | Response 샘플 |
|---|---|---|---|---|---|---|
| 동아리 탐색 | **MODIFY** `/discover/clubs`(181행: q·category만) — cursor/limit·status 필터·응답 스키마 추가 | GET | `/discover/clubs?q=밴드&category=문화·예술&status=recruiting&cursor=&limit=20` | public 탐색 | (query) | `{ "items":[{...club}], "nextCursor":"eyJ..." }` |
| 동아리 상세 | **MODIFY** `/clubs/{id}`(196행) — `Club` 스키마에 capacity·openRecruit·내 멤버십/신청상태 추가 | GET | `/clubs/club_sound` | public(회원/비회원 분기) | — | `{ "id":"club_sound","capacity":30,"openRecruit":true,"viewerState":{"membership":null,"applicationStatus":null} }` |
| 신청서 폼 로드 | **EXISTS** `/clubs/{id}/application-form`(210행) — 권한 **MODIFY**: 신청자도 읽어야 함(현재 club.staff) | GET | `/clubs/club_sound/application-form` | 신청 화면 동적 렌더 | — | `{ "title":"...","builtIns":{...},"questions":[{"id":"q_part",...}] }` |
| (운영진) 폼빌더 저장 | **EXISTS** `/clubs/{id}/application-form`(211행, PUT) | PUT | `/clubs/club_sound/application-form` · `club.staff` | 동적 양식 저장 | `{ "title":"...","builtIns":{"experience":true},"questions":[{"id":"q_part","type":"choice","label":"담당 파트","required":true,"choices":["🎸 기타"]}] }` | `200 OK` |
| 가입 신청 | **EXISTS** `/clubs/{id}/applications`(213행, POST) · `verified` · 409=이미신청/회원(docs04) | POST | `/clubs/club_sound/applications` · **verified** | 폼 답변 제출 | `{ "answers":[{"questionId":"q_part","value":"🎸 기타"},{"questionId":"q_exp","value":"있어요 (1년 이상)"}], "note":"통기타 3년 차" }` | `201 Created {"id":"japp_201","status":"pending"}` · 미인증 `403 KYC_REQUIRED` · 중복 `409 CONFLICT` |
| 내 신청 현황 | **NEW** (openapi에 self 조회 없음 — `GET applications`는 club.staff 전용) | GET | `/me/applications` · `self` | 신청자 본인 대기/승인/거절 목록 | — | `{ "items":[{"id":"japp_201","clubId":"club_sound","status":"pending","appliedAt":"2026-06-22T11:30:00Z"}] }` |
| 신청 철회 | **NEW** (`/applications/{aid}`에 DELETE 없음, status enum에 withdrawn 없음) | DELETE | `/me/applications/japp_201` · `self` | pending→withdrawn | — | `204 No Content` · 이미처리 `409 CONFLICT` |
| (운영진) 신청자 목록 | **EXISTS** `/clubs/{id}/applications`(214행, GET) · `club.staff` — 응답에 applicant·answers.label 동봉 필요 | GET | `/clubs/club_sound/applications?cursor=&limit=20` | 신청자 검토 큐 | — | `{ "items":[{"id":"japp_301","applicant":{"nickname":"홍길동","temp":37.2,"verified":true},"answers":[{"label":"담당 파트","value":"🎺 보컬"}]}], "nextCursor":null }` |
| (운영진) 승인/반려 | **EXISTS** `/clubs/{id}/applications/{aid}/decision`(215행, POST) · `club.staff` — **MODIFY**: memberCount≥capacity 시 정원 가드 추가 | POST | `/clubs/club_sound/applications/japp_301/decision` · **club.staff** | approve→Membership 생성+알림 | `{ "decision":"approve" }` 또는 `{ "decision":"reject","reason":"파트 정원 초과" }` | `200 OK` · 정원초과 `409 CLUB_FULL`(NEW 에러코드) |
| 회원 목록 | **EXISTS** `/clubs/{id}/members`(199행, GET) · `club.member` | GET | `/clubs/club_sound/members` | 승인 후 부원 표시 | — | `{ "items":[{"userId":"u_hong","role":"member","joinedMonth":"2026.06","active":true}] }` |

비고: 가입 신청·승인은 **포인트 이동이 없으므로 `Idempotency-Key`를 달지 않는다**(에스크로 op만 멱등 필수). verified는 신청(`POST applications`)에만 적용, 승인(`decision`)은 club.staff 권한 게이트.

### §4/§11 자체검증
- **회원 간 송금 API**: 신설/제안한 엔드포인트는 탐색·상세·신청·철회·승인·회원조회뿐 — 사용자 간 송금 경로 없음. ✅ 위반 없음
- **포인트를 모임 정산 외 용도**: 이 저니는 포인트를 전혀 다루지 않음(가입은 무상). ✅ 위반 없음
- **충전·출금 수수료**: 금전 op 자체가 없음 → 수수료 항목 없음. ✅ 위반 없음
- **원장(LedgerEntry) 수정·삭제**: LedgerEntry를 생성·변경하지 않음(append-only 무관). ✅ 위반 없음
- **멱등 누락**: 머니 op가 없어 멱등 대상 아님 — `Idempotency-Key` 의도적으로 미부착(정당). ✅ 위반 없음
- **verified 게이트 누락**: `POST applications`에 verified 명시 + 미인증 `403 KYC_REQUIRED` 처리 + 신청화면 사전 KYC 분기 제안. ✅ 준수
- **AuditLog**: 승인/반려는 멤버십 변경(민감)이므로 before/after AuditLog 권장(§4-8) — 제안에 포함. ✅ 준수
- **openapi 계약 준수**: 신규는 `/me/applications`(GET/DELETE)·`CLUB_FULL` 에러코드 2건만 NEW로 명시, 나머지는 기존 path에 매핑. 발명 최소화. ✅ 준수
