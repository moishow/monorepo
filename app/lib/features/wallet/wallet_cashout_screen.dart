// 현금화(출금) — prototype WalletCashoutScreen (5b8ddc3c:171).
// 현금화 가능 포인트 · 출금 계좌 · 출금 금액(슬라이더 + 전액) · 수수료 안내 · 하단 현금화 CTA.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';

class WalletCashoutScreen extends StatefulWidget {
  const WalletCashoutScreen({super.key});

  @override
  State<WalletCashoutScreen> createState() => _WalletCashoutScreenState();
}

class _WalletCashoutScreenState extends State<WalletCashoutScreen> {
  static const int _available = 83400;
  int _amt = _available;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '포인트 현금화', onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 18, T.padScreen, 24),
            children: [
              _balanceCard(),
              const SizedBox(height: 16),
              const SectionLabel('출금 계좌'),
              _accountCard(),
              const SizedBox(height: 16),
              const SectionLabel('출금 금액'),
              _amountCard(),
              const SizedBox(height: 16),
              _feeNotice(),
            ],
          ),
        ),
        StickyBar(
          child: MButton(
            '${won(_amt)}원 현금화하기',
            variant: 'primary',
            size: 'lg',
            block: true,
            leadingIcon: const Icon(LucideIcons.arrowUpRight, size: 18, color: T.white),
            onTap: () {
              MoishoToast.show(context, '${won(_amt)}원이 곧 입금돼요.',
                  tone: 'success', title: '출금 신청 완료');
              Navigator.of(context).maybePop();
            },
          ),
        ),
      ]),
    );
  }

  // ── 현금화 가능 포인트 ──
  Widget _balanceCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: T.surfaceSunken,
          borderRadius: BorderRadius.circular(T.rXl),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('현금화 가능 포인트', style: tx(13, FontWeight.w500, T.textMuted, height: 1)),
          const SizedBox(height: 6),
          Text('${won(_available)}P', style: tx(26, FontWeight.w700, T.textStrong, height: 1, tab: true)),
          const SizedBox(height: 6),
          Text('예치 중인 포인트는 정산 완료 후 현금화할 수 있어요.',
              style: tx(11.5, FontWeight.w500, T.textDisabled, height: 1.4)),
        ]),
      );

  // ── 출금 계좌 ──
  Widget _accountCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: T.surfaceSunken,
          borderRadius: BorderRadius.circular(T.rXl),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(T.rMd)),
            child: const Icon(LucideIcons.landmark, size: 18, color: T.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('국민은행 110-234-567890', style: tx(14, FontWeight.w600, T.textTitle, height: 1.3)),
              const SizedBox(height: 3),
              Text('홍길동 · 본인 명의', style: tx(11.5, FontWeight.w500, T.textDisabled, height: 1)),
            ]),
          ),
          const Icon(LucideIcons.chevronRight, size: 18, color: T.textDisabled),
        ]),
      );

  // ── 출금 금액 (슬라이더) ──
  Widget _amountCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: T.surfaceSunken,
          borderRadius: BorderRadius.circular(T.rXl),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text(won(_amt), style: tx(28, FontWeight.w700, T.textStrong, height: 1, tab: true)),
            const SizedBox(width: 4),
            Text('원', style: tx(18, FontWeight.w700, T.textMuted, height: 1)),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _amt = _available),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: T.white,
                  borderRadius: BorderRadius.circular(T.rPill),
                  border: Border.all(color: T.borderDefault, width: 1.5),
                ),
                child: Text('전액', style: tx(12, FontWeight.w700, T.primary, height: 1)),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: T.primary,
              inactiveTrackColor: T.gray100,
              thumbColor: T.primary,
              overlayColor: T.primary.withValues(alpha: 0.12),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: _amt.toDouble(),
              min: 0,
              max: _available.toDouble(),
              // step=1000 스냅(프로토타입)은 유지하되 눈금(tick)은 그리지 않아 트랙을 깔끔히.
              onChanged: (v) => setState(() => _amt = (v / 1000).round() * 1000),
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('0원', style: tx(11, FontWeight.w500, T.textDisabled, height: 1, tab: true)),
            Text('${won(_available)}원', style: tx(11, FontWeight.w500, T.textDisabled, height: 1, tab: true)),
          ]),
        ]),
      );

  // ── 수수료 안내 ──
  Widget _feeNotice() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: T.successSoft, borderRadius: BorderRadius.circular(T.rMd)),
        child: Row(children: [
          const Icon(LucideIcons.badgeCheck, size: 16, color: T.successStrong),
          const SizedBox(width: 8),
          Expanded(
            child: Text('출금 수수료 0원 · 영업일 기준 즉시~1시간 내 입금돼요.',
                style: tx(12, FontWeight.w500, T.successStrong, height: 1.5)),
          ),
        ]),
      );
}
