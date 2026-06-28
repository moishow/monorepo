# 신규 3기능 화면 명세 (/spec 산출물)

> gstack `/spec` 1단계 산출물 — `07-new-features-validation.md`의 확정 결정 4종을 **Flutter 화면 작업**으로 확정. /autoplan(2단계) 입력.
> 작성: 2026-06-28 · 브랜치 `feat/proto-screens` · 코드 grounding: `app/lib/` 실측(라우팅·토큰·위젯·기존화면).
> ⚠ 쇼츠 제외. 백엔드 머니수학(잔액=분개합·멱등·5분 서버시계·위약금 분개)은 **흉내만**(시뮬레이션 표시).

---

## 0. 화면 작업 인벤토리 (한눈에)

| 기능 | 화면 | 종류 | 파일 | 핵심 |
|---|---|---|---|---|
| **F1a** | 모임생성 폼 | MODIFY | `features/meeting/create_meeting_screen.dart` | 게스트 번개 매칭 토글 추가 |
| **F1b** | 모임생성 폼 | MODIFY | 〃 | 출금 가능시각 타임피커(≥만남시각) |
| **F1c** | 모임생성 폼 | MODIFY | 〃 | 장소 지도링크 필드(https) |
| **F2-1** | 게스트 신청 | **NEW** | `features/club/guest_apply_screen.dart` | 외부인 체험신청 + KYC 게이트 |
| **F2-2** | 게스트 매칭(관리자) | **NEW** | `features/club/guest_match_admin_screen.dart` | 신청자 수 + 날짜투표 + 종료상태 |
| **F2-3** | 게스트 가입승인 | MODIFY | `features/club/member_approval_screen.dart` | 번개검증 배지 + 승인(정산 직교) |
| **F2-aux** | 단발성 번개(자동개최) | REUSE | `features/meeting/flash_apply_screen.dart`·`meeting_detail_screen.dart` | 5000원 예약금·에스크로 카드(목업) |
| **F3-1** | 정산 피드 | MODIFY | `features/settlement/settlement_detail_screen.dart` | 광고 레이아웃 완전 제거 |
| **F3-2** | 취소/위약금 | MODIFY | `features/settlement/deposit_confirm_screen.dart` + 모임상세 | 시간별 취소 위약금 표시 |
| **F3-3** | 총무 출금동의받기 | MODIFY | `features/treasurer/treasurer_payout_screen.dart`·`treasurer_screen.dart` | "출금 동의받기"→5분 알림 발송, 전액출금 |
| **F3-4** | 부원 출금동의 | MODIFY | `features/treasurer/payout_consent_screen.dart` | 5분 카운트다운·동의=확인/거절=이의(출금 안막음) |
| **F3-5** | OCR 영수증 | MODIFY | `features/settlement/settle_return_screen.dart` | OCR값 수정가능 + 원본사진 강제노출 |
| **F3-6** | 인라인 알림액션 | MODIFY | `features/social/notifications_screen.dart` | 알림 내 [동의/거절] 즉시 액션 |

**= NEW 2개 + MODIFY 8개 + REUSE 2개.** 80% 완성 목업 덕에 대부분 정밀 수정.

---

## 1. 공통 규약 (코드 실측 — 모든 신규/수정 화면이 따름)

- **화면 골격**: `Scaffold(backgroundColor: T.surfacePage, body: Column([MoishoStatusBar(), MoishoAppHeader(title:.., onBack:..), Expanded(ScrollBody(children:[..])), StickyBar(child: MButton(..))]))`.
- **토큰**: 색 `T.*`(T.primary/T.accent/T.success/T.danger/T.textStrong/T.surfaceCard/T.border*), 라운드 `T.rSm~r2xl`, 그림자 `T.shadow*`. 타이포 `tx(size, FontWeight, color, {height, tab})`. 금액 `won(int)` + `tx(..., tab:true)`(tabular figures). **새 색·간격 발명 금지**(CLAUDE.md §11).
- **상태**: 화면 = `StatefulWidget + setState`(폼/토글/카운트다운). 세션·verified·wallet = `sessionProvider`(core/data/session.dart) — KYC 게이트는 `ref.watch(sessionProvider.select((s)=>s.verified))`.
- **더미데이터**: 단일화면용 = 화면 내 `static const`; 공유 = `core/data/fixtures.dart`. 금액=정수(원), 시간=UTC ISO8601.
- **위젯 재사용**: `MButton(variant: primary/ghost/danger)`·`MCard(elevation: raised/flat, accent:..)`·`MBadge`·`MAvatar`·`MTag`·`ProgressBar`·`ddayInfo()`·`MoishoToast.show()`·`MinTapTarget(44px)`. **SnackBar·기본 Dialog 금지**, 토스트/시트로.
- **아이콘**: `LucideIcons.*`(이모지 금지, git 3326e3c).
- **네비**: 인플로우 = `Navigator.of(context).push(MaterialPageRoute(builder:(_)=>..))`. 최상위 진입은 `main.dart` `_router`에 `GoRoute` 추가(필요시).
- **머니수학 경계**: 화면은 상태·금액을 **표시만**. "5분 경과→거절", "위약금 12,000원 차감", "에스크로 전액 출금" 등은 하드코딩/시뮬레이션 텍스트. 실제 분개·멱등·서버시계 미구현.

