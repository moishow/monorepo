// 부원 출금 동의 요청 — prototype PayoutConsentScreen (5b8ddc3c:406).
// 총무 출금 요청 안내 hero · 출금 요약 카드 · 균등 환급 안내 · 동의/거절 CTA.
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

  String? _done; // null | 'agreed' | 'rejected'

  void _agree() {
    setState(() => _done = 'agreed');
    MoishoToast.show(context, '출금에 동의했어요. 전원 동의되면 총무가 출금할 수 있어요.',
        tone: 'success', title: '동의 완료');
  }

  void _reject() {
    setState(() => _done = 'rejected');
    MoishoToast.show(context, '총무에게 거절이 전달됐어요. 사유는 채팅으로 전해 주세요.',
        tone: 'neutral', title: '동의 거절');
  }

  @override
  Widget build(BuildContext context) {
    final agreed = _done == 'agreed';
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
              _summaryCard(),
              const SizedBox(height: 16),
              _noticeBox(),
              if (_done != null) ...[
                const SizedBox(height: 16),
                _resultBox(agreed),
              ],
            ],
          ),
        ),
        _cta(agreed),
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

  // ── 균등 환급 안내(앰버) ──
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
              '락 시점에 예치한 전원이 동의해야 총무가 출금할 수 있어요. 출금 후 잔액은 영수증 증빙을 거쳐 1인당 균등 환급돼요.',
              // proto text #92400E (amber-900) → 가장 가까운 토큰 amber600.
              style: tx(12, FontWeight.w500, T.amber600, height: 1.5),
            ),
          ),
        ]),
      );

  // ── 동의/거절 결과 ──
  Widget _resultBox(bool agreed) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: agreed ? T.successSoft : T.dangerSoft,
          borderRadius: BorderRadius.circular(T.rLg),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(agreed ? LucideIcons.circleCheck : LucideIcons.circleX,
              size: 18, color: agreed ? T.successStrong : T.danger),
          const SizedBox(width: 8),
          Text(
            agreed ? '출금에 동의했어요' : '동의를 거절했어요',
            style: tx(14, FontWeight.w700, agreed ? T.successStrong : T.danger, height: 1),
          ),
        ]),
      );

  // ── 하단 CTA ──
  Widget _cta(bool agreed) {
    if (_done == null) {
      return StickyBar(
        child: Row(children: [
          Expanded(
            child: MButton('거절', variant: 'secondary', size: 'lg', block: true, onTap: _reject),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: MButton('출금에 동의', variant: 'primary', size: 'lg', block: true,
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
