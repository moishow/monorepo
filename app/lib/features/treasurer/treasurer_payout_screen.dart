// 총무 출금(현금화) — LOCKED 이후·전원 동의 게이트 — prototype TreasurerPayoutScreen (5b8ddc3c:300).
// LOCKED hero · 출금 동의 현황(아바타 리스트+게이지) · 정산 타이머 · OCR 안내 · 데모 동의 처리 · 하단 출금 CTA.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import '../settlement/settle_return_screen.dart';

class _Member {
  final String name;
  final bool consented;
  final String? at;
  const _Member(this.name, this.consented, this.at);

  _Member copyConsent(String at) => _Member(name, true, at);
}

class TreasurerPayoutScreen extends StatefulWidget {
  const TreasurerPayoutScreen({super.key});

  @override
  State<TreasurerPayoutScreen> createState() => _TreasurerPayoutScreenState();
}

class _TreasurerPayoutScreenState extends State<TreasurerPayoutScreen> {
  static const int _pooled = 480000;
  // 락 시점 스냅샷: 이 시점에 예치한 부원 전원의 동의가 모여야 출금 가능
  static const String _lockedAt = '2026.06.22 21:00';

  List<_Member> _members = const [
    _Member('김회장', true, '21:04'),
    _Member('이총무', true, '21:06'),
    _Member('박소심', true, '21:11'),
    _Member('정디자', true, '21:20'),
    _Member('최부원', true, '어제'),
    _Member('장열심', false, null),
    _Member('오빠름', false, null),
    _Member('한바름', true, '오늘 08:30'),
  ];

  int get _agreed => _members.where((m) => m.consented).length;
  int get _total => _members.length;
  bool get _allAgreed => _agreed == _total;
  double get _pct => (_agreed / _total * 100).roundToDouble();

  void _requestConsent() {
    MoishoToast.show(
      context,
      '미동의 ${_total - _agreed}명에게 출금 동의 요청을 보냈어요.',
      tone: 'info',
      title: '동의 요청 발송',
    );
  }

  void _simulateConsent() {
    setState(() {
      _members = _members.map((m) => m.consented ? m : m.copyConsent('방금')).toList();
    });
  }