---

## 2. F1 — 모임 생성 폼 고도화 (MODIFY `create_meeting_screen.dart`)

기존 폼(클럽선택·카테고리·일시·장소·설명·비용·펀딩설정·CTA)에 3필드 추가. 펀딩설정 섹션 하단 권장.

### F1a 게스트 번개 매칭 토글
- **UI**: `MCard(flat)` 안 스위치 행 — 라벨 "게스트 번개 매칭 신청받기" + 보조설명 "외부인이 체험 참여를 신청할 수 있어요". `Switch`(T.primary).
- **트리거**: 토글 ON → `setState(_allowGuestFlash=true)`. ON일 때만 이 모임이 F2 게스트 신청의 진입점이 됨(상세 화면에 "게스트 신청" 버튼 노출).
- **상태/목업**: `bool _allowGuestFlash = false`.

### F1b 출금 가능시각 타임피커
- **UI**: "출금 가능 시각" 라벨 + `showTimePicker`/`showDatePicker` 트리거 버튼(`MinTapTarget`). 보조설명 "만남 시각 이후로만 설정할 수 있어요 (그 전엔 출금이 잠겨요)".
- **검증(핵심)**: 선택값 `< 만남일시(datetime)`이면 차단 — 토스트 `MoishoToast.show(.., tone:'danger', '만남 시각 이후로만 설정할 수 있어요')` + 값 미반영. `≥ 만남일시`만 허용(결정3).
- **상태/목업**: `DateTime? _withdrawAt` (기본 = 만남일시). UTC 저장 가정, 표시만 KST.

### F1c 장소 지도링크
- **UI**: 기존 장소 자유텍스트 아래 "지도 링크(선택)" `TextField` + "지도에서 보기" 보조 액션(`LucideIcons.mapPin`).
- **검증**: 입력값이 `https://`로 시작 안 하면 토스트 경고 + 미반영(주입/오픈리다이렉트 차단, 07 §2-9).
- **상태/목업**: `String _mapUrl = ''`.

**수락 기준 F1**: ①토글 ON 시 모델에 `allowGuestFlash:true` 반영(상세에 게스트 버튼) ②출금시각 < 만남시각 입력 거부(토스트) ③지도링크 비-https 거부 ④세 필드 모두 기존 토큰·위젯으로 렌더, 새 색 없음.

---

## 3. F2 — 3-Step 게스트 온보딩 (NEW 2 + MODIFY 1 + REUSE)

상태머신(JoinApplication 확장, 머니=번개 에스크로 별도):
```
[외부인] --신청+KYC--> GUEST_PENDING
GUEST_PENDING --관리자 날짜투표 개설--> POLL_OPEN
POLL_OPEN --투표완료(정족수)--> FLASH_CREATED(단발성 번개 자동개최, 5000원 예약금)
POLL_OPEN --동점--> POLL_TIE(관리자 재투표/수동선택)
POLL_OPEN --기한초과/무투표--> POLL_EXPIRED(신청 보류·게스트 알림)
FLASH_CREATED --번개 만남·검증--> TRIAL_DONE
FLASH_CREATED --게스트 노쇼--> TRIAL_NOSHOW(예약금 위약·신청 자동보류)
TRIAL_DONE --관리자 가입승인(정원<capacity)--> MEMBER(동일 JoinApplication 머신, 409 CLUB_FULL 가드)
TRIAL_DONE --승인 무한방치(타임아웃)--> TRIAL_APPROVAL_TIMEOUT(게스트 알림·환불 옵션)
GUEST_PENDING/POLL_OPEN --게스트 철회--> TRIAL_WITHDRAWN
```

