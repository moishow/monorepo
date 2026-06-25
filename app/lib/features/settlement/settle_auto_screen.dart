// 자동 정산 결과 — prototype SettleAutoScreen (5b8ddc3c:531).
// 정산 완료 축하 hero(파티 + 내 환급) · 부원별 균등 환급 리스트 · 현금화 CTA.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../wallet/wallet_cashout_screen.dart';

class SettleAutoScreen extends StatelessWidget {
  const SettleAutoScreen({super.key});

  // ── 데이터(프로토타입 SettleAutoScreen 리터럴) ──
  static const int _returned = 68000;
  static const int _heads = 8;
  static const List<String> _members = [
    '김회장', '이총무', '박소심', '정성실', '최느림', '장열심', '윤민지', '나',
  ];

  int get _per => _returned ~/ _heads;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '자동 정산 완료', onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 16, T.padScreen, 24),
            children: [
              _heroCard(),
              const SizedBox(height: 16),
              const SectionLabel('부원별 환급 ($_heads명 균등)'),
              _refundList(),
              const SizedBox(height: 16),
            ],
          ),
        ),
        StickyBar(
          child: MButton(
            '환급 포인트 현금화하기',
            variant: 'primary',
            size: 'lg',
            block: true,
            leadingIcon: const Icon(LucideIcons.arrowUpRight, size: 18, color: T.white),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WalletCashoutScreen()),
            ),
          ),
        ),
      ]),
    );
  }

  // ── 정산 완료 축하 hero ──
  Widget _heroCard() => MCard(
        elevation: 'raised',
        radius: T.r2xl,
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(
            child: Container(
              width: 56, height: 56,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: const BoxDecoration(color: T.successSoft, shape: BoxShape.circle),
              child: const Icon(LucideIcons.partyPopper, size: 26, color: T.successStrong),
            ),
          ),
          Text('정산이 끝났어요!',
              textAlign: TextAlign.center,
              style: tx(18, FontWeight.w700, T.textStrong, height: 1.3)),
          const SizedBox(height: 6),
          Text('반납금 ${won(_returned)}P를 $_heads명에게 공평하게 나눴어요.',
              textAlign: TextAlign.center,
              style: tx(13, FontWeight.w500, T.textMuted, height: 1.5)),
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.only(top: 14),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: T.borderSubtle))),
            child: Column(children: [
              Text('나의 환급', style: tx(12, FontWeight.w500, T.textMuted, height: 1)),
              const SizedBox(height: 6),
              Text('+${won(_per)}P', style: tx(30, FontWeight.w700, T.primary, height: 1, tab: true)),
            ]),
          ),
        ]),
      );

  // ── 부원별 환급 리스트 ──
  Widget _refundList() => MCard(
        elevation: 'flat',
        radius: T.rXl,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: [
          for (var i = 0; i < _members.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                border: i < _members.length - 1
                    ? const Border(bottom: BorderSide(color: T.borderSubtle))
                    : null,
              ),
              child: Row(children: [
                MAvatar(name: _members[i], size: 34, tone: _members[i] == '나' ? 'purple' : 'blue'),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_members[i]}${_members[i] == '나' ? ' (나)' : ''}',
                    style: tx(14, _members[i] == '나' ? FontWeight.w700 : FontWeight.w600, T.textTitle, height: 1),
                  ),
                ),
                Text('+${won(_per)}P', style: tx(14, FontWeight.w700, T.successStrong, height: 1, tab: true)),
              ]),
            ),
        ]),
      );
}
