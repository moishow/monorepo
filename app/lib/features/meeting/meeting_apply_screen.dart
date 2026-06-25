// 참가 신청(예치) — prototype MeetingApplyScreen (87338638:480).
// 모임 마스터 배너 · 차수별 선택 카드(체크박스·상태·인원바) · 안내 · 하단 정산 바(카카오페이 예치).
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../social/public_profile_screen.dart';
import '../settlement/deposit_confirm_screen.dart';

class _RoundCfg {
  final int id;
  final String label, title, time, place, status;
  final int cost, cur, max;
  final int? min;
  const _RoundCfg(this.id, this.label, this.title, this.time, this.place,
      this.cost, this.cur, this.min, this.max, this.status);
}

class _StatusCfg {
  final Color dot, bg, color;
  final String label;
  const _StatusCfg(this.dot, this.bg, this.color, this.label);
}

class MeetingApplyScreen extends StatefulWidget {
  const MeetingApplyScreen({super.key});

  @override
  State<MeetingApplyScreen> createState() => _MeetingApplyScreenState();
}

class _MeetingApplyScreenState extends State<MeetingApplyScreen> {
  // ── 차수 데이터(프로토타입 ROUNDS 리터럴) ──
  static const _rounds = [
    _RoundCfg(1, '1차', '삼겹살 뿌시기', '18:00 ~ 20:00', '하남돼지집 영통점', 25000, 8, 5, 15, 'recruiting'),
    _RoundCfg(2, '2차', '락볼링장 내기', '20:15 ~ 22:00', '킹핀 락볼링장', 15000, 9, null, 10, 'closing'),
    _RoundCfg(3, '3차', '간단하게 맥주', '22:15 ~ ', '역전할머니맥주 영통역점', 10000, 12, null, 12, 'full'),
  ];

  // 상태 → 색/라벨. recruiting=success · closing=warning · full=danger.
  static const _statusCfg = {
    'recruiting': _StatusCfg(T.success, T.successSoft, T.success, '모집 중'),
    'closing': _StatusCfg(T.warning, T.warningSoft, T.amber600, '마감 임박'),
    'full': _StatusCfg(T.danger, T.dangerSoft, T.danger, '인원 초과'),
  };

  // 기본: 1차만 선택.
  final Map<int, bool> _checked = {1: true, 2: false, 3: false};

  // 첫 마운트 시 1차(25000)에서 카운트업 방지용 시작값.
  static const int _initialTotal = 25000;

  int get _total => _rounds
      .where((r) => (_checked[r.id] ?? false) && r.status != 'full')
      .fold(0, (s, r) => s + r.cost);

  List<String> get _selectedLabels => _rounds
      .where((r) => (_checked[r.id] ?? false) && r.status != 'full')
      .map((r) => r.label)
      .toList();

  void _toggle(int id) {
    final r = _rounds.firstWhere((x) => x.id == id);
    if (r.status == 'full') return;
    setState(() => _checked[id] = !(_checked[id] ?? false));
  }