### F2-1 게스트 신청 (NEW `guest_apply_screen.dart`)
- **진입**: `club_detail_screen.dart`에서 `allowGuestFlash && !isMember` → "게스트로 체험 신청" 버튼.
- **UI**: 동아리 요약 카드 + 한줄 자기소개 `TextField` + 희망 활동 `MTag` 선택 + **KYC 게이트**: `!verified`면 폼 대신 `MCard`로 "본인인증 후 신청할 수 있어요"(`LucideIcons.shieldQuestion`) + "본인인증 하기" 버튼(→ KYC 시뮬레이션 → `sessionProvider.verifyKyc()`).
- **트리거**: 제출 → `MoishoToast.show(.., '게스트 신청 완료 🎉')` → 상세 복귀. 상태 GUEST_PENDING.
- **목업**: `bool _verified`(세션), `String _intro`, `List<String> _wants`.

### F2-2 게스트 매칭 관리자 뷰 (NEW `guest_match_admin_screen.dart`)
- **진입**: 관리자(club.staff)가 동아리 관리/알림에서.
- **UI**: ①게스트 신청자 리스트(`MAvatar`+닉네임+자기소개+신뢰배지 **서버값**, 07 §2-4) + 카운트 헤더. ②**날짜 투표 컴포넌트**: 후보 날짜 3~4개 행 + 각 득표수 `ProgressBar` + "투표 마감" 버튼. ③종료상태 처리: 동점→"동점이에요, 날짜를 직접 고르거나 재투표"(POLL_TIE), 정족수 미달→"아직 정족수 미달"(empty/disabled).
- **트리거**: "투표 마감 & 번개 개최" → 시뮬레이션으로 단발성 번개 생성 → `flash_apply`/`meeting_detail`로 네비(FLASH_CREATED). 상태 배지로 전이 표시.
- **목업**: `List<_DateOption>(label, votes)`, `int _quorum`, 종료상태 enum 텍스트.

### F2-aux 단발성 번개 (REUSE `flash_apply_screen.dart` + `meeting_detail_screen.dart`)
- 기존 개인 번개와 **동일**: 차수당 5,000원 노쇼 예약금. hostId=관리자. **에스크로 카드는 "시스템 에스크로 보관 중"** 명시(게스트→관리자 직접송금 아님, 07 결정4). 출금은 만남시각 락+동의 경유(F3 흐름) 후 관리자 본인계좌. **신규 화면 없음** — 카피/배지만 보정.

### F2-3 게스트 가입승인 (MODIFY `member_approval_screen.dart`)
- **UI**: 기존 승인 큐에 게스트 항목 추가 — "번개 검증 완료" `MBadge(success)` + 번개 출석/매너 **서버 신호** 표시(클라 계산 금지, 07 §2-3). "가입 승인"/"보류" 버튼.
- **트리거**: 승인 → **동일 JoinApplication→Membership 전환**, `memberCount≥capacity`면 `MoishoToast(.., tone:'danger','정원이 가득 찼어요')`(409 CLUB_FULL 가드, 07 C-f). **정산과 직교**: 번개 정산은 승인과 무관하게 진행(승인 안 해도 게스트 예치금 인질 금지, 07 F2-6).
- **목업**: 게스트 항목에 `trialVerified:true`, `noshow:false`.

**수락 기준 F2**: ①게스트 토글 OFF 동아리엔 신청버튼 미노출 ②미인증 게스트는 KYC 게이트에서 차단 ③날짜투표 동점/정족수미달 종료상태 각각 UI로 표현 ④번개 에스크로 카드가 "시스템 보관"으로 표기 ⑤승인 시 정원초과면 차단 ⑥승인 버튼과 번개 정산이 서로 독립.

---

## 4. F3 — 결제/정산 피드 + 출금동의 (MODIFY 6)

### F3-1 정산 피드 광고 제거 (MODIFY `settlement_detail_screen.dart`)
- 기존 투명장부 뷰에서 **광고 레이아웃·"출금 직후 광고대기" 단계 완전 삭제**(07 C-k). 취합·출금·실지출·반납·1인당 + 영수증 썸네일만.

