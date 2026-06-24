// 마이 탭 — prototype MyPageScreen (a6569647:173). 매너온도 히어로·지갑·신뢰지표·탭.
// 신원·지갑·verified 는 sessionProvider 에서 읽는다(단일 출처). 미인증이면 지갑 카드가 KYC 게이트.
// 매너/신뢰 수치는 아직 showcase 하드코딩 — 서버 산출 연동은 journey-06(§11) 다음 패스.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/data/session.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import '../auth/auth_dialogs.dart';

// 매너온도 → 히어로 배경 / 강조색
LinearGradient _mannerHero(double t) {
  final colors = t >= 38
      ? const [Color(0xFFFFE8D2), Color(0xFFFFD2A8)]
      : t >= 37
          ? const [Color(0xFFFEF3C7), Color(0xFFFDE8B0)]
          : t >= 36.5
              ? const [Color(0xFFFEF9E7), Color(0xFFFDF0C4)]
              : t >= 35
                  ? const [Color(0xFFEAF2FE), Color(0xFFD6E6FB)]
                  : const [Color(0xFFEBF0F6), Color(0xFFDCE6F0)];
  return LinearGradient(begin: const Alignment(-0.4, -1), end: const Alignment(0.4, 1), colors: colors);
}

Color _mannerAccent(double t) => t >= 38
    ? const Color(0xFFEA7B2C)
    : t >= 37
        ? const Color(0xFFE8A317)
        : t >= 36.5
            ? const Color(0xFFCDA434)
            : t >= 35
                ? const Color(0xFF5B8DEF)
                : const Color(0xFF7089A6);

class _Club {
  final String name, role, img;
  final int members;
  const _Club(this.name, this.role, this.members, this.img);
}

