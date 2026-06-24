// 세션 상태 — 앱의 단일 출처(verified·wallet·user). 모든 머니 게이트가 이 verified를 본다.
// Riverpod Notifier (riverpod 2.6). 백엔드 연동 시 메서드 본문을 dio 호출로 교체.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'fixtures.dart';
import 'models.dart';

enum SessionStatus { loggedOut, onboarding, authed }

/// 불변 세션 스냅샷. verified·needsOnboarding 는 user에서 파생.
class SessionState {
  final SessionUser? user;
  final Wallet? wallet;
  final SessionStatus status;
  const SessionState({this.user, this.wallet, this.status = SessionStatus.loggedOut});

  bool get verified => user?.verified ?? false;
  bool get needsOnboarding => user?.needsOnboarding ?? false;
  bool get hasWallet => wallet != null;

  SessionState copyWith({SessionUser? user, Wallet? wallet, SessionStatus? status}) =>
      SessionState(user: user ?? this.user, wallet: wallet ?? this.wallet, status: status ?? this.status);

  /// 정착 사용자(파워유저) — 기본 세션. /app 직접 진입 시 마이 탭 프로토타입 패리티.
  factory SessionState.powerUser() =>
      const SessionState(user: kPowerUser, wallet: kPowerWallet, status: SessionStatus.authed);
}

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() => SessionState.powerUser();

  /// 소셜 로그인 — provider별 stub 신규 유저로 세션 시작(미인증·온보딩 필요).
  void loginAs(String provider) {
    state = SessionState(user: oauthStubUser(provider), status: SessionStatus.onboarding);
  }

  /// 온보딩 완료 — 프로필 + 약관 이력 저장(`POST /auth/signup/profile`).
  /// verified 는 건드리지 않는다(KYC는 금융 행위 직전 just-in-time).
  void completeOnboarding({
    required String nickname,
    String? bio,
    required List<String> interests,
    required List<AgreementChoice> agreements,
  }) {
    final u = state.user;
    if (u == null) return;
    // agreements[] 는 서버 audit 기록 대상 — 백엔드 연동 시 요청 바디로 전송.
    state = state.copyWith(
      user: u.copyWith(nickname: nickname, bio: bio, interests: interests, needsOnboarding: false),
      status: SessionStatus.authed,
    );
  }

  /// 본인인증 — verified 부여 + 지갑 1회 개설(`POST /auth/kyc`).
  /// 멱등 안전동작: 이미 verified면 기존 지갑 반환(두 번째 지갑 생성 금지 — flow doc).
  Wallet verifyKyc({String method = 'telecom'}) {
    final u = state.user;
    if (u == null) {
      return state.wallet ?? const Wallet(id: 'w_guest', balance: 0, accountLabel: '포인트');
    }
    if (u.verified && state.wallet != null) return state.wallet!; // 멱등
    final w = Wallet(id: 'w_${u.id}', balance: 0, accountLabel: '${u.nickname ?? '내'} 포인트');
    state = state.copyWith(
      user: u.copyWith(verified: true, phone: '+821012345678'),
      wallet: w,
      status: SessionStatus.authed,
    );
    return w;
  }

  void signOut() => state = const SessionState(status: SessionStatus.loggedOut);
}

final sessionProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);
