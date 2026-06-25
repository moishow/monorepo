// 총무 입금 현황 — prototype TreasurerScreen (6c5465b6:243).
// 모임통장·취합 금액·안내·예치 완료 명단·하단 출금 CTA.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import 'treasurer_payout_screen.dart';

class _Attendee {
  final String name, time;
  final int amount;
  const _Attendee(this.name, this.amount, this.time);
}

class TreasurerScreen extends StatelessWidget {
  /// 카드에서 넘어올 때 모임명을 덮어쓸 수 있음(프로토타입 navData.meeting).
  final String? meetingName;
  const TreasurerScreen({super.key, this.meetingName});

  static const _maxPeople = 10;
  static const _attendees = [
    _Attendee('김회장', 40000, '14:02'),
    _Attendee('박소심', 40000, '11:30'),
    _Attendee('이총무', 40000, '10:15'),
    _Attendee('최부원', 40000, '09:50'),
    _Attendee('정디자', 40000, '09:22'),
    _Attendee('장열심', 40000, '08:55'),
    _Attendee('오빠름', 40000, '08:41'),
  ];

  String get _meeting => meetingName ?? '정기 합주 & 뒷풀이';
  int get _total => _attendees.fold(0, (s, a) => s + a.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(
          title: '총무 — $_meeting',
          onBack: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 16, T.padScreen, 16),
            physics: const BouncingScrollPhysics(),
            children: [
              _walletCard(),
              const SizedBox(height: 16),
              _totalCard(),
              const SizedBox(height: 16),
              _notice(),
              const SizedBox(height: 18),
              SectionLabel('✅ 예치 완료 (${_attendees.length}명) — 포인트 예치'),
              _depositList(),
            ],
          ),
        ),
        StickyBar(
          child: MButton('모임 자금 출금 · 정산하기',
              variant: 'primary', size: 'lg', block: true,
              leadingIcon: const Icon(LucideIcons.banknote, size: 18, color: T.white),
              onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TreasurerPayoutScreen()),
                  )),
        ),
      ]),
    );
  }

  // ── 모임통장 ──
  Widget _walletCard() => MCard(
        elevation: 'flat',
        radius: T.rLg,
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: T.successSoft, borderRadius: BorderRadius.circular(T.rMd)),
            child: const Icon(LucideIcons.wallet, size: 18, color: T.successStrong),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('카카오페이 모임통장', style: tx(12, FontWeight.w600, T.textMuted, height: 1)),
              const SizedBox(height: 2),
              Text('사운드 모임통장 · 자동 수취', style: tx(14, FontWeight.w700, T.textStrong, height: 1.2)),
            ]),
          ),
          const SizedBox(width: 8),
          const MBadge('연결됨', tone: 'success', variant: 'dot'),
        ]),
      );

  // ── 취합 금액 ──
  Widget _totalCard() => MCard(
        elevation: 'raised',
        radius: T.rXl,
        padding: const EdgeInsets.all(18),
        accent: T.primary,
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('현재까지 취합된 금액', style: tx(12, FontWeight.w500, T.textMuted, height: 1)),
              const SizedBox(height: 6),
              Text('${won(_total)}원', style: tx(28, FontWeight.w700, T.textStrong, height: 1, ls: -0.02, tab: true)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('참석 신청', style: tx(12, FontWeight.w500, T.textMuted, height: 1)),
            const SizedBox(height: 6),
            Text('${_attendees.length} / $_maxPeople명', style: tx(20, FontWeight.w700, T.primary, height: 1, tab: true)),
          ]),
        ]),
      );

  // ── 안내 ──
  Widget _notice() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: T.successSoft, borderRadius: BorderRadius.circular(T.rMd)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(LucideIcons.shieldCheck, size: 16, color: T.successStrong),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '참석 신청 시 보유 포인트 차감 + 부족분만 충전해 예치돼요. 마감 전 취소 시 100% 환불.',
              style: tx(12, FontWeight.w500, T.textBody, height: 1.5),
            ),
          ),
        ]),
      );

  // ── 입금 완료 명단 ──
  Widget _depositList() => Column(
        children: [
          for (var i = 0; i < _attendees.length; i++) _depositRow(_attendees[i], i < _attendees.length - 1),
        ],
      );

  Widget _depositRow(_Attendee p, bool divider) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: divider ? const Border(bottom: BorderSide(color: T.borderSubtle)) : null,
        ),
        child: Row(children: [
          MAvatar(name: p.name, status: 'success', size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: tx(14, FontWeight.w600, T.textTitle, height: 1.2)),
              const SizedBox(height: 3),
              Text('오늘 ${p.time} 자동 이체', style: tx(12, FontWeight.w500, T.textMuted, height: 1)),
            ]),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${won(p.amount)}원', style: tx(13, FontWeight.w600, T.successStrong, height: 1.2, tab: true)),
            const SizedBox(height: 4),
            const MBadge('완료', tone: 'success', variant: 'soft'),
          ]),
        ]),
      );
}
