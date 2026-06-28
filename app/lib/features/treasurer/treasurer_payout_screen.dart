// 총무 출금(현금화) — LOCKED 이후 — prototype TreasurerPayoutScreen (5b8ddc3c:300).
// 결정1(시간별 위약금 + 전액출금): 출금은 동의에 막히지 않음. "출금 동의받기"=5분 투명성
// 수집 알림(미응답=위약금 부담 노쇼), 출금 CTA는 항상 전액 가능.
import 'dart:async';
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
  // 락 시점 스냅샷: 이 시점에 예치한 부원 명단(투명성 동의 분모) — 출금 게이트가 아님.
  static const String _lockedAt = '2026.06.22 21:00';
  static const int _windowSec = 300; // 출금 동의 수집 5분 창(클라 표시·서버시계 흉내)

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

  bool _requested = false; // 출금 동의받기 발송 여부
  bool _closed = false; // 5분 창 마감 여부
  int _remaining = _windowSec;
  Timer? _timer;

  int get _agreed => _members.where((m) => m.consented).length;
  int get _total => _members.length;
  bool get _allAgreed => _agreed == _total;
  double get _pct => (_agreed / _total * 100).roundToDouble();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _clock(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  // 출금 동의받기 = 5분 투명성 수집 알림 발송(출금을 막지 않음).
  void _requestConsent() {
    if (_requested) return;
    setState(() => _requested = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_remaining <= 1) {
        _closeWindow();
      } else {
        setState(() => _remaining -= 1);
      }
    });
    MoishoToast.show(
      context,
      '미동의 ${_total - _agreed}명에게 출금 동의 요청을 보냈어요. 5분 후 자동 마감돼요.',
      tone: 'info',
      title: '동의 요청 발송',
    );
  }

  void _closeWindow() {
    if (_closed) return;
    _timer?.cancel();
    final noResp = _total - _agreed;
    setState(() {
      _remaining = 0;
      _closed = true;
    });
    // 결정1-③/⑤: 미응답=위약금 부담 노쇼. 출금은 동의와 무관하게 전액 가능.
    MoishoToast.show(
      context,
      noResp > 0
          ? '동의 마감 — 미응답 $noResp명은 위약금 부담(노쇼)으로 기록됐어요. 전액 출금할 수 있어요.'
          : '동의 마감 — 전원 응답 완료. 전액 출금할 수 있어요.',
      tone: 'neutral',
      title: '동의 마감',
    );
  }

  void _simulateConsent() {
    setState(() {
      _members = _members.map((m) => m.consented ? m : m.copyConsent('방금')).toList();
    });
  }

  void _payout() {
    _timer?.cancel();
    // 결정1-⑤: PAYOUT = 에스크로 전액(무응답자 몫도 위약금 부담으로 포함). "전원 동의" 게이트 없음.
    MoishoToast.show(
      context,
      '${won(_pooled)}원 전액이 계좌로 이체됐어요. 영수증·잔액 반납 타이머가 시작돼요.',
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
              _consentPanel(),
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

  // ── 출금 동의 현황(투명성 수집 — 출금 게이트 아님) ──
  Widget _consentPanel() {
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
              const TextSpan(text: '에게 정산 투명성 동의를 받아요. 동의는 출금 조건이 아니에요 — 미응답·거절은 위약금 부담 노쇼로 기록돼요.'),
            ]),
          ),
        ),
        ProgressBar(value: _pct, height: 12, tone: _allAgreed ? 'success' : 'primary'),
        const SizedBox(height: 14),
        for (var i = 0; i < _members.length; i++) _memberRow(_members[i], i == 0),
        const SizedBox(height: 12),
        if (!_requested)
          _requestButton()
        else if (!_closed)
          _countdownRow()
        else
          _closedNote(),
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
            MBadge(_closed ? '노쇼' : '대기', tone: _closed ? 'warning' : 'neutral', variant: 'soft'),
        ]),
      );

  // ── 출금 동의받기(5분 알림 발송) ──
  Widget _requestButton() => GestureDetector(
        onTap: _requestConsent,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: T.primarySoft,
            borderRadius: BorderRadius.circular(T.rMd),
            border: Border.all(color: T.primary, width: 1.5),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.bellRing, size: 15, color: T.primary),
            const SizedBox(width: 6),
            Text('출금 동의받기 · 미동의 ${_total - _agreed}명에게 5분 알림',
                style: tx(13, FontWeight.w700, T.primary, height: 1)),
          ]),
        ),
      );

  // ── 5분 수집 카운트다운 ──
  Widget _countdownRow() {
    final pct = (_remaining / _windowSec * 100).clamp(0, 100).toDouble();
    final urgent = _remaining <= 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(T.rMd)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(LucideIcons.clock, size: 15, color: urgent ? T.danger : T.primary),
          const SizedBox(width: 8),
          Text('동의 수집 마감까지', style: tx(12.5, FontWeight.w600, T.textBody, height: 1)),
          const Spacer(),
          Text(_clock(_remaining),
              style: tx(18, FontWeight.w800, urgent ? T.danger : T.textStrong, height: 1, tab: true)),
        ]),
        const SizedBox(height: 10),
        ProgressBar(value: pct, height: 6, tone: urgent ? 'accent' : 'primary'),
        const SizedBox(height: 8),
        Text('미응답은 위약금 부담 노쇼로 기록돼요. 출금은 지금도 전액 가능해요.',
            style: tx(11.5, FontWeight.w500, T.textMuted, height: 1.4)),
      ]),
    );
  }

  // ── 동의 마감 안내 ──
  Widget _closedNote() {
    final noResp = _total - _agreed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: T.surfaceSunken, borderRadius: BorderRadius.circular(T.rMd)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(LucideIcons.circleCheck, size: 15, color: T.textBody),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            noResp > 0
                ? '동의 수집 마감 · 전액 출금 가능 (미응답 $noResp명 위약금 부담 노쇼)'
                : '동의 수집 마감 · 전원 응답 · 전액 출금 가능',
            style: tx(12, FontWeight.w600, T.textBody, height: 1.4),
          ),
        ),
      ]),
    );
  }

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

  // ── 하단 CTA(전액 출금 — 동의에 막히지 않음) ──
  Widget _cta() => StickyBar(
        child: MButton('전액 출금 · ${won(_pooled)}원',
            variant: 'primary',
            size: 'lg',
            block: true,
            leadingIcon: const Icon(LucideIcons.banknote, size: 18, color: T.white),
            onTap: _payout),
      );
}