  void _payout() {
    MoishoToast.show(
      context,
      '전원 동의 완료 · ${won(_pooled)}원이 계좌로 이체됐어요.',
      tone: 'success',
      title: '출금 완료',
    );
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettleReturnScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '총무 — 모임 자금 출금', onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 16, T.padScreen, 24),
            children: [
              _hero(),
              const SizedBox(height: 16),
              _consentGate(),
              const SizedBox(height: 16),
              _settleTimer(),
              const SizedBox(height: 16),
              _ocrNotice(),
              if (!_allAgreed) ...[
                const SizedBox(height: 14),
                _demoButton(),
              ],
            ],
          ),
        ),
        _cta(),
      ]),
    );
  }

  // ── LOCKED hero ──
  Widget _hero() => ClipRRect(
        borderRadius: BorderRadius.circular(T.r2xl),
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: T.shadowCard,
            // proto linear-gradient(135deg, #1F2937, #4B5563)
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [T.gray800, T.gray600], // proto #1F2937 → #4B5563
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const MBadge('🔒 LOCKED', tone: 'warning', variant: 'soft'),
              const SizedBox(width: 6),
              Text('만남 시각 경과 · 취소 마감',
                  style: tx(12, FontWeight.w500, Colors.white.withValues(alpha: 0.85), height: 1)),
            ]),
            const SizedBox(height: 10),
            Text('출금 가능한 모인 자금',
                style: tx(12, FontWeight.w500, Colors.white.withValues(alpha: 0.85), height: 1)),
            const SizedBox(height: 5),
            Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
              Text(won(_pooled), style: tx(30, FontWeight.w700, T.white, height: 1, tab: true)),
              Text('원', style: tx(18, FontWeight.w700, Colors.white.withValues(alpha: 0.85), height: 1)),
            ]),
          ]),
        ),
      );

  // ── 출금 동의 게이트 ──
  Widget _consentGate() {
    return MCard(
      elevation: 'raised',
      radius: T.rXl,
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(LucideIcons.users, size: 17, color: T.primary),
          const SizedBox(width: 8),
          Text('출금 동의 현황', style: tx(14, FontWeight.w700, T.textTitle, height: 1)),
          const Spacer(),
          Text('$_agreed / $_total명',
              style: tx(14, FontWeight.w700, _allAgreed ? T.successStrong : T.primary, height: 1, tab: true)),
        ]),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RichText(
            text: TextSpan(style: tx(11.5, FontWeight.w500, T.textMuted, height: 1.4), children: [
              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.only(right: 3),
                  child: Icon(LucideIcons.lock, size: 11, color: T.textMuted),
                ),
              ),
              TextSpan(text: '$_lockedAt 락 시점에 예치한 '),
              TextSpan(text: '$_total명', style: tx(11.5, FontWeight.w700, T.textMuted, height: 1.4)),
              const TextSpan(text: ' 전원이 동의해야 출금할 수 있어요.'),
            ]),
          ),
        ),
        ProgressBar(value: _pct, height: 12, tone: _allAgreed ? 'success' : 'primary'),
        const SizedBox(height: 14),
        for (var i = 0; i < _members.length; i++) _memberRow(_members[i], i == 0),
        if (!_allAgreed) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _requestConsent,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: T.primarySoft,
                borderRadius: BorderRadius.circular(T.rMd),
                border: Border.all(color: T.primary, width: 1.5),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(LucideIcons.bell, size: 14, color: T.primary),
                const SizedBox(width: 6),
                Text('미동의 ${_total - _agreed}명에게 동의 요청 보내기',
                    style: tx(13, FontWeight.w700, T.primary, height: 1)),
              ]),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _memberRow(_Member m, bool first) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: first ? null : const Border(top: BorderSide(color: T.borderSubtle)),
        ),
        child: Row(children: [
          MAvatar(name: m.name, size: 32, status: m.consented ? 'success' : null),
          const SizedBox(width: 10),
          Expanded(child: Text(m.name, style: tx(13, FontWeight.w600, T.textBody, height: 1))),
          if (m.consented) ...[
            Text(m.at ?? '', style: tx(11, FontWeight.w500, T.textDisabled, height: 1)),
            const SizedBox(width: 4),
            const MBadge('동의', tone: 'success', variant: 'soft'),
          ] else
            const MBadge('대기', tone: 'neutral', variant: 'soft'),
        ]),
      );

  // ── 정산 타이머 ──
  Widget _settleTimer() => MCard(
        elevation: 'flat',
        radius: T.rXl,
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: T.warningSoft, borderRadius: BorderRadius.circular(T.rMd)),
            child: const Icon(LucideIcons.clock, size: 20, color: T.amber600), // proto #B45309
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('정산 데드라인 12:00:00', style: tx(14, FontWeight.w700, T.textTitle, height: 1.3, tab: true)),
              const SizedBox(height: 3),
              Text('출금하면 타이머가 시작돼요. 기한 내 영수증·잔액을 반납하지 않으면 신용등급이 차감돼요.',
                  style: tx(11.5, FontWeight.w500, T.textMuted, height: 1.4)),
            ]),
          ),
        ]),
      );

  // ── OCR 안내 ──
  Widget _ocrNotice() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(T.rMd)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(LucideIcons.receipt, size: 15, color: T.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text('모임 종료 후 영수증을 올리면 OCR이 지출액을 자동 인식하고, 남은 잔액은 부원에게 자동 환급돼요.',
                style: tx(12, FontWeight.w500, T.primary, height: 1.5)),
          ),
        ]),
      );

  // ── 데모: 미동의 부원 동의 시뮬레이션 ──
  Widget _demoButton() => GestureDetector(
        onTap: _simulateConsent,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(T.rPill),
            border: Border.all(color: T.borderDefault),
          ),
          child: Text('⚙ 데모: 남은 ${_total - _agreed}명 동의 처리',
              style: tx(11, FontWeight.w500, T.textDisabled, height: 1)),
        ),
      );

  // ── 하단 CTA ──
  Widget _cta() => StickyBar(
        child: _allAgreed
            ? MButton('전원 동의 완료 · ${won(_pooled)}원 출금',
                variant: 'primary',
                size: 'lg',
                block: true,
                leadingIcon: const Icon(LucideIcons.banknote, size: 18, color: T.white),
                onTap: _payout)
            : MButton('출금 동의 대기 중 · $_agreed/$_total명',
                variant: 'secondary',
                size: 'lg',
                block: true,
                disabled: true,
                leadingIcon: const Icon(LucideIcons.lock, size: 17, color: T.primary)),
      );
}
