// 포인트 충전 — 현재 보유·프리셋 금액·충전 후 잔액·수수료 0원 안내·카카오페이 CTA.
// prototype WalletChargeScreen (5b8ddc3c:125).
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';

// 카카오 브랜드(충전 레일 한정) — 토큰 없음, 프로토타입 KK/KKD 그대로.
const _kk = Color(0xFFFEE500); // proto #FEE500
const _kkd = Color(0xFF3C1E1E); // proto #3C1E1E

class WalletChargeScreen extends StatefulWidget {
  const WalletChargeScreen({super.key});

  @override
  State<WalletChargeScreen> createState() => _WalletChargeScreenState();
}

class _WalletChargeScreenState extends State<WalletChargeScreen> {
  int _amt = 50000;

  static const List<int> _presets = [10000, 30000, 50000, 100000];
  static const int _balance = 128400;

  void _charge() {
    MoishoToast.show(context, '${won(_amt)}P가 충전됐어요.', tone: 'success');
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(
          title: '포인트 충전',
          onBack: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 18, T.padScreen, 24),
            children: [
              // ── 현재 보유 ──
              MCard(
                elevation: 'flat',
                radius: T.rXl,
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('현재 보유', style: tx(13, FontWeight.w500, T.textMuted, height: 1)),
                  const SizedBox(height: 6),
                  Text('${won(_balance)}P', style: tx(22, FontWeight.w700, T.textStrong, height: 1, tab: true)),
                ]),
              ),
              const SizedBox(height: 16),

              // ── 충전 금액 (2열 프리셋) ──
              const SectionLabel('충전 금액'),
              Row(children: [
                Expanded(child: _presetTile(_presets[0])),
                const SizedBox(width: 10),
                Expanded(child: _presetTile(_presets[1])),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _presetTile(_presets[2])),
                const SizedBox(width: 10),
                Expanded(child: _presetTile(_presets[3])),
              ]),
              const SizedBox(height: 14),

              // ── 충전 후 잔액 ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: T.white,
                  borderRadius: BorderRadius.circular(T.rLg),
                  border: Border.all(color: T.borderSubtle),
                ),
                child: Row(children: [
                  Text('충전 후 잔액', style: tx(13, FontWeight.w600, T.textMuted, height: 1)),
                  const Spacer(),
                  Text('${won(_balance + _amt)}P', style: tx(17, FontWeight.w700, T.primary, height: 1, tab: true)),
                ]),
              ),
              const SizedBox(height: 16),

              // ── 수수료 0원 안내 ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: T.successSoft, borderRadius: BorderRadius.circular(T.rMd)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(LucideIcons.badgeCheck, size: 16, color: T.successStrong),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '충전 수수료 0원. 사용하지 않은 포인트는 언제든 계좌로 현금화할 수 있어요.',
                      style: tx(12, FontWeight.w500, T.successStrong, height: 1.5),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),

        // ── 카카오페이 충전 CTA ──
        StickyBar(
          child: GestureDetector(
            onTap: _charge,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 54,
              decoration: BoxDecoration(color: _kk, borderRadius: BorderRadius.circular(T.rLg)),
              alignment: Alignment.center,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: _kkd, borderRadius: BorderRadius.circular(5)),
                  child: Text('Pay',
                      style: TextStyle(fontFamily: 'sans-serif', fontWeight: FontWeight.w900, fontSize: 11, color: _kk, height: 1)),
                ),
                const SizedBox(width: 8),
                Text('카카오페이로 ${won(_amt)}P 충전',
                    style: tx(16, FontWeight.w700, _kkd, height: 1, tab: true)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _presetTile(int p) {
    final on = _amt == p;
    return GestureDetector(
      onTap: () => setState(() => _amt = p),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: on ? T.primarySoft : T.white,
          borderRadius: BorderRadius.circular(T.rLg),
          border: Border.all(color: on ? T.primary : T.borderDefault, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text('${won(p)}P', style: tx(16, FontWeight.w700, on ? T.primary : T.textBody, height: 1, tab: true)),
      ),
    );
  }
}