const _clubs = [
  _Club("홍대 연합 밴드 '사운드'", '부원', 18, 'https://images.unsplash.com/photo-1501612780327-45045538702b?w=88&h=88&fit=crop&auto=format&q=80'),
  _Club('책과 사람들 독서모임', '운영진', 9, 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=88&h=88&fit=crop&auto=format&q=80'),
  _Club('필름 사진 동호회', '부원', 24, 'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=88&h=88&fit=crop&auto=format&q=80'),
  _Club('주말 등산 크루', '부원', 31, 'https://images.unsplash.com/photo-1454496522488-7a8e488e8606?w=88&h=88&fit=crop&auto=format&q=80'),
  _Club('수요 풋살 모임', '운영진', 15, 'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=88&h=88&fit=crop&auto=format&q=80'),
];

const _feedImgs = [
  'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=200&h=200&fit=crop&auto=format&q=75',
  'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=200&h=200&fit=crop&auto=format&q=75',
  'https://images.unsplash.com/photo-1501612780327-45045538702b?w=200&h=200&fit=crop&auto=format&q=75',
  'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=200&h=200&fit=crop&auto=format&q=75',
  'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=200&h=200&fit=crop&auto=format&q=75',
  'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=200&h=200&fit=crop&auto=format&q=75',
];

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});
  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  String _tab = 'credit';
  bool _expanded = false;
  bool _clubsExpanded = false;

  static const _temp = 37.8; // 매너온도 showcase (서버 산출 연동은 journey-06)

  void _stub() => MoishoToast.show(context, '준비 중인 화면이에요', tone: 'info');

  // 미인증 → 지갑 개설(KYC 게이트). 성공 시 세션 flip 으로 카드가 리렌더.
  Future<void> _openWallet() async {
    await ensureVerified(context, ref, action: '포인트 지갑');
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sessionProvider);
    return Column(
      children: [
        const MoishoStatusBar(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _hero(s),
              _walletCard(s),
              _treasurerCard(s),
              // 매너·신뢰·동아리 showcase 는 verified 사용자에게만. 미인증은 빈 상태 + 게이트.
              if (s.verified) ...[
                _innerTabBar(),
                _tabContent(),
              ] else
                _unverifiedBody(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _hero(SessionState s) {
    final u = s.user;
    final name = u?.nickname ?? '게스트';
    final bio = u?.bio ?? '';
    final interests = u?.interests ?? const <String>[];
    final verified = s.verified;
    return Container(
      decoration: BoxDecoration(gradient: _mannerHero(_temp)),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Column(children: [
        // 프로필 수정 / 설정
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(
            onTap: _stub,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.62), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white.withValues(alpha: 0.7))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(LucideIcons.pencil, size: 14, color: T.textTitle),
                const SizedBox(width: 5),
                Text('프로필 수정', style: tx(12, FontWeight.w600, T.textTitle, height: 1)),
              ]),
            ),
          ),
          MinTapTarget(const Icon(LucideIcons.settings, size: 22, color: T.textMuted), onTap: _stub),
        ]),
        const SizedBox(height: 10),
        // 아바타 + 인증 배지(verified일 때만)
        Stack(clipBehavior: Clip.none, children: [
          Container(
            width: 92, height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.95), width: 3.5),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.16), blurRadius: 20, offset: const Offset(0, 6))],
            ),
            child: ClipOval(
              child: NetImage(
                url: u?.photo,
                width: 92, height: 92,
                fallback: Container(
                  color: T.gray100,
                  alignment: Alignment.center,
                  child: Text(name.characters.first, style: tx(34, FontWeight.w700, T.gray500)),
                ),
              ),
            ),
          ),
          if (verified)
            Positioned(
              right: 4, bottom: 4,
              child: Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: T.primary, shape: BoxShape.circle, border: Border.all(color: T.white, width: 2.5)),
                child: const Icon(LucideIcons.check, size: 11, color: T.white),
              ),
            ),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(name, style: tx(21, FontWeight.w700, T.textStrong, ls: -0.02, height: 1)),
          const SizedBox(width: 6),
          if (verified)
            const MBadge('본인인증', tone: 'primary')
          else
            const MBadge('미인증', tone: 'neutral'),
        ]),
        if (bio.isNotEmpty) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(bio, textAlign: TextAlign.center, style: tx(13, FontWeight.w500, T.textBody, height: 1.55)),
          ),
        ],
        if (interests.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: [
            for (final t in interests)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white.withValues(alpha: 0.6))),
                child: Text('#$t', style: tx(11, FontWeight.w600, T.primary, height: 1)),
              ),
          ]),
        ],
        // 팔로워 / 팔로잉 — verified 사용자에게만(미인증 신규 유저는 활동 이력 없음)
        if (verified) ...[
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(T.rLg), border: Border.all(color: Colors.white.withValues(alpha: 0.7))),
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(children: [
              _followCol('팔로워', 89),
              Container(width: 1, height: 26, color: Colors.black.withValues(alpha: 0.1)),
              _followCol('팔로잉', 34),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _followCol(String label, int v) => Expanded(
        child: GestureDetector(
          onTap: _stub,
          behavior: HitTestBehavior.opaque,
          child: Column(children: [
            Text('$v', style: tx(17, FontWeight.w700, T.textStrong, height: 1, tab: true)),
            const SizedBox(height: 3),
            Text(label, style: tx(11, FontWeight.w500, T.textMuted, height: 1)),
          ]),
        ),
      );

  // verified + 지갑 보유 → 잔액 카드 / 미인증 → 본인인증 게이트 CTA
  Widget _walletCard(SessionState s) {
    if (s.verified && s.wallet != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
        child: GestureDetector(
          onTap: _stub,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(gradient: T.gradWallet, borderRadius: BorderRadius.circular(T.rXl), boxShadow: [BoxShadow(color: const Color(0xFF3D7DFA).withValues(alpha: 0.28), blurRadius: 18, offset: const Offset(0, 6))]),
            child: Row(children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(T.rMd)), child: const Icon(LucideIcons.wallet, size: 20, color: T.white)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('내 포인트 지갑', style: tx(11.5, FontWeight.w500, Colors.white.withValues(alpha: 0.85), height: 1)),
                  const SizedBox(height: 5),
                  Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                    Text(won(s.wallet!.balance), style: tx(20, FontWeight.w700, T.white, height: 1, tab: true)),
                    Text('P', style: tx(13, FontWeight.w700, Colors.white.withValues(alpha: 0.85), height: 1)),
                  ]),
                ]),
              ),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text('충전·현금화', style: tx(12, FontWeight.w600, Colors.white.withValues(alpha: 0.9), height: 1)),
                const Icon(LucideIcons.chevronRight, size: 16, color: T.white),
              ]),
            ]),
          ),
        ),
      );
    }
    // 미인증 — 본인인증 게이트 CTA
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
      child: GestureDetector(
        onTap: _openWallet,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: T.primarySoft,
            borderRadius: BorderRadius.circular(T.rXl),
            border: Border.all(color: T.primary.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Row(children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: T.primary, borderRadius: BorderRadius.circular(T.rMd)), child: const Icon(LucideIcons.shieldCheck, size: 20, color: T.white)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('본인인증하고 회비 지갑 만들기', style: tx(14, FontWeight.w700, T.textStrong, height: 1.2)),
                const SizedBox(height: 4),
                Text('인증 한 번이면 충전·예치·정산을 시작해요', style: tx(11.5, FontWeight.w500, T.primary, height: 1.2)),
              ]),
            ),
            const Icon(LucideIcons.chevronRight, size: 18, color: T.primary),
          ]),
        ),
      ),
    );
  }

  // 총무 정산 관리 — verified 사용자에게만(총무는 인증 필수)
  Widget _treasurerCard(SessionState s) {
    if (!s.verified) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
      child: GestureDetector(
        onTap: _stub,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(color: T.white, borderRadius: BorderRadius.circular(T.rXl), border: Border.all(color: T.borderDefault, width: 1.5)),
          child: Row(children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(T.rMd)), child: const Icon(LucideIcons.shieldCheck, size: 20, color: T.primary)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('총무 정산 관리', style: tx(14, FontWeight.w700, T.textStrong, height: 1)),
                  const SizedBox(width: 6),
                  const MBadge('총무', tone: 'primary'),
                ]),
                const SizedBox(height: 4),
                Text('입금 현황 · 자금 출금 · 영수증 OCR · 잔액 반납 정산', style: tx(11.5, FontWeight.w500, T.textMuted, height: 1.3)),
              ]),
            ),
            const Icon(LucideIcons.chevronRight, size: 18, color: T.textMuted),
          ]),
        ),
      ),
    );
  }

  // 미인증 유저 빈 상태 — 매너/신뢰/동아리는 첫 회비 모임부터 쌓인다는 안내 + 게이트.
  Widget _unverifiedBody() => Container(
        width: double.infinity,
        color: T.gray50,
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.fromLTRB(28, 44, 28, 64),
        child: Column(children: [
          Container(
            width: 66, height: 66,
            decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(T.rXl)),
            child: const Icon(LucideIcons.sprout, size: 30, color: T.primary),
          ),
          const SizedBox(height: 18),
          Text('본인인증하고 활동을 시작해보세요', textAlign: TextAlign.center, style: tx(16, FontWeight.w700, T.textStrong)),
          const SizedBox(height: 8),
          Text('매너온도·정산 신뢰·내 동아리는\n첫 회비 모임부터 차곡차곡 쌓여요',
              textAlign: TextAlign.center, style: tx(13, FontWeight.w500, T.textMuted, height: 1.6)),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: _openWallet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
              decoration: BoxDecoration(color: T.primary, borderRadius: BorderRadius.circular(T.rMd), boxShadow: T.glowBlue),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(LucideIcons.shieldCheck, size: 17, color: T.white),
                const SizedBox(width: 7),
                Text('본인인증 시작하기', style: tx(14.5, FontWeight.w700, T.white)),
              ]),
            ),
          ),
        ]),
      );

  Widget _innerTabBar() => Container(
        margin: const EdgeInsets.only(top: 14),
        decoration: const BoxDecoration(color: T.white, border: Border(bottom: BorderSide(color: T.borderSubtle))),
        child: Row(children: [
          _innerTab('credit', LucideIcons.barChart, '활동·매너'),
          _innerTab('feed', LucideIcons.grid3x3, '모임피드'),
          _innerTab('clubs', LucideIcons.building, '내 동아리'),
        ]),
      );

  Widget _innerTab(String id, IconData icon, String label) {
    final on = _tab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = id),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 44,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: on ? T.primary : Colors.transparent, width: 2.5))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 15, color: on ? T.primary : T.textMuted),
            const SizedBox(width: 5),
            Text(label, style: tx(12, on ? FontWeight.w700 : FontWeight.w500, on ? T.primary : T.textMuted, height: 1)),
          ]),
        ),
      ),
    );
  }

  Widget _tabContent() {
    switch (_tab) {
      case 'feed':
        return _feedGrid();
      case 'clubs':
        return _clubsTab();
      default:
        return _creditTab();
    }
  }

  // ── 활동·매너 ──
  Widget _creditTab() {
    final accent = _mannerAccent(_temp);
    return Container(
      color: T.gray50,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 매너지표 헤더
        Row(children: [
          const Icon(LucideIcons.thermometer, size: 15, color: T.warning),
          const SizedBox(width: 6),
          Text('매너지표', style: tx(13, FontWeight.w700, T.textTitle, height: 1)),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(color: T.white, borderRadius: BorderRadius.circular(T.rXl)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('매너온도', style: tx(11, FontWeight.w500, T.textMuted, height: 1)),
            const SizedBox(height: 5),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text('$_temp℃', style: tx(28, FontWeight.w700, accent, ls: -0.02, height: 1, tab: true)),
              const SizedBox(width: 6),
              const Icon(LucideIcons.smile, size: 13, color: T.success),
              const SizedBox(width: 3),
              Text('좋아요', style: tx(11, FontWeight.w700, T.success, height: 1)),
            ]),
            const SizedBox(height: 12),
            // 온도 바
            LayoutBuilder(builder: (_, c) {
              final knobX = (math.min(_temp / 99, 1.0)) * c.maxWidth;
              return SizedBox(
                height: 16,
                child: Stack(clipBehavior: Clip.none, children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(height: 8, decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), gradient: const LinearGradient(colors: [Color(0xFF93C5FD), Color(0xFFFDE68A), Color(0xFFFB923C)]))),
                  ),
                  Positioned(
                    left: knobX - 8,
                    top: 0,
                    child: Container(width: 16, height: 16, decoration: BoxDecoration(color: T.white, shape: BoxShape.circle, border: Border.all(color: accent, width: 3), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 1))])),
                  ),
                ]),
              );
            }),
            const SizedBox(height: 18),
            // 2x2 매너 항목
            Row(children: [
              Expanded(child: _mannerItem(LucideIcons.thumbsUp, '받은 칭찬', '24개', T.primary)),
              const SizedBox(width: 10),
              Expanded(child: _mannerItem(LucideIcons.clock, '정시 참석률', '96%', T.success)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _mannerItem(LucideIcons.userX, '노쇼', '없음', T.success)),
              const SizedBox(width: 10),
              Expanded(child: _mannerItem(LucideIcons.messageCircle, '응답률', '92%', T.accent)),
            ]),
          ]),
        ),
        const SizedBox(height: 22),
        // 정산 신뢰 지표
        Row(children: [
          const Icon(LucideIcons.shieldCheck, size: 14, color: T.primary),
          const SizedBox(width: 6),
          Text('정산 신뢰 지표', style: tx(13, FontWeight.w700, T.textTitle, height: 1)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(999)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 5, height: 5, decoration: const BoxDecoration(color: T.primary, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text('모이쇼 인증', style: tx(10, FontWeight.w700, T.primary, height: 1)),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // 영수증 업로드 아크
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(color: T.white, borderRadius: BorderRadius.circular(T.rXl)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                _ArcProgress(pct: 95),
                SizedBox(height: 5),
                _ArcLabel(),
              ]),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(children: [
                Expanded(child: _statCard(LucideIcons.zap, '번개 참여', '23회', T.primary)),
                const SizedBox(width: 7),
                Expanded(child: _statCard(LucideIcons.star, '번개 주최', '5회', T.accent)),
                const SizedBox(width: 7),
                Expanded(child: _statCard(LucideIcons.clock, '정산 지연', '없음', T.success)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        // 정산 지연 0회 배너
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: T.successSoft, borderRadius: BorderRadius.circular(T.rLg), border: Border.all(color: T.mint100)),
          child: Row(children: [
            const Icon(LucideIcons.trophy, size: 15, color: T.successStrong),
            const SizedBox(width: 8),
            Flexible(child: RichText(text: TextSpan(children: [
              TextSpan(text: '정산 지연 0회 달성!', style: tx(12, FontWeight.w700, T.successStrong, height: 1.3)),
              TextSpan(text: '  모든 정산을 기한 내 완료했어요', style: tx(11, FontWeight.w500, T.success, height: 1.3)),
            ]))),
          ]),
        ),
        const SizedBox(height: 14),
        // 최근 정산 내역 (접기/펼치기)
        Container(
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: T.borderSubtle))),
          child: Column(children: [
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(children: [
                  Text('최근 정산 내역', style: tx(13, FontWeight.w600, T.textTitle, height: 1)),
                  const Spacer(),
                  Text('3건', style: tx(11, FontWeight.w500, T.textMuted, height: 1)),
                  const SizedBox(width: 4),
                  Icon(_expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 14, color: T.textMuted),
                ]),
              ),
            ),
            if (_expanded)
              Column(children: [
                _settlementRow('06/15', '정기 대관 연습', '인당 40,000원'),
                _settlementRow('05/20', '5월 정기 엠티', '인당 82,000원'),
                _settlementRow('05/11', '5월 독서 모임', '인당 0원'),
                const SizedBox(height: 10),
              ]),
          ]),
        ),
      ]),
    );
  }

  Widget _mannerItem(IconData icon, String label, String val, Color col) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: T.gray50, borderRadius: BorderRadius.circular(T.rLg)),
        child: Row(children: [
          Container(width: 30, height: 30, decoration: const BoxDecoration(color: T.white, shape: BoxShape.circle), child: Icon(icon, size: 15, color: col)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(val, style: tx(15, FontWeight.w700, col, height: 1, tab: true)),
              const SizedBox(height: 4),
              Text(label, style: tx(10, FontWeight.w500, T.textMuted, height: 1.2)),
            ]),
          ),
        ]),
      );

  Widget _statCard(IconData icon, String label, String val, Color col) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(color: T.white, borderRadius: BorderRadius.circular(T.rLg)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 13, color: col),
          const SizedBox(height: 5),
          Text(val, style: tx(14, FontWeight.w700, col, height: 1, tab: true)),
          const SizedBox(height: 5),
          Text(label, style: tx(9, FontWeight.w500, T.textDisabled, height: 1.3)),
        ]),
      );

  Widget _settlementRow(String date, String title, String amount) => Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: T.white, borderRadius: BorderRadius.circular(T.rLg), border: Border.all(color: T.borderSubtle)),
        child: Row(children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(color: T.mint100, borderRadius: BorderRadius.circular(T.rMd)), child: const Icon(LucideIcons.check, size: 13, color: T.success)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(12, FontWeight.w600, T.textTitle, height: 1.2)),
              const SizedBox(height: 3),
              Text('$date · $amount', style: tx(10, FontWeight.w500, T.textMuted, height: 1)),
            ]),
          ),
          const MBadge('정상', tone: 'success'),
        ]),
      );

  // ── 내 동아리 ──
  Widget _clubsTab() {
    final shown = _clubsExpanded ? _clubs : _clubs.take(3).toList();
    return Container(
      color: T.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(children: [
        for (final club in shown)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MCard(
              radius: T.rXl,
              padding: const EdgeInsets.all(14),
              onTap: _stub,
              child: Row(children: [
                ClipRRect(borderRadius: BorderRadius.circular(T.rMd), child: NetImage(url: club.img, width: 48, height: 48, fallback: Container(width: 48, height: 48, color: T.gray100))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(club.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(14, FontWeight.w600, T.textTitle, height: 1.2)),
                    const SizedBox(height: 5),
                    Row(children: [
                      MBadge(club.role, tone: club.role == '운영진' ? 'primary' : 'neutral'),
                      const SizedBox(width: 6),
                      Text('멤버 ${club.members}명', style: tx(12, FontWeight.w500, T.textMuted, height: 1)),
                    ]),
                  ]),
                ),
                const Icon(LucideIcons.chevronRight, size: 17, color: T.textDisabled),
              ]),
            ),
          ),
        if (_clubs.length > 3)
          GestureDetector(
            onTap: () => setState(() => _clubsExpanded = !_clubsExpanded),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(_clubsExpanded ? '간단히 보기' : '전체보기 (${_clubs.length})', style: tx(13, FontWeight.w600, T.textMuted, height: 1)),
                const SizedBox(width: 5),
                Icon(_clubsExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 15, color: T.textMuted),
              ]),
            ),
          ),
        GestureDetector(
          onTap: _stub,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(T.rLg), border: Border.all(color: T.primary, width: 1.5)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(LucideIcons.plus, size: 16, color: T.primary),
              const SizedBox(width: 8),
              Text('동아리 개설', style: tx(14, FontWeight.w700, T.primary, height: 1)),
            ]),
          ),
        ),
      ]),
    );
  }

  // ── 모임피드 ──
  Widget _feedGrid() => Container(
        color: T.white,
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final img in _feedImgs)
              GestureDetector(onTap: _stub, child: NetImage(url: img, fallback: Container(color: T.gray100))),
          ],
        ),
      );
}