  void _openProfile(String name) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PublicProfileScreen(name: name)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '모임 신청', onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 20, T.padScreen, 24),
            physics: const BouncingScrollPhysics(),
            children: [
              _master(),
              const SizedBox(height: 24),
              const SectionLabel('차수 선택'),
              for (var i = 0; i < _rounds.length; i++) ...[
                _roundCard(_rounds[i]),
                if (i < _rounds.length - 1) const SizedBox(height: 12),
              ],
              const SizedBox(height: 16),
              _infoHint(),
            ],
          ),
        ),
        _bottomBar(),
      ]),
    );
  }

  // ── 모임 마스터 배너 ──
  Widget _master() => Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          gradient: T.gradWallet,
          borderRadius: BorderRadius.circular(T.r2xl),
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
              child: Text('👥 동아리', style: tx(10, FontWeight.w700, T.white, height: 1)),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text("홍대 연합 밴드 '사운드'",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tx(11, FontWeight.w600, Colors.white.withValues(alpha: 0.85), height: 1)),
            ),
          ]),
          const SizedBox(height: 8),
          Text('정기 공연 뒷풀이', style: tx(17, FontWeight.w700, T.white, ls: -0.02, height: 1.3)),
          const SizedBox(height: 10),
          Row(children: [
            Icon(LucideIcons.calendar, size: 13, color: Colors.white.withValues(alpha: 0.85)),
            const SizedBox(width: 6),
            Text('2026년 6월 13일 (토) 18:00',
                style: tx(12, FontWeight.w500, Colors.white.withValues(alpha: 0.85), height: 1)),
          ]),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => _openProfile('홍길동'),
            behavior: HitTestBehavior.opaque,
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(LucideIcons.user, size: 13, color: Colors.white.withValues(alpha: 0.85)),
                  const SizedBox(width: 6),
                  Text('주최자: 홍길동 회장',
                      style: tx(12, FontWeight.w500, Colors.white.withValues(alpha: 0.85), height: 1)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(T.rPill),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Text('⭐ 우수 · 🌡️ 37.8℃', style: tx(10, FontWeight.w700, T.white, height: 1)),
                ),
              ],
            ),
          ),
        ]),
      );

  // ── 차수 선택 카드 ──
  Widget _roundCard(_RoundCfg r) {
    final st = _statusCfg[r.status]!;
    final on = _checked[r.id] ?? false;
    final disabled = r.status == 'full';
    final pct = (r.cur / r.max * 100).round();
    final borderColor = disabled ? T.borderSubtle : (on ? T.primary : T.borderDefault);
    final bg = disabled ? T.gray50 : (on ? T.primarySoft : T.white);
    final fillColor = disabled ? T.danger : (r.status == 'closing' ? T.warning : T.primary);

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: GestureDetector(
        onTap: () => _toggle(r.id),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(T.rXl),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // 카드 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // 체크박스
                Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 1),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: disabled ? T.gray100 : (on ? T.primary : T.white),
                    borderRadius: BorderRadius.circular(T.rMini),
                    border: Border.all(color: disabled ? T.borderDefault : (on ? T.primary : T.borderDefault), width: 2),
                  ),
                  child: (on && !disabled)
                      ? const Icon(LucideIcons.check, size: 13, color: T.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Flexible(
                        child: Text('${r.label}: ${r.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tx(14, FontWeight.w700, disabled ? T.textDisabled : T.textStrong, height: 1)),
                      ),
                      if (disabled) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: st.bg, borderRadius: BorderRadius.circular(T.rPill)),
                          child: Text('선택 불가', style: tx(10, FontWeight.w700, st.color, height: 1)),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(LucideIcons.clock, size: 12, color: T.textMuted),
                      const SizedBox(width: 4),
                      Text(r.time, style: tx(12, FontWeight.w500, T.textMuted, height: 1)),
                      const SizedBox(width: 4),
                      Opacity(opacity: 0.4, child: Text('·', style: tx(12, FontWeight.w500, T.textMuted, height: 1))),
                      const SizedBox(width: 4),
                      const Icon(LucideIcons.mapPin, size: 12, color: T.textMuted),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(r.place,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tx(12, FontWeight.w500, T.textMuted, height: 1)),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    // 상태 + 인원
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: st.bg, borderRadius: BorderRadius.circular(T.rPill)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(width: 6, height: 6, decoration: BoxDecoration(color: st.dot, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(st.label, style: tx(11, FontWeight.w600, st.color, height: 1)),
                        ]),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${r.cur}명 참여 중 / 최대 ${r.max}명${r.min != null ? ' (최소 ${r.min}명)' : ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tx(11, FontWeight.w500, T.textMuted, height: 1),
                        ),
                      ),
                    ]),
                  ]),
                ),
                const SizedBox(width: 8),
                // 금액
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${won(r.cost)}원',
                      style: tx(16, FontWeight.w700,
                          disabled ? T.textDisabled : (on ? T.primary : T.textStrong),
                          height: 1, tab: true)),
                  const SizedBox(height: 3),
                  Text('인당 예상', style: tx(10, FontWeight.w500, T.textDisabled, height: 1)),
                ]),
              ]),
            ),
            // 인원 프로그레스 바
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: SizedBox(
                height: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: (pct / 100).clamp(0.0, 1.0),
                      child: Container(color: fillColor),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── 안내 ──
  Widget _infoHint() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: T.gray50, borderRadius: BorderRadius.circular(T.rLg)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(LucideIcons.info, size: 14, color: T.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text('선택한 차수의 회비를 합산하여 한 번에 송금합니다. 취소 시 주최자와 협의 후 환불돼요.',
                style: tx(12, FontWeight.w500, T.textMuted, height: 1.6)),
          ),
        ]),
      );

  // ── 하단 고정 정산 바 ──
  Widget _bottomBar() {
    final labels = _selectedLabels;
    return Container(
      decoration: const BoxDecoration(
        color: T.white,
        border: Border(top: BorderSide(color: T.borderSubtle)),
        // 프로토타입 box-shadow: 0 -4px 20px rgba(0,0,0,0.08).
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: labels.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('참석할 차수를 선택해 주세요',
                      textAlign: TextAlign.center,
                      style: tx(14, FontWeight.w500, T.textMuted, height: 1.5)),
                )
              : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        RichText(
                          text: TextSpan(
                            style: tx(12, FontWeight.w500, T.textMuted, height: 1),
                            children: [
                              const TextSpan(text: '선택한 차수: '),
                              TextSpan(text: labels.join(' + '), style: tx(12, FontWeight.w700, T.primary, height: 1)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('나의 총 예상 회비', style: tx(12, FontWeight.w500, T.textMuted, height: 1)),
                      ]),
                    ),
                    const SizedBox(width: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: _initialTotal.toDouble(), end: _total.toDouble()),
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, _) => Text('${won(v.round())}원',
                          style: tx(26, FontWeight.w700, T.textStrong, ls: -0.02, height: 1, tab: true)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DepositConfirmScreen()),
                    ),
                    child: Container(
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE500), // proto #FEE500 (카카오페이 브랜드)
                        borderRadius: BorderRadius.circular(T.rXl),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        // 카카오페이 로고 스탠드인.
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3C1E1E), // proto #3C1E1E (카카오페이 브랜드)
                            shape: BoxShape.circle,
                          ),
                          child: Text('pay',
                              style: tx(8, FontWeight.w700, const Color(0xFFFEE500), height: 1)), // proto #FEE500
                        ),
                        const SizedBox(width: 10),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: _initialTotal.toDouble(), end: _total.toDouble()),
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, _) => Text('포인트로 ${won(v.round())}원 예치하고 신청',
                              style: tx(15, FontWeight.w700, const Color(0xFF3C1E1E), height: 1)), // proto #3C1E1E
                        ),
                      ]),
                    ),
                  ),
                ]),
        ),
      ),
    );
  }
}
