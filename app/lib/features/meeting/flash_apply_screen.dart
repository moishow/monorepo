// 번개 참여 신청 — prototype FlashApplyScreen (87338638:663).
// 주최자 헤더(앰버→레드)·안전 금융 규칙·차수별 노쇼 예약금 선택·하단 실시간 송금 요약 + 카카오페이 예치.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../settlement/deposit_confirm_screen.dart';

// 카카오페이 브랜드 컬러 — 토큰 매핑 없음(서드파티 브랜드).
const _kakaoYellow = Color(0xFFFEE500); // proto #FEE500 카카오페이 brand
const _kakaoDark = Color(0xFF3C1E1E); // proto #3C1E1E 카카오페이 brand

class _FlashRound {
  final int id;
  final String label, title, time;
  final int cost;
  const _FlashRound(this.id, this.label, this.title, this.time, this.cost);
}

class FlashApplyScreen extends StatefulWidget {
  const FlashApplyScreen({super.key});

  @override
  State<FlashApplyScreen> createState() => _FlashApplyScreenState();
}

class _FlashApplyScreenState extends State<FlashApplyScreen> {
  static const int _depositPerRound = 5000;
  static const _rounds = [
    _FlashRound(1, '1차', '생활맥주 영통점', '19:00 ~', 25000),
    _FlashRound(2, '2차', '킹핀 락볼링장', '21:00 ~', 15000),
  ];

  final Map<int, bool> _checked = {1: true, 2: false};

  int get _selectedCount => _rounds.where((r) => _checked[r.id] == true).length;
  int get _total => _selectedCount * _depositPerRound;
  int get _restTotal =>
      _rounds.where((r) => _checked[r.id] == true).fold(0, (s, r) => s + r.cost);

