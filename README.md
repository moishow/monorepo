# 모이쇼(Moisho) — 개발 핸드오프 패키지

> 동아리·소모임의 회비/펀딩을 **모으고 → 예산을 짜고 → 투명하게 정산**하는 핀테크 서비스.
> 콘셉트: **"신뢰감을 주는 활기찬 핀테크 (Vibrant Fintech)"**

> 🌐 **라이브 사이트(권장)** → **<https://moishow.github.io/design/>**
> 모든 설계 문서·프로토타입을 디자인 시스템이 적용된 HTML 랜딩에서 한눈에 둘러볼 수 있습니다.
> (아래 마크다운 링크 목록은 GitHub 레포 뷰용 보조 자료입니다.)

이 패키지는 Claude Code로 모이쇼를 **풀스택 구현**하기 위한 단일 출처(single source of truth)입니다.
회의에 없던 개발자도 이 폴더만 보고 구현을 시작할 수 있도록 작성되었습니다.

---

## 📂 문서 바로가기

> 아래 링크는 [GitHub Pages](https://moishow.github.io/design/)에서 브라우저로 바로 열립니다. (HTML 문서·프로토타입은 클릭 시 렌더링)

### 설계 문서 (`docs/`)
| 문서 | 설명 |
|---|---|
| [01 · PRD](docs/01_PRD.html) | 제품 요구사항 · 페르소나 · 머니플로우 · 상태머신 |
| [02 · 데이터 정의서](docs/02_%EB%8D%B0%EC%9D%B4%ED%84%B0%EC%A0%95%EC%9D%98%EC%84%9C.html) | 33개 엔티티 · 필드 · 관계 |
| [03 · API 권한설계서](docs/03_API_%EA%B6%8C%ED%95%9C%EC%84%A4%EA%B3%84%EC%84%9C.html) | 85개 엔드포인트 + RBAC 권한 매트릭스 |
| [04 · API 상세명세서](docs/04_API_%EC%83%81%EC%84%B8%EB%AA%85%EC%84%B8%EC%84%9C.html) | Req/Res 스키마 · 에러 코드 · 결제 시퀀스 |
| [05 · 포인트 에스크로 정산모델](docs/05_%ED%8F%AC%EC%9D%B8%ED%8A%B8%EC%97%90%EC%8A%A4%ED%81%AC%EB%A1%9C%EC%A0%95%EC%82%B0%EB%AA%A8%EB%8D%B8.html) ⭐ | 머니플로우 정본 · 5단계 에스크로 · 포인트 원장 |

### 디자인 (`design/`)
| 항목 | 설명 |
|---|---|
| [📱 모바일 앱 프로토타입](design/prototype-app.html) | 로그인 + 5탭 하이파이 (자체완결 단일 파일) |
| [🖥 운영 어드민 프로토타입](design/prototype-admin.html) | 웹 어드민 하이파이 (자체완결 단일 파일) |
| [🗂 화면 정의서 / 와이어프레임](design/spec/Moisho%20Spec.html) | 로파이 플로우 참고 자료 |
| [🎨 디자인 토큰 요약](design/design-tokens.md) | 색·타이포·간격·라운드·섀도·모션 |

### 계약 · 규칙
| 파일 | 설명 |
|---|---|
| [openapi.yaml](openapi.yaml) | API 계약 (OpenAPI 3.1, raw 텍스트) |
| [CLAUDE.md](CLAUDE.md) | Claude Code 프로젝트 규칙서 |

---

## 0. 이 패키지를 읽는 순서

1. **이 README** — 전체 그림 · 기술 스택 · 빌드 순서
2. **`CLAUDE.md`** — Claude Code가 매 세션 읽어야 할 프로젝트 규칙(레포 구조·코딩 컨벤션·DoD)
3. **`docs/` 의 설계 문서 5종**(HTML, 브라우저로 열기)
   - `01_PRD.html` — 제품 요구사항(기능·페르소나·머니플로우·상태머신)
   - `02_데이터정의서.html` — 33개 엔티티 · 필드 · 관계 (목업에서 역추출한 **실제** 데이터 모델)
   - `03_API_권한설계서.html` — 85개 엔드포인트 + RBAC 권한 매트릭스
   - `04_API_상세명세서.html` — Req/Res JSON 스키마 · 에러 코드 · 결제 시퀀스
   - `05_포인트에스크로정산모델.html` — ⭐**머니플로우 정본** · 5단계 에스크로 · 포인트 원장 · 패널티 · OCR · 동시성 · 법적전략
4. **`openapi.yaml`** — 기계가 읽는 API 계약(코드 생성·Swagger UI·Flutter 클라이언트 생성에 사용)
5. **`design/` 의 디자인 레퍼런스** — 프로토타입 위치 · 디자인 토큰

> ⚠️ **중요 — 디자인 파일의 성격**
> `design/` 안의 HTML/JSX 프로토타입은 **디자인 레퍼런스**입니다(의도된 외관·동작을 보여주는 시안). 그대로 복사해 출시하는 코드가 아닙니다.
> 과업은 이 시안을 **Flutter**로, 백엔드 설계를 **Spring Boot**로 **재구현**하는 것입니다.

---

## 1. 무엇을 만드는가 (제품 요약)

모이쇼는 두 개의 클라이언트와 하나의 서버로 구성됩니다.

| 클라이언트 | 사용자 | 핵심 |
|---|---|---|
| **모바일 앱** (Flutter) | 부원 · 총무 | 탐색·가입·펀딩 납부·정산·쇼/Showts·DM·지갑 |
| **운영 어드민** (웹, 별도/후순위) | 본사 운영팀 | 입금 대사·지급 승인·모더레이션·CS·푸시·리포트 |

- **머니플로우 핵심 (정본: `docs/05`)**: 자금은 **앱 포인트 기반 기간 제한형 에스크로**로 흐른다 — 예치(OPEN) → 만남시각 락(LOCKED) → 락 스냅샷 전원 출금 동의(CONSENT) → 총무 출금(WITHDRAWN) → 증빙·잔액 반납(SETTLING) → 자동 균등 정산·현금화(DONE). **카카오페이는 포인트 충전·현금화 레일로만** 사용(회원 간 송금 없음). 잔액은 **포인트 원장(LedgerEntry)** 분개로 표현.
- **신뢰·방어 장치**: 안심 예산안, 매너온도·신뢰등급, 만남시각 락(취소권↔출금권 전환), 정산 데드라인 패널티(총무 권한 박탈), 영수증 OCR 강제 매핑, append-only 원장, 감사 로그.
- **법적 전략**: 포인트는 모임 정산 목적 외 사용 불가 + 정산 즉시 현금화로 발행 잔액 최소화 → 선불업 등록 유예. 충전·출금 수수료 0원 → 비영리 지위. 수익은 인앱 광고(결제선 분리).

> ⚠️ `01~04` 문서에 남은 "카카오페이 즉시 이체/`attendances`/`payments/kakao/ready·approve`" 서술은 **`05` 에스크로 모델로 대체**됨. 머니플로우는 `05` + `openapi.yaml`이 정본.

상세는 `docs/01_PRD.html` 참고.

---

## 2. 확정된 기술 스택

| 영역 | 선택 | 메모 |
|---|---|---|
| **백엔드** | **Spring Boot (Kotlin)** | Java도 가능. 본 문서 예시는 Kotlin 기준 |
| **프론트엔드(앱)** | **Flutter** | 프로토타입은 React지만 디자인 레퍼런스로만 사용 |
| **DB** | **MySQL 8.x** | 금액은 `BIGINT`(원, 정수), 시간은 `DATETIME(6)` UTC |
| **API** | REST · JSON · `openapi.yaml` 계약 | |
| **결제** | **앱 포인트 + 카카오페이 충전/현금화** (PG 아님) | `PaymentProvider` 어댑터로 추상화 → 추후 PG 전환 대비 |
| **레포** | **빈 새 모노레포** | `backend/` + `app/` + `docs/` 구조 권장 |

> **수수료 정책**: 출시 초기 **0%(무료)**. 규모 확대 시 PG 전환과 함께 변경 예정 → `FeePolicy`를 버전 관리형으로 설계.

---

## 3. 권장 레포 구조 (빈 새 레포 기준)

```
moisho/
├── CLAUDE.md                 # Claude Code 프로젝트 규칙 (이 패키지에서 복사)
├── openapi.yaml              # API 계약 (이 패키지에서 복사)
├── docs/                     # 설계 문서 (이 패키지에서 복사)
│   ├── 01_PRD.html
│   ├── 02_데이터정의서.html
│   ├── 03_API_권한설계서.html
│   └── 04_API_상세명세서.html
├── backend/                  # Spring Boot (Kotlin) + MySQL
│   ├── build.gradle.kts
│   └── src/main/kotlin/app/moisho/
│       ├── auth/  user/  trust/  club/  meeting/
│       ├── payment/  settlement/  ledger/  social/
│       ├── admin/  notification/  common/
│       └── MoishoApplication.kt
└── app/                      # Flutter
    ├── pubspec.yaml
    └── lib/
        ├── core/  (theme, network, router, di)
        ├── features/ (auth, discover, club, meeting, funding,
        │              settlement, wallet, show, showts, dm, profile)
        └── main.dart
```

도메인 경계는 `docs/02_데이터정의서.html`의 7개 그룹(A 계정·신뢰 / B 동아리 / C 모임·펀딩 / D 금융·장부 / E 소셜 / F 탐색·정책 / G 어드민)을 그대로 따릅니다.

---

## 4. 권장 빌드 순서 (마일스톤)

각 단계는 `openapi.yaml`의 해당 태그를 계약으로 삼고, 백엔드→앱 순으로 짝지어 진행합니다.

1. **M0 · 기반** — 모노레포, CI, MySQL 스키마(DDL), 공통 에러 포맷, JWT 인증 골격
2. **M1 · 계정** — 소셜 로그인(카카오) → KYC → 지갑 자동 개설 / 앱 온보딩·로그인
3. **M2 · 동아리** — 개설·멤버·역할(RBAC)·폼빌더 가입·승인 / 앱 탐색·클럽 상세
4. **M3 · 모임·차수** ⭐핵심 — 모임·차수(Round)·안심 예산안 / 앱 모임 상세
5. **M4 · 에스크로 예치·락·출금** ⭐핵심 — 차수 예치(포인트)·취소 환불·만남시각 락·총무 출금 / 앱 예치·결제 플로우
6. **M5 · 증빙·반납·자동정산** — 영수증 OCR·실지출·잔액 반납·1인당 균등 환급·현금화·패널티 / 앱 정산·지갑
7. **M6 · 소셜** — 쇼 피드·Showts(검수)·DM·알림 / 앱 소셜 탭
8. **M7 · 어드민** — 입금 대사·지급 승인·모더레이션·CS·푸시·리포트(웹)

> **권장**: 결제·정산은 **차수(Round)를 최소 거래 단위**로 구현. 한 모임에 여러 차수를 신청해도 결제는 1건(합산)이되, 차수별 Attendance·LedgerEntry로 분개되어 부분 취소·노쇼·부분 환불이 독립 처리됩니다.

---

## 5. Fidelity (시안 완성도)

- 앱 프로토타입(`design/prototype-app.html`)은 **하이파이(hi-fi)** 입니다 — 로그인 → **5탭(탐색·홈·Showts·DM·마이)** 풀 버전. 홈 탭 기본 화면은 쇼 피드입니다. 최종 색·타이포·간격·인터랙션이 반영되어 있어 **Flutter로 픽셀에 가깝게 재현**하세요. (브라우저로 바로 열리는 자체완결형 단일 파일)
- 어드민(`design/prototype-admin.html`)도 하이파이입니다(웹, 단일 파일).
- 와이어프레임(`design/spec/`)은 화면 정의·플로우용 **로파이** 참고 자료입니다.

디자인 토큰(색·타이포·간격·라운드·섀도·모션)은 **6절**과 `design/design-tokens.md`에 정확한 값으로 정리되어 있습니다. Flutter `ThemeData`로 1:1 매핑하세요.

---

## 6. 디자인 토큰 (Flutter ThemeData로 매핑)

### 컬러 — 브랜드
| 토큰 | HEX | 용도 |
|---|---|---|
| `primary` (모이쇼 블루) | `#3B5CFF` | 버튼·펀딩 게이지·핵심 링크 |
| `primary-hover` | `#2E47E6` | |
| `primary-press` | `#2438B8` | |
| `primary-soft` | `#EEF2FF` | 옅은 배경 |
| `accent` (네온 퍼플) | `#8C52FF` | 쇼 피드·이벤트·독촉 |
| `accent-soft` | `#F4EEFF` | |

### 컬러 — 시맨틱
| 토큰 | HEX | 용도 |
|---|---|---|
| `success` (민트) | `#00C781` | 입금 완료·정산 마감 |
| `success-soft` | `#E5FBF3` | |
| `danger` (코랄) | `#FF4B4B` | 미입금·마감 임박 |
| `danger-soft` | `#FFECEC` | |
| `warning` (앰버) | `#FFA722` | 마감 임박 보조 |

### 컬러 — 텍스트 / 표면 / 보더
| 토큰 | HEX |
|---|---|
| `text-strong` (금액/Display) | `#161A24` |
| `text-title` | `#272D3B` |
| `text-body` | `#3C4456` |
| `text-muted` | `#6E7689` |
| `surface-page` / `surface-card` | `#FFFFFF` |
| `surface-sunken` (수치 카드 배경) | `#F4F6FA` |
| `border-subtle` / `border-default` | `#EBEEF4` / `#DDE2EC` |

### 타이포그래피 — Pretendard
- 폰트: **Pretendard** (한국 핀테크 표준, 숫자 가독성↑). 금액·달성률엔 **tabular numerals**(`fontFeatures: [FontFeature.tabularFigures()]`).
- 스케일(px): Display-lg **34** / Display **28** / Heading **22** / Title **18** / Subtitle **16** / Body **14** / Caption **12** / Micro **11**
- 굵기: regular 400 / medium 500 / semibold 600 / bold 700
- 자간: Display `-0.02em`, Title `-0.01em`
- 행간: tight 1.2 / snug 1.35 / normal 1.5 / relaxed 1.65

### 간격 (4px 베이스)
`4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 · 64` — 화면 좌우 여백 `20`, 카드 내부 `20`, 리스트 간격 `12`.

### 라운드
mini **6** / sm **8** / md **12**(입력·버튼) / lg **16** / xl **20**(카드) / 2xl **24**(메인 보드) / pill **999** / full **50%**

### 섀도 (파란 기운이 도는 핀테크 깊이)
- `card`: `0 4px 20px rgba(59,92,255,.08)` (대시보드 카드 기본)
- `pop`: `0 16px 40px rgba(30,46,143,.16)` (모달·바텀시트)
- `glow-blue`: `0 6px 20px rgba(59,92,255,.35)` (CTA 강조)

### 모션 — "또로롱"(가볍게 통통)
- easing: standard `cubic-bezier(.2,0,.2,1)` / spring `cubic-bezier(.34,1.56,.64,1)` / out `cubic-bezier(.16,1,.3,1)`
- duration: fast **120ms** / base **200ms** / slow **320ms**

### 레이아웃
앱 캔버스 폭 **420px** 기준 디자인 · 탭바 높이 **64** · 헤더 높이 **56**

전체 원본 CSS는 `design/tokens/` 에 그대로 포함되어 있습니다.

---

## 7. 권한(RBAC) 요약

3계층 권한. 상세 매트릭스는 `docs/03_API_권한설계서.html`.

- **플랫폼**: `GUEST` → `MEMBER`(로그인) → `MEMBER·VERIFIED`(본인인증, 금융 기능) → `OPERATOR`
- **운영자 세부**: `op.super` · `op.finance` · `op.cs` · `op.content` · `op.ops`
- **동아리(리소스 스코프)**: `club.member`(부원) · `club.staff`(운영진) · `club.treasurer`(총무) · `club.leader`(회장) + `club.host`(모임 주최자)

핵심 규칙:
- **금융 행위**(납부·개설·정산·환불·연동)는 `verified` 필수 → 미인증 시 `403 KYC_REQUIRED`
- **정산 마감·지급(환불) 실행**은 `club.treasurer` 이상
- **동아리 정보 수정·역할 위임·해산**은 `club.leader`만

---

## 8. 머니플로우 핵심 (포인트 에스크로)

`docs/05_포인트에스크로정산모델.html` 의 5단계 + `openapi.yaml`을 그대로 구현하세요. **(이 절이 결제 정본 — 기존 `attendances`/`payments/kakao/ready·approve` 흐름은 폐기)**

1. **예치(OPEN)**: `POST /meetings/{id}/rounds/{rid}/deposit` — 보유 포인트 차감(부족분 카카오페이 충전). 만남 시각 전 `DELETE` 로 자유 취소 → 즉시 환불. 총무 출금 잠김.
2. **락(LOCKED)**: 만남 시각 도달 → `POST /meetings/{id}/lock`(스케줄러). 취소 차단 + 총무 출금 활성. 모임 단위 직렬화로 마감 경합 방지.
3. **총무 출금(WITHDRAWN)**: `POST /meetings/{id}/payout` — LOCKED + 락 스냅샷 전원 동의(CONSENT) 이후만. 본인 계좌로 현금화 + 정산 데드라인 타이머(기본 12h, FeePolicy 설정 가능) 시작.
4. **증빙·반납(SETTLING)**: `POST .../settlement/receipts`(영수증 OCR) → `POST .../settlement/return`(실지출+잔액 반납). 데드라인 초과 시 신용등급 패널티.
5. **자동 정산(DONE)**: `POST .../settlement/auto` — 반납금 ÷ 참여인원 균등 환급. 부원은 `POST /me/wallet/cashout` 으로 즉시 계좌 현금화.

> 충전·현금화·예치·출금·반납은 모두 `Idempotency-Key` 필수. 원장 불변식: 에스크로 잔액 = Σ deposit − Σ payout_treasurer + Σ return − Σ settle_refund (DONE 시 0). 회원 간 송금 API 금지(선불업 유예).

---

## 9. 의도적으로 백엔드 자율에 맡긴 것

- **신뢰/매너 점수 산식** — score·매너온도·등급 컷의 계산식과 갱신 트리거는 서버 내부 로직(요청에 따라 자율). API는 결과 필드만 노출.
- **실시간 인프라** — DM/푸시 전송(WebSocket·FCM)은 API 계약과 별도 인프라로 설계.

---

## 10. 파일 목록

> 🔗 각 파일은 배포된 [GitHub Pages](https://moishow.github.io/design/)에서 바로 열립니다.

- **README.md** ← 이 문서
- [**CLAUDE.md**](https://moishow.github.io/design/CLAUDE.md) ← Claude Code 프로젝트 규칙
- [**openapi.yaml**](https://moishow.github.io/design/openapi.yaml) ← API 계약 (OpenAPI 3.1)
- **docs/** ← 설계 문서 5종 (HTML)
  - [01_PRD.html](https://moishow.github.io/design/docs/01_PRD.html)
  - [02_데이터정의서.html](https://moishow.github.io/design/docs/02_%EB%8D%B0%EC%9D%B4%ED%84%B0%EC%A0%95%EC%9D%98%EC%84%9C.html)
  - [03_API_권한설계서.html](https://moishow.github.io/design/docs/03_API_%EA%B6%8C%ED%95%9C%EC%84%A4%EA%B3%84%EC%84%9C.html)
  - [04_API_상세명세서.html](https://moishow.github.io/design/docs/04_API_%EC%83%81%EC%84%B8%EB%AA%85%EC%84%B8%EC%84%9C.html)
  - [05_포인트에스크로정산모델.html](https://moishow.github.io/design/docs/05_%ED%8F%AC%EC%9D%B8%ED%8A%B8%EC%97%90%EC%8A%A4%ED%81%AC%EB%A1%9C%EC%A0%95%EC%82%B0%EB%AA%A8%EB%8D%B8.html) ⭐ 머니플로우 정본
- **design/**
  - [design-tokens.md](https://moishow.github.io/design/design/design-tokens.md) ← 토큰 요약(이 README 6절과 동일)
  - **tokens/** ← 원본 토큰 CSS ([base](https://moishow.github.io/design/design/tokens/base.css) · [colors](https://moishow.github.io/design/design/tokens/colors.css) · [typography](https://moishow.github.io/design/design/tokens/typography.css) · [spacing](https://moishow.github.io/design/design/tokens/spacing.css) · [fonts](https://moishow.github.io/design/design/tokens/fonts.css))
  - [prototype-app.html](https://moishow.github.io/design/design/prototype-app.html) ← 모바일 앱 풀 프로토타입 (로그인+5탭, 자체완결 단일 파일)
  - [prototype-admin.html](https://moishow.github.io/design/design/prototype-admin.html) ← 운영 어드민 풀 프로토타입 (자체완결 단일 파일)
  - **spec/** ← 화면 정의서 / 와이어프레임 ([Moisho Spec.html](https://moishow.github.io/design/design/spec/Moisho%20Spec.html))

---

## 11. Claude Code 시작 프롬프트 예시

> 새 레포에서 첫 세션을 열 때 아래처럼 지시하세요.

```
이 레포는 모이쇼 풀스택 프로젝트야. design_handoff_moisho/CLAUDE.md 를
먼저 읽고, 그 규칙을 루트 CLAUDE.md 로 복사해줘.
그다음 openapi.yaml 과 docs/02_데이터정의서.html 를 근거로
M0(기반) → M1(계정) 순서로 backend(Spring Boot/Kotlin)부터 시작하자.
MySQL DDL과 도메인 패키지 골격을 먼저 만들고 보여줘.
```