### F3-2 시간별 취소 위약금 (MODIFY `deposit_confirm_screen.dart` + 모임상세 취소)
- **UI**: 예치 확인/취소 화면에 "취소 위약금 안내" `MCard` — 시간 구간별 차감률 표(예: 마감~24h전 0% / 24h~6h 50% / 6h~만남 100%, 07 결정1). 취소 시 "환불 예상액 = 예치 − 위약금" 계산 표시. 위약금은 **"그룹 공동비용에 충당"** 명시(플랫폼·총무 0, §11).
- **트리거**: 취소 버튼 → 현재 구간 위약금 계산(시뮬) → 확인 시트 → 토스트.
- **목업**: `List<_PenaltyTier>(fromHrs, rate)`, `int _depositAmt`.

### F3-3 총무 출금동의받기 + 5분 (MODIFY `treasurer_payout_screen.dart`·`treasurer_screen.dart`)
- **UI**: "출금 동의받기" 버튼(`MButton primary`) — 누르면 "부원들에게 알림을 보냈어요" + **5분 카운트다운** 표시 + 동의 수집 현황(`agreed/total`, 무응답=위약금부담 노쇼로 표기). 5분 후 "동의 마감 — 전액 출금 가능"(전액출금, 결정1).
- **트리거**: 버튼 → 알림 발송 시뮬 + 5분 타이머 UI(클라 표시, 서버시계는 흉내). 출금 버튼은 **동의에 안 막힘**(전액출금).
- **목업**: `int _agreed`, `Duration _left`(카운트다운), `bool _payoutDone`.

### F3-4 부원 출금동의 (MODIFY `payout_consent_screen.dart`)
- **UI**: 기존 동의 화면에 **5분 카운트다운** + 프레이밍 보정 — "동의 = 정산 투명성 확인 / 거절 = 이의 기록(출금은 진행돼요)". 출금금액·내 예치·원본영수증 안내. **무응답 시 위약금 부담** 안내 문구.
- **트리거**: [동의]/[거절] → `_done` 상태 + 토스트. 거절은 이의로 기록되나 출금 차단 안 함(데드락 소멸, 07 결정1).
- **목업**: `String? _done`, `Duration _left`.

### F3-5 OCR 영수증 수정+원본강제노출 (MODIFY `settle_return_screen.dart`)
- **UI**: OCR 인식 결과 카드의 금액을 **편집 가능 `TextField`**(현재 잠금 → 해제, 07 결정2). 정수만 입력(`keyboardType: number`). **하단에 원본 영수증 사진 강제노출**(`NetImage`, 접거나 숨길 수 없음). "출금액 − 실지출 = 반납 잔액" 자동 재계산.
- **트리거**: 금액 수정 → 반납액 실시간 재계산. "반납하고 정산" → `settle_auto`로.
- **잔여리스크 표기(목업 허용)**: 상향 착복 강제력 없음 — 화면 하단에 작은 안내 "영수증 원본과 금액을 비교해 주세요"(실서비스 전 이의제기/AuditLog 보완, 07 결정2).
- **목업**: `int _actualSpent`(편집), `String _receiptUrl`(강제표시), `int _withdrawn`.

### F3-6 인라인 알림 액션 (MODIFY `notifications_screen.dart`)
- **UI**: 출금동의 알림(`kind: payout_consent`) 항목에 **인라인 [동의]/[거절] 버튼**(`MButton sm`) — 화면 진입 없이 그 자리에서 액션.
- **트리거**: 인라인 [동의] → 항목을 "동의함"으로 갱신 + 토스트(앱 진입 없음). 보안 주석: 실서비스는 단발성·수신자한정 토큰 필요(07 §2-3, 목업은 시뮬).
- **목업**: `_Notif`에 `actionable:true, action:'payout_consent'`, 처리 후 `resolved` 상태.

**수락 기준 F3**: ①정산 피드에 광고 0 ②취소 시 시간구간 위약금·환불예상액 표시, 위약금 "그룹 충당" 명시 ③총무 "출금 동의받기"→5분 카운트다운, 출금이 동의에 안 막힘 ④부원 동의화면 거절이 출금 차단 안 함 ⑤OCR 금액 편집 가능 + 원본사진 항상 노출 + 반납액 재계산 ⑥알림에서 진입 없이 동의/거절.

---

## 5. 더미 데이터 스키마 (화면 렌더용 — 금액 정수, 시간 UTC)

