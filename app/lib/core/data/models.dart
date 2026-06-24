// 도메인 모델 — 백엔드 계약(openapi.yaml)의 핵심 엔티티를 불변 Dart 클래스로.
// 금액은 정수(원/포인트) — CLAUDE.md §4. 부동소수점 금지. JSON은 boundary에서만.
//
// 이 턴에서 다루는 가입·KYC·verified 게이트 저니에 필요한 모델만 정의한다(YAGNI).
// 동아리·모임·정산 모델은 해당 저니 구현 시 추가.

/// 세션 사용자 — `/auth/oauth/{provider}` · `/auth/signup/profile` · `/auth/kyc` 응답의 user.
class SessionUser {
  final String id;
  final String? nickname; // OAuth 직후 null → 온보딩에서 채움
  final String email;
  final String? phone; // 본인인증 후 E.164 (입금자 매칭 키)
  final String? photo;
  final String? bio;
  final List<String> interests; // 해시 없는 토큰 ('밴드'), 표시 시 # 부착
  final bool verified; // KYC 통과 여부 — 머니 게이트의 단일 기준
  final String provider; // kakao | apple | google
  final bool needsOnboarding; // 재로그인 반복 방지 (verified ⟂ needsOnboarding)

  const SessionUser({
    required this.id,
    this.nickname,
    required this.email,
    this.phone,
    this.photo,
    this.bio,
    this.interests = const [],
    this.verified = false,
    required this.provider,
    this.needsOnboarding = true,
  });

  SessionUser copyWith({
    String? nickname,
    String? phone,
    String? photo,
    String? bio,
    List<String>? interests,
    bool? verified,
    bool? needsOnboarding,
  }) =>
      SessionUser(
        id: id,
        nickname: nickname ?? this.nickname,
        email: email,
        phone: phone ?? this.phone,
        photo: photo ?? this.photo,
        bio: bio ?? this.bio,
        interests: interests ?? this.interests,
        verified: verified ?? this.verified,
        provider: provider,
        needsOnboarding: needsOnboarding ?? this.needsOnboarding,
      );

  factory SessionUser.fromJson(Map<String, dynamic> j) => SessionUser(
        id: j['id'] as String,
        nickname: j['nickname'] as String?,
        email: j['email'] as String? ?? '',
        phone: j['phone'] as String?,
        photo: j['photo'] as String?,
        bio: j['bio'] as String?,
        interests: (j['interests'] as List?)?.cast<String>().map(_stripHash).toList() ?? const [],
        verified: j['verified'] as bool? ?? false,
        provider: j['provider'] as String? ?? 'kakao',
        needsOnboarding: j['needsOnboarding'] as bool? ?? false,
      );

  static String _stripHash(String s) => s.startsWith('#') ? s.substring(1) : s;
}

/// 포인트 지갑 — User 1:1. KYC 통과 시 1회 개설(중복 생성 금지).
class Wallet {
  final String id;
  final int balance; // 정수 포인트(원)
  final String currency;
  final String accountLabel;

  const Wallet({required this.id, required this.balance, this.currency = 'KRW', required this.accountLabel});

  factory Wallet.fromJson(Map<String, dynamic> j) => Wallet(
        id: j['id'] as String,
        balance: (j['balance'] as num).toInt(),
        currency: j['currency'] as String? ?? 'KRW',
        accountLabel: j['accountLabel'] as String? ?? '포인트',
      );
}

/// 약관 문서 — code·version·required로 동의 이력의 컴플라이언스 증빙(선불업 유예 전제).
class LegalDoc {
  final String code; // tos | privacy | efin_transaction | marketing
  final String title;
  final String version;
  final bool required;
  final String summary; // 1줄 요약(체크박스 라벨)
  final String body; // [보기] 본문

  const LegalDoc({
    required this.code,
    required this.title,
    required this.version,
    required this.required,
    required this.summary,
    required this.body,
  });
}

/// 약관 동의 선택 — `POST /auth/signup/profile` 의 agreements[] 요소.
class AgreementChoice {
  final String code;
  final String version;
  final bool agreed;
  const AgreementChoice({required this.code, required this.version, required this.agreed});

  Map<String, dynamic> toJson() => {'code': code, 'version': version, 'agreed': agreed};
}

/// 신뢰 프로필 — 서버 산출값(§11: 산식 클라 노출/하드코딩 금지). 여기선 seed 값만 fixture.
class TrustProfile {
  final int score;
  final String grade; // seed | sprout | ...
  final double temp; // 매너온도
  final int praises, punctualRate, noshow, responseRate;
  final int receiptRate, hosted, joined, delays;

  const TrustProfile({
    required this.score,
    required this.grade,
    required this.temp,
    this.praises = 0,
    this.punctualRate = 0,
    this.noshow = 0,
    this.responseRate = 0,
    this.receiptRate = 0,
    this.hosted = 0,
    this.joined = 0,
    this.delays = 0,
  });
}
