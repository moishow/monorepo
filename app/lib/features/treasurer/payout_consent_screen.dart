// 부원 출금 동의 요청 — prototype PayoutConsentScreen (5b8ddc3c:406).
// 결정1(시간별 위약금 + 전액출금) 반영: 동의=정산 투명성 확인, 거절=이의 기록(출금은 진행).
// 5분 카운트다운(클라 표시·서버시계 흉내) + 무응답=위약금 부담(노쇼) 프레이밍.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import '../social/notifications_screen.dart';

class PayoutConsentScreen extends StatefulWidget {
  const PayoutConsentScreen({super.key});

  @override
  State<PayoutConsentScreen> createState() => _PayoutConsentScreenState();
}

class _PayoutConsentScreenState extends State<PayoutConsentScreen> {
  // ── navData 폴백(프로토타입 리터럴) ──
  static const _meeting = '정기 합주 & 뒷풀이';
  static const _amount = 480000;
  static const _myDeposit = 40000;

  // 동의 응답 창. 머니수학(서버 타이머·만료→위약금 분개)은 백엔드 몫 — 여기선 표시만.
  static const _windowSec = 300; // 5분

  String? _done; // null | 'agreed' | 'rejected' | 'expired'
  int _remaining = _windowSec;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_remaining <= 1) {
        _expire();
      } else {
        setState(() => _remaining -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _stopTimer() => _timer?.cancel();

  String _clock(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  void _agree() {
    _stopTimer();
    setState(() => _done = 'agreed');
    // 결정1-④: 동의 = 투명성 확인(출금 인가가 아님). "전원 동의" 프레이밍 제거.
    MoishoToast.show(context, '정산 내역을 확인했어요. 출금 내역은 영수증 증빙으로 공개돼요.',
        tone: 'success', title: '동의 완료');
  }

  void _reject() {
    _stopTimer();
    setState(() => _done = 'rejected');
    // 결정1-④: 거절 = 이의 기록일 뿐 출금을 막지 않음(CONSENT 데드락 소멸).
    MoishoToast.show(context, '이의가 기록됐어요. 출금은 예정대로 진행되며, 사유는 채팅으로 남겨 주세요.',
        tone: 'info', title: '이의 기록');
  }

  void _expire() {
    if (_done != null) return;
    _stopTimer();
    setState(() {
      _remaining = 0;
      _done = 'expired';
    });
    // 결정1-③: 무응답 = 위약금 부담 노쇼(환불 없음). 출금은 그대로 진행.
    MoishoToast.show(context, '응답 시간이 지났어요. 무응답은 위약금 부담(노쇼)으로 처리돼요.',
        tone: 'neutral', title: '응답 마감');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(
          title: '총무 출금 동의 요청',
          onBack: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 16, T.padScreen, 24),
            physics: const BouncingScrollPhysics(),
            children: [
              _hero(),
              const SizedBox(height: 16),
              if (_done == null) ...[
                _countdownBar(),
                const SizedBox(height: 16),
              ],
              _summaryCard(),
              const SizedBox(height: 16),
              _noticeBox(),
              if (_done != null) ...[
                const SizedBox(height: 16),
                _resultBox(),
              ],
            ],
          ),
        ),
        _cta(),
      ]),
    );
  }

  // ── 출금 요청 hero ──
  Widget _hero() => MCard(
        elevation: 'raised',
        radius: T.r2xl,
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Container(
            width: 56, height: 56,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: const BoxDecoration(color: T.primarySoft, shape: BoxShape.circle),
            child: const Icon(LucideIcons.shieldQuestion, size: 28, color: T.primary),
          ),
          Text(
            '총무가 모임 자금 출금을\n요청했어요',
            textAlign: TextAlign.center,
            style: tx(17, FontWeight.w700, T.textStrong, height: 1.3),
          ),
          const SizedBox(height: 6),
          Text(_meeting, textAlign: TextAlign.center, style: tx(13, FontWeight.w500, T.textMuted, height: 1.5)),
        ]),
      );

  // ── 5분 응답 카운트다운(표시용·서버시계 흉내) ──
  Widget _countdownBar() {
    final pct = (_remaining / _windowSec * 100).clamp(0, 100).toDouble();
    final urgent = _remaining <= 60;
    return MCard(
      elevation: 'flat',
      radius: T.rXl,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(LucideIcons.clock, size: 16, color: urgent ? T.danger : T.primary),
          const SizedBox(width: 8),
          Text('동의 마감까지', style: tx(13, FontWeight.w600, T.textBody, height: 1)),
          const Spacer(),
          Text(
            _clock(_remaining),
            style: tx(22, FontWeight.w800, urgent ? T.danger : T.textStrong, height: 1, tab: true),
          ),
        ]),
        const SizedBox(height: 12),
        ProgressBar(value: pct, height: 8, tone: urgent ? 'accent' : 'primary'),
        const SizedBox(height: 10),
        Text(
          '무응답으로 마감되면 위약금 부담(노쇼)으로 처리돼요. 총무 출금은 동의 여부와 무관하게 진행돼요.',
          style: tx(12, FontWeight.w500, T.textMuted, height: 1.5),
        ),
      ]),
    );
  }

  // ── 출금 요약 ──
  Widget _summaryCard() {
    final formatted = <(String, String)>[
      ('출금 요청 금액', '${won(_amount)}원'),
      ('내 예치금', '${won(_myDeposit)}P'),
      ('출금 후', '영수증 OCR 증빙 + 잔액 자동 환급'),
    ];
    return MCard(
      elevation: 'flat',
      radius: T.rXl,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Column(children: [
        for (var i = 0; i < formatted.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: i == 0 ? null : const Border(top: BorderSide(color: T.borderSubtle)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(formatted[i].$1, style: tx(13, FontWeight.w500, T.textMuted, height: 1)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  formatted[i].$2,
                  textAlign: TextAlign.right,
                  style: tx(13, FontWeight.w700, T.textStrong, height: 1.3, tab: true),
                ),
              ),
            ]),
          ),
      ]),
    );
  }

  // ── 동의/거절 프레이밍 안내(앰버) ──
  Widget _noticeBox() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: T.warningSoft, borderRadius: BorderRadius.circular(T.rMd)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(LucideIcons.info, size: 15, color: T.amber600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '동의는 정산 투명성 확인, 거절은 이의 기록이에요. 거절해도 총무 출금은 진행돼요. '
              '출금 후 잔액은 영수증 증빙을 거쳐 1인당 균등 환급돼요.',
              // proto text #92400E (amber-900) → 가장 가까운 토큰 amber600.
              style: tx(12, FontWeight.w500, T.amber600, height: 1.5),
            ),
          ),
        ]),
      );

  // ── 동의/거절/만료 결과 ──
  Widget _resultBox() {
    final (Color bg, Color fg, IconData icon, String label) = switch (_done) {
      'agreed' => (T.successSoft, T.successStrong, LucideIcons.circleCheck, '정산 내역을 확인했어요'),
      'rejected' => (T.warningSoft, T.amber600, LucideIcons.flag, '이의를 기록했어요 · 출금은 진행돼요'),
      _ => (T.surfaceSunken, T.textBody, LucideIcons.clock, '응답 시간이 지났어요 · 무응답 위약금 부담'),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(T.rLg)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 18, color: fg),
        const SizedBox(width: 8),
        Flexible(
          child: Text(label, textAlign: TextAlign.center, style: tx(14, FontWeight.w700, fg, height: 1.2)),
        ),
      ]),
    );
  }

  // ── 하단 CTA ──
  Widget _cta() {
    if (_done == null) {
      return StickyBar(
        child: Row(children: [
          Expanded(
            child: MButton('거절', variant: 'secondary', size: 'lg', block: true, onTap: _reject),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: MButton('동의', variant: 'primary', size: 'lg', block: true,
                leadingIcon: const Icon(LucideIcons.check, size: 17, color: T.white), onTap: _agree),
          ),
        ]),
      );
    }
    return StickyBar(
      child: MButton('확인', variant: 'primary', size: 'lg', block: true,
          onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              )),
    );
  }
}