```json
{
  "f1_meetingDraft": {
    "allowGuestFlash": true,
    "datetime": "2026-07-04T09:00:00.000Z",
    "withdrawAt": "2026-07-04T11:00:00.000Z",
    "place": "홍대 사운드스튜디오",
    "mapUrl": "https://maps.google.com/?q=홍대+사운드스튜디오"
  },
  "f2_guestApplication": {
    "id": "gapp_01", "applicantId": "u_guest", "clubId": "club_sound",
    "state": "GUEST_PENDING", "intro": "보컬 지망, 합주 경험 있어요",
    "wants": ["#보컬", "#친목"], "verified": true,
    "trust": { "temp": 36.5, "source": "server" }
  },
  "f2_datePoll": {
    "id": "poll_01", "clubId": "club_sound", "quorum": 3,
    "options": [
      { "date": "2026-07-05T09:00:00.000Z", "votes": 4 },
      { "date": "2026-07-06T09:00:00.000Z", "votes": 4 },
      { "date": "2026-07-12T09:00:00.000Z", "votes": 1 }
    ],
    "state": "POLL_TIE"
  },
  "f2_flashMeeting": {
    "id": "mtg_flash01", "type": "flash", "hostId": "u_admin",
    "reservationFee": 5000, "escrowOwner": "system",
    "escrow": { "state": "OPEN", "balance": 15000, "custody": "system" }
  },
  "f3_penaltyTiers": [
    { "fromHrsBeforeMeet": 999, "toHrs": 24, "rate": 0.0 },
    { "fromHrsBeforeMeet": 24, "toHrs": 6, "rate": 0.5 },
    { "fromHrsBeforeMeet": 6, "toHrs": 0, "rate": 1.0 }
  ],
  "f3_payoutConsent": {
    "meetingId": "mtg_01", "required": 8, "agreed": 5,
    "deadlineAt": "2026-07-04T11:05:00.000Z", "timerSec": 300,
    "model": "fullPayout", "noResponseMeans": "feeBearingNoshow"
  },
  "f3_ocrReturn": {
    "withdrawn": 480000, "actualSpent": 412000, "returned": 68000,
    "receiptUrl": "https://cdn.moisho.app/r/rcpt_a1.jpg",
    "editable": true, "confidence": 0.98
  },
  "f3_inlineNotif": {
    "id": "ntf_01", "kind": "payout_consent", "actionable": true,
    "title": "총무가 출금 동의를 요청했어요", "meetingId": "mtg_01", "resolved": null
  }
}
```

---

## 6. 빌드 순서 / 의존성

```
F1a 게스트 토글 ─────> F2-1 게스트 신청 ──> F2-2 매칭(날짜투표) ──> F2-aux 번개(REUSE) ──> F2-3 가입승인
   (진입점 먼저)
F1b 출금시각 ┐
F1c 지도링크 ┘ (독립, 병렬 가능)

F3-4 부원 동의(전액출금 모델) ──> F3-3 총무 출금동의받기(5분) ──> F3-5 OCR 반납 ──> F3-1 정산피드(광고제거)
F3-2 위약금 ┐
F3-6 인라인 알림 ┘ (독립, 병렬 가능)
```
**근거**: F2는 F1a 토글이 진입점이라 선행. F3는 동의모델(결정1)이 총무·부원·OCR 화면을 관통하므로 동의화면 먼저 패턴 확정.

---

## 7. Out of Scope (명시적 제외)
- **백엔드 머니수학**: 잔액=분개합·멱등·5분 서버시계·위약금 분개·OCR→원장 바인딩 — 목업은 표시/시뮬만.
- **CLAUDE.md §6 개정**("취소·환불 자유"→"시간별 위약금"): 별도 1줄 커밋(07 결정1, 본 명세 밖).
- **OCR 이의제기/AuditLog 보완**: 실서비스 전 TODO(07 결정2 잔여리스크).
- **쇼츠**: 이미 구현, 제외.
- **실제 KYC·카카오페이·지도 SDK 연동**: 시뮬레이션.

---

## 8. /autoplan 핸드오프
- 본 명세 = /autoplan 입력. 3 스프린트 권장: **①UI 목업(화면·필드·네비) → ②상태전이(토글·5분타이머·위약금계산·OCR재계산 시뮬) → ③더미데이터 모킹(§5 스키마)**.
- NEW 2 / MODIFY 8 / REUSE 2. 빌드순서 §6 준수.
- 각 화면 수락기준은 §2~4 말미.
