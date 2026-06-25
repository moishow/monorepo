// 포인트 지갑 — prototype WalletScreen (5b8ddc3c:53).
// 그라데이션 잔액 hero(보유/사용가능/예치중) + 충전·현금화 + 예치 중 모임 + 포인트 원장 내역.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../meeting/meeting_detail_screen.dart';
import 'wallet_charge_screen.dart';
import 'wallet_cashout_screen.dart';

// ── 예치 중 모임(프로토타입 리터럴) ──
class _LockedMeeting {
  final String name, rounds, dline;
  final int amount;
  const _LockedMeeting(this.name, this.rounds, this.amount, this.dline);
}

// ── 원장 내역(프로토타입 LEDGER 리터럴) ──
class _Ledger {
  final String title, date, kind;
  final int amt;
  final IconData icon;
  const _Ledger(this.title, this.date, this.amt, this.kind, this.icon);
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  // ── 잔액(프로토타입 리터럴) ──
  static const int _balance = 128400;
  static const int _locked = 45000;
  static const int _available = _balance - _locked; // 83400

  static const _lockedMeetings = [
    _LockedMeeting('정기 합주 & 뒷풀이', '1·2차', 40000, 'D-1 후 락'),
    _LockedMeeting('파이썬 스터디 번개', '1차', 5000, '오늘 19시 락'),
  ];

  static const _ledger = [
    _Ledger('정기 합주 정산 환급', '2026.06.16 21:03', 4200, '정산환급', LucideIcons.rotateCcw),
    _Ledger('정기 합주 차수 예치', '2026.06.13 18:22', -40000, '예치', LucideIcons.lock),
    _Ledger('포인트 충전', '2026.06.13 18:20', 50000, '충전', LucideIcons.plus),
    _Ledger('번개 예약금 취소 환불', '2026.06.10 12:40', 5000, '취소환불', LucideIcons.undo2),
    _Ledger('계좌 현금화', '2026.06.02 09:12', -30000, '현금화', LucideIcons.arrowUpRight),
    _Ledger('독서모임 정산 환급', '2026.05.28 20:14', 12000, '정산환급', LucideIcons.rotateCcw),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '내 포인트 지갑', onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              _hero(context),
              const SizedBox(height: 16),
              const SectionLabel('예치 중인 모임'),
              _lockedList(context),
              const SizedBox(height: 18),
              const SectionLabel('포인트 내역'),
              _ledgerCard(),
            ],
          ),
        ),
      ]),
    );
  }

  // ── A안 — 그라데이션 잔액 hero + 예치중 요약 ──
  Widget _hero(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(T.r2xl),
        child: Container(
          decoration: const BoxDecoration(color: T.white, boxShadow: T.shadowCard),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // 그라데이션 잔액 섹션
            Container(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              decoration: const BoxDecoration(gradient: T.gradWallet),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(LucideIcons.wallet, size: 16, color: T.white.withValues(alpha: 0.92)),
                  const SizedBox(width: 7),
                  Text('보유 포인트', style: tx(13, FontWeight.w600, T.white.withValues(alpha: 0.92), height: 1)),
                ]),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(text: won(_balance), style: tx(34, FontWeight.w700, T.white, ls: -0.02, height: 1, tab: true)),
                    TextSpan(text: 'P', style: tx(20, FontWeight.w700, T.white.withValues(alpha: 0.85), height: 1, tab: true)),
                  ]),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.only(top: 14),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: T.white.withValues(alpha: 0.2)))),
                  child: Row(children: [
                    _heroStat('사용 가능', '${won(_available)}P'),
                    const SizedBox(width: 16),
                    _heroStat('예치 중 🔒', '${won(_locked)}P'),
                  ]),
                ),
              ]),
            ),
            // 충전·현금화 액션 섹션(흰 배경)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Expanded(
                  child: MButton('충전', variant: 'primary', size: 'md', block: true,
                      leadingIcon: const Icon(LucideIcons.plus, size: 17, color: T.white),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletChargeScreen()))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MButton('현금화', variant: 'secondary', size: 'md', block: true,
                      leadingIcon: const Icon(LucideIcons.arrowUpRight, size: 17, color: T.primary),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletCashoutScreen()))),
                ),
              ]),
            ),
          ]),
        ),
      );

  Widget _heroStat(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: tx(11, FontWeight.w500, T.white.withValues(alpha: 0.8), height: 1)),
        const SizedBox(height: 5),
        Text(value, style: tx(16, FontWeight.w700, T.white, height: 1, tab: true)),
      ]);

  // ── 예치 중인 모임 ──
  Widget _lockedList(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: T.white,
          borderRadius: BorderRadius.circular(T.rXl),
          border: Border.all(color: T.borderSubtle),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(T.rXl),
          child: Column(children: [
            for (var i = 0; i < _lockedMeetings.length; i++) _lockedRow(context, _lockedMeetings[i], i == 0),
          ]),
        ),
      );

  Widget _lockedRow(BuildContext context, _LockedMeeting m, bool divider) => GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MeetingDetailScreen(title: m.name, status: 'deposited')),
        ),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(border: divider ? const Border(bottom: BorderSide(color: T.borderSubtle)) : null),
          child: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: T.warningSoft, borderRadius: BorderRadius.circular(T.rMd)),
              child: const Icon(LucideIcons.lock, size: 16, color: T.amber600), // proto #B45309
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(14, FontWeight.w600, T.textTitle, height: 1.3)),
                const SizedBox(height: 3),
                Text('${m.rounds} · ${m.dline}', style: tx(11.5, FontWeight.w500, T.textDisabled, height: 1)),
              ]),
            ),
            const SizedBox(width: 8),
            Text('${won(m.amount)}P', style: tx(14, FontWeight.w700, T.textStrong, height: 1, tab: true)),
            const SizedBox(width: 4),
            const Icon(LucideIcons.chevronRight, size: 17, color: T.textDisabled),
          ]),
        ),
      );

  // ── 포인트 원장 내역 ──
  Widget _ledgerCard() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: T.white,
          borderRadius: BorderRadius.circular(T.rXl),
          border: Border.all(color: T.borderSubtle),
        ),
        child: Column(children: [
          for (var i = 0; i < _ledger.length; i++) _ledgerRow(_ledger[i], i == _ledger.length - 1),
        ]),
      );

  Widget _ledgerRow(_Ledger e, bool last) {
    final pos = e.amt > 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: T.borderSubtle))),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: pos ? T.successSoft : T.gray50, borderRadius: BorderRadius.circular(T.rMd)),
          child: Icon(e.icon, size: 18, color: pos ? T.successStrong : T.textMuted),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(14, FontWeight.w600, T.textTitle, height: 1.3)),
            const SizedBox(height: 3),
            Text('${e.date} · ${e.kind}', style: tx(11.5, FontWeight.w500, T.textDisabled, height: 1)),
          ]),
        ),
        const SizedBox(width: 8),
        Text('${pos ? '+' : ''}${won(e.amt)}P',
            style: tx(15, FontWeight.w700, pos ? T.successStrong : T.textStrong, height: 1, tab: true)),
      ]),
    );
  }
}
