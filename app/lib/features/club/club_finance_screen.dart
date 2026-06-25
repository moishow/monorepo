// 동아리 재정 관리 — prototype ClubFinanceScreen (a6569647:499).
// 잔액 카드(지갑 그라데이션)·엑셀/PDF 내보내기·역대 정산 히스토리.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import '../settlement/settlement_detail_screen.dart';

class _Hist {
  final String date, title;
  final int amount;
  final bool receipt;
  const _Hist(this.date, this.title, this.amount, this.receipt);
}

class ClubFinanceScreen extends StatelessWidget {
  const ClubFinanceScreen({super.key});

  // ── 정산 히스토리(프로토타입 history 리터럴) ──
  static const _history = [
    _Hist('06/15', '정기 대관 연습', 360000, true),
    _Hist('05/20', '5월 정기 엠티', 820000, true),
    _Hist('05/01', '신입생 환영회', 450000, true),
    _Hist('04/12', '4월 정기 연습', 280000, true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(
          title: '동아리 재정 관리',
          onBack: () => Navigator.of(context).maybePop(),
          actions: [
            MinTapTarget(
              const Icon(LucideIcons.download, size: 20, color: T.textMuted),
              onTap: () => MoishoToast.show(context, '준비 중', tone: 'info'),
              min: 38,
            ),
          ],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            physics: const BouncingScrollPhysics(),
            children: [
              _balanceCard(context),
              const SizedBox(height: 18),
              const SectionLabel('📂 역대 정산 히스토리'),
              ...[
                for (final h in _history) ...[
                  _historyCard(context, h),
                  if (h != _history.last) const SizedBox(height: 10),
                ],
              ],
            ],
          ),
        ),
      ]),
    );
  }

  // ── 잔액 카드 ──
  Widget _balanceCard(BuildContext context) => MCard(
        elevation: 'raised',
        radius: T.r2xl,
        padding: EdgeInsets.zero,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            decoration: const BoxDecoration(gradient: T.gradWallet),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Opacity(
                opacity: 0.85,
                child: Text("홍대 연합 밴드 '사운드' 장부 총 잔액",
                    style: tx(12, FontWeight.w500, T.white, height: 1)),
              ),
              const SizedBox(height: 8),
              Text('124,000원', style: tx(34, FontWeight.w700, T.white, ls: -0.02, height: 1, tab: true)),
              const SizedBox(height: 8),
              Opacity(
                opacity: 0.75,
                child: Text('부원들의 페이백 미차감액 총합',
                    style: tx(12, FontWeight.w500, T.white, height: 1.3)),
              ),
            ]),
          ),
          Container(
            color: T.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Expanded(
                child: MButton('엑셀', variant: 'secondary', size: 'sm', block: true,
                    leadingIcon: const Icon(LucideIcons.fileSpreadsheet, size: 16, color: T.primary),
                    onTap: () => MoishoToast.show(context, '준비 중', tone: 'info')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MButton('PDF', variant: 'secondary', size: 'sm', block: true,
                    leadingIcon: const Icon(LucideIcons.fileText, size: 16, color: T.primary),
                    onTap: () => MoishoToast.show(context, '준비 중', tone: 'info')),
              ),
            ]),
          ),
        ]),
      );

  // ── 정산 히스토리 카드 ──
  Widget _historyCard(BuildContext context, _Hist h) {
    final parts = h.date.split('/');
    return MCard(
      elevation: 'outline',
      radius: T.rXl,
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettlementDetailScreen()),
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: T.gray50, borderRadius: BorderRadius.circular(T.rMd)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(parts[1], style: tx(15, FontWeight.w700, T.textStrong, height: 1)),
            const SizedBox(height: 2),
            Text('${parts[0]}월', style: tx(10, FontWeight.w500, T.textMuted, height: 1)),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(h.title, style: tx(14, FontWeight.w600, T.textTitle, height: 1.2)),
            const SizedBox(height: 4),
            Text('지출 ${won(h.amount)}원', style: tx(14, FontWeight.w700, T.textStrong, height: 1, tab: true)),
          ]),
        ),
        if (h.receipt) ...[
          const SizedBox(width: 8),
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.receipt, size: 16, color: T.primary),
            const SizedBox(width: 4),
            Text('영수증', style: tx(12, FontWeight.w600, T.primary, height: 1)),
          ]),
        ],
      ]),
    );
  }
}
