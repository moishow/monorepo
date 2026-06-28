// 샘플 데이터 fixtures — docs/flow-review/sample-data/* 의 JSON을 Dart 상수로.
// 백엔드 미구현 동안 화면을 렌더하는 단일 출처. 백엔드 연동 시 이 파일만 dio 호출로 교체.
// 출처: sample-data/01-auth-kyc.md (가입·KYC), prototype MyPageScreen(파워유저 페르소나).
import 'models.dart';

// ── 관심사 서버 어휘 (자유 추가형) — 온보딩 하드코딩 8개 대체 ──
// data/02 "interests: #밴드 #독서 (자유 추가형)". 표시 시 # 부착, 저장은 bare 토큰.
const kInterestVocab = <String>[
  '밴드', '독서', '사진', '영화', '등산', '요리', '게임', '여행',
  '풋살', '러닝', '와인', '카페', '전시', '보드게임', '클라이밍', '캠핑',
];

// ── 약관 카탈로그 — sample-data legalAgreements[] (code·version·required) ──
// 필수 3종(이용약관·개인정보·전자금융거래) + 선택(마케팅). 동의 이력은 audit 증빙.
const kLegalDocs = <LegalDoc>[
  LegalDoc(
    code: 'tos',
    title: '서비스 이용약관',
    version: '2026-05-01',
    required: true,
    summary: '[필수] 모이쇼 서비스 이용약관',
    body: '제1조(목적) 본 약관은 모이쇼(이하 "회사")가 제공하는 동아리·소모임 회비 관리 '
        '서비스의 이용 조건 및 절차를 규정합니다.\n\n'
        '제2조(서비스) 회사는 회비 모금, 예산 편성, 투명한 정산을 위한 포인트 기반 '
        '에스크로 기능을 제공합니다. 포인트는 모임 정산 목적으로만 사용되며, 충전·현금화 '
        '수수료는 부과되지 않습니다.\n\n'
        '제3조(회원의 의무) 회원은 본인의 계정 정보를 안전하게 관리할 책임이 있습니다.',
  ),
  LegalDoc(
    code: 'privacy',
    title: '개인정보 수집·이용 동의',
    version: '2026-05-01',
    required: true,
    summary: '[필수] 개인정보 수집 및 이용 동의',
    body: '회사는 서비스 제공을 위해 다음의 개인정보를 수집합니다.\n\n'
        '· 수집 항목: 닉네임, 이메일, 휴대폰 번호(본인인증 시), 프로필 사진\n'
        '· 이용 목적: 회원 식별, 본인인증, 입금자 매칭, 정산 처리\n'
        '· 보유 기간: 회원 탈퇴 시까지 (관련 법령에 따른 거래 기록은 5년 보관)\n\n'
        '동의를 거부할 권리가 있으나, 필수 항목 미동의 시 서비스 이용이 제한됩니다.',
  ),
  LegalDoc(
    code: 'efin_transaction',
    title: '전자금융거래 이용약관',
    version: '2026-05-01',
    required: true,
    summary: '[필수] 전자금융거래 이용약관 (포인트·정산)',
    body: '본 약관은 포인트 충전·예치·정산·현금화 등 전자금융거래의 권리·의무를 정합니다.\n\n'
        '· 포인트는 1포인트 = 1원으로, 모임 회비 정산 목적으로만 사용됩니다.\n'
        '· 예치 자금은 신청 마감 24시간 전까진 전액, 이후엔 남은 시간에 따른 위약금을 제외하고 환불됩니다(위약금은 그룹 공동비용에 충당).\n'
        '· 회사는 거래 내역을 원장(Ledger)에 기록하며, 기록은 정정 분개로만 수정됩니다.\n'
        '· 본인인증을 완료한 회원만 충전·예치·현금화를 이용할 수 있습니다.',
  ),
  LegalDoc(
    code: 'marketing',
    title: '마케팅 정보 수신',
    version: '2026-05-01',
    required: false,
    summary: '[선택] 이벤트·혜택 알림 수신 동의',
    body: '신규 기능, 이벤트, 혜택 정보를 앱 푸시 및 이메일로 받아보실 수 있습니다.\n\n'
        '· 선택 항목으로, 미동의 시에도 서비스 이용에 제한이 없습니다.\n'
        '· 거래·정산·보안 등 필수 안내는 본 동의와 무관하게 항상 발송됩니다.\n'
        '· 설정 > 알림에서 언제든지 수신을 변경할 수 있습니다.',
  ),
];

/// 신규 가입자 신뢰 프로필 seed — sample-data trustProfile_seed.
const kSeedTrust = TrustProfile(score: 0, grade: 'seed', temp: 36.5);

/// OAuth 직후 신규 유저 stub — sample-data authToken_afterOAuth_newUser.user.
/// nickname/bio/interests 비어있고 verified=false, needsOnboarding=true.
SessionUser oauthStubUser(String provider) {
  const emails = {'kakao': 'hong@kakao.com', 'apple': 'hong@privaterelay.appleid.com', 'google': 'hong@gmail.com'};
  return SessionUser(
    id: 'u_8fK2pQ',
    nickname: null,
    email: emails[provider] ?? 'hong@moisho.app',
    photo: null, // 신규 유저는 이니셜 폴백 (cdn 사진은 실 OAuth 시)
    bio: null,
    interests: const [],
    verified: false,
    provider: provider,
    needsOnboarding: true,
  );
}

// ── 파워유저 페르소나 — prototype MyPageScreen 의 정착 사용자(인라인 하드코딩 추출) ──
// 기본 세션 = 이 유저. /app 직접 진입 시 마이 탭이 프로토타입과 동일하게 렌더.
const _powerFace = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=160&h=160&fit=crop&crop=face&auto=format&q=80';

const kPowerUser = SessionUser(
  id: 'u_hong',
  nickname: '홍길동',
  email: 'hong@kakao.com',
  phone: '+821012345678',
  photo: _powerFace,
  bio: '밴드에서 베이스 치고, 주말엔 필름 카메라 들고 다녀요. 정산은 늘 칼같이 🙌',
  interests: ['밴드', '독서', '사진', '필름카메라', '와인'],
  verified: true,
  provider: 'kakao',
  needsOnboarding: false,
);

const kPowerWallet = Wallet(id: 'w_hong', balance: 128400, accountLabel: '홍길동의 포인트');