// 영수증 업로드 3/4 아크 게이지
class _ArcProgress extends StatelessWidget {
  final int pct;
  const _ArcProgress({required this.pct});
  @override
  Widget build(BuildContext context) {
    final col = pct >= 90 ? T.success : pct >= 75 ? T.warning : T.danger;
    return SizedBox(
      width: 88, height: 88,
      child: Stack(alignment: Alignment.center, children: [
        CustomPaint(size: const Size(88, 88), painter: _ArcPainter(pct / 100, col)),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('$pct%', style: tx(17, FontWeight.w700, col, height: 1, tab: true)),
          const SizedBox(height: 2),
          Text('준수율', style: tx(9, FontWeight.w500, T.textMuted, height: 1)),
        ]),
      ]),
    );
  }
}

class _ArcLabel extends StatelessWidget {
  const _ArcLabel();
  @override
  Widget build(BuildContext context) => Text('영수증 업로드', style: tx(10, FontWeight.w600, T.textMuted, height: 1));
}

class _ArcPainter extends CustomPainter {
  final double fraction;
  final Color color;
  _ArcPainter(this.fraction, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    const sw = 8.0;
    final r = (size.width - sw) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    const start = math.pi * 0.75; // 135deg
    const sweepTotal = math.pi * 1.5; // 270deg (3/4)
    final track = Paint()
      ..color = T.gray100
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(center: center, radius: r);
    canvas.drawArc(rect, start, sweepTotal, false, track);
    canvas.drawArc(rect, start, sweepTotal * fraction.clamp(0, 1), false, fill);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.fraction != fraction || old.color != color;
}