  void _toggle(int id) => setState(() => _checked[id] = !(_checked[id] ?? false));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '번개 참여 신청', onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            physics: const BouncingScrollPhysics(),
            children: [
              _hostHeader(),
              const SizedBox(height: 20),
              _safetyBox(),
              const SizedBox(height: 20),
              const SectionLabel('차수 선택 (최대 2차)'),
              for (var i = 0; i < _rounds.length; i++) ...[
                _roundCard(_rounds[i]),
                if (i < _rounds.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        _bottomBar(),
      ]),
    );
  }

  // ── 주최자 헤더(앰버→레드 그라데이션) ──
  Widget _hostHeader() => Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [T.warning, T.danger], // proto #F59E0B → #EF4444
          ),
          borderRadius: BorderRadius.all(Radius.circular(T.r2xl)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(T.rPill),
                border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(LucideIcons.zap, size: 12, color: T.white),
                const SizedBox(width: 4),
                Text('개인 번개', style: tx(10, FontWeight.w700, T.white, height: 1)),
              ]),
            ),
            const SizedBox(width: 8),
            Opacity(
              opacity: 0.9,
              child: Text('이영희 님 주최', style: tx(11, FontWeight.w600, T.white, height: 1)),
            ),
          ]),
          const SizedBox(height: 10),
          Text('퇴근길 치맥 & 볼링 번개', style: tx(17, FontWeight.w700, T.white, ls: -0.02, height: 1.3)),
          const SizedBox(height: 12),
          Wrap(spacing: 7, runSpacing: 7, children: [
            _trustBadge(LucideIcons.shieldCheck, '본인 인증 완료'),
            _trustBadge(LucideIcons.thermometer, '매너온도 37.5℃'),
          ]),
        ]),
      );

  Widget _trustBadge(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(T.rPill),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: T.white),
          const SizedBox(width: 4),
          Text(label, style: tx(11, FontWeight.w600, T.white, height: 1)),
        ]),
      );

  // ── 안전 금융 규칙 박스 ──
  Widget _safetyBox() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: T.warningSoft, // proto #FFFDF0
          borderRadius: BorderRadius.circular(T.rLg),
          border: Border.all(color: T.amber100, width: 1.5), // proto #FDE68A
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(LucideIcons.triangleAlert, size: 16, color: T.amber600), // proto #D97706
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: tx(11, FontWeight.w500, T.amber600, height: 1.6), // proto #92400E
                children: const [
                  TextSpan(text: '모이쇼 안전 금융 규칙: ', style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(
                      text:
                          '개인 번개는 먹튀 방지를 위해 차수당 5,000원의 노쇼 예약금만 먼저 송금하며, 나머지 잔액은 모임 후 방장이 영수증을 올리면 후불 정산됩니다.'),
                ],
              ),
            ),
          ),
        ]),
      );

  // ── 차수 카드 ──
  Widget _roundCard(_FlashRound r) {
    final on = _checked[r.id] == true;
    return GestureDetector(
      onTap: () => _toggle(r.id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: on ? T.warningSoft : T.white, // proto on:#FFFDF5
          borderRadius: BorderRadius.circular(T.rXl),
          border: Border.all(color: on ? T.warning : T.borderDefault, width: 2), // proto on:#F59E0B
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // 체크박스
              Container(
                width: 22, height: 22,
                margin: const EdgeInsets.only(top: 1),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on ? T.warning : T.white, // proto on:#F59E0B
                  borderRadius: BorderRadius.circular(T.rMini),
                  border: Border.all(color: on ? T.warning : T.borderDefault, width: 2),
                ),
                child: on ? const Icon(LucideIcons.check, size: 14, color: T.white) : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${r.label}: ${r.title}', style: tx(15, FontWeight.w700, T.textStrong, height: 1.2)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(LucideIcons.clock, size: 12, color: T.textMuted),
                    const SizedBox(width: 5),
                    Text(r.time, style: tx(12, FontWeight.w500, T.textMuted, height: 1)),
                  ]),
                  const SizedBox(height: 12),
                ]),
              ),
            ]),
            // 비용 구조
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: T.gray50, borderRadius: BorderRadius.circular(T.rMd)),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('총 예상 비용', style: tx(12, FontWeight.w500, T.textMuted, height: 1)),
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(text: '약 ${won(r.cost)}원 ', style: tx(13, FontWeight.w600, T.textBody, height: 1, tab: true)),
                      TextSpan(text: '(현장 후정산)', style: tx(11, FontWeight.w500, T.textDisabled, height: 1)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 7),
                const Divider(height: 1, thickness: 1, color: T.borderSubtle),
                const SizedBox(height: 7),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    Icon(LucideIcons.star, size: 12, color: on ? T.warning : T.textDisabled), // proto on:#F59E0B
                    const SizedBox(width: 5),
                    Text('노쇼 예약금', style: tx(12, FontWeight.w600, on ? T.amber600 : T.textMuted, height: 1)), // proto on:#D97706
                  ]),
                  Text('${won(_depositPerRound)}원',
                      style: tx(14, FontWeight.w700, on ? T.amber600 : T.textMuted, height: 1, tab: true)), // proto on:#D97706
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ── 하단 고정 바(실시간 요약 + 카카오페이 예치) ──
  Widget _bottomBar() {
    final has = _selectedCount > 0;
    return StickyBar(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
          Flexible(
            child: Text(
              has ? '현재 송금액 ($_selectedCount개 차수 예약금)' : '참석할 차수를 선택해 주세요',
              style: tx(12, FontWeight.w500, T.textMuted, height: 1),
            ),
          ),
          if (has)
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: _total),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              builder: (_, value, _) =>
                  Text('${won(value)}원', style: tx(24, FontWeight.w700, T.textStrong, ls: -0.01, height: 1, tab: true)),
            ),
        ]),
        if (has) ...[
          const SizedBox(height: 4),
          Text('잔액 ${won(_restTotal)}원은 모임 후 현장 정산',
              style: tx(11, FontWeight.w500, T.textDisabled, height: 1, tab: true)),
        ],
        const SizedBox(height: 12),
        _kakaoButton(has),
      ]),
    );
  }

  Widget _kakaoButton(bool has) {
    final fg = has ? _kakaoDark : T.textMuted;
    return GestureDetector(
      onTap: has
          ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DepositConfirmScreen()))
          : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: has ? _kakaoYellow : T.gray100,
          borderRadius: BorderRadius.circular(T.rXl),
        ),
        alignment: Alignment.center,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _kakaoPayMark(has),
          const SizedBox(width: 10),
          Text(
            has ? '포인트로 예약금 ${won(_total)}원 예치하고 참석' : '차수를 선택해 주세요',
            style: tx(14, FontWeight.w700, fg, height: 1),
          ),
        ]),
      ),
    );
  }

  // 카카오페이 "Pay" 마크 — 노란 버튼 위 다크 원형 라벨(SVG 로고 대체).
  Widget _kakaoPayMark(bool has) {
    final dark = has ? _kakaoDark : T.gray400; // proto disabled:#9CA3AF
    return Container(
      width: 22, height: 22,
      decoration: BoxDecoration(color: dark, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text('P', style: tx(11, FontWeight.w900, _kakaoYellow, height: 1)),
    );
  }
}
