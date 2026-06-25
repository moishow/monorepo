// 차수 예치 확인 — prototype DepositConfirmScreen (5b8ddc3c:228).
// 예치할 포인트 hero(accent) + 분개(모임·차수·금액·보유에서 차감·부족분) + 안내 + 하단 CTA.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import '../meeting/payment_success_screen.dart';

class DepositConfirmScreen extends StatelessWidget {
  const DepositConfirmScreen({super.key});

  // ── 예치 데이터(프로토타입 리터럴, navData 미전달 시 기본값) ──
  static const int _need = 45000; // 예치 금액
  static const int _balance = 128400; // 보유 포인트
  static const String _meeting = '정기 합주 & 뒷풀이';
  static const String _rounds = '1차 · 2차';

  int get _short => (_need - _balance) > 0 ? (_need - _balance) : 0; // 부족분
  int get _fromPoint => _need - _short;

  void _confirm(BuildContext context) {
    MoishoToast.show(context, '${won(_need)}P를 예치했어요. 만남 시각 전까지 취소할 수 있어요.', tone: 'success');
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentSuccessScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '차수 예치 확인', onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 18, T.padScreen, 24),
            children: [
              // A안 — 큰 예치 금액 hero + 분개
              MCard(
                elevation: 'raised',
                radius: T.r2xl,
                padding: const EdgeInsets.all(20),
                accent: T.accent,
                child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Text('예치할 포인트', style: tx(13, FontWeight.w600, T.textMuted, height: 1)),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: tx(36, FontWeight.w700, T.textStrong, ls: -0.02, height: 1, tab: true),
                      children: [
                        TextSpan(text: won(_need)),
                        TextSpan(text: 'P', style: tx(20, FontWeight.w700, T.textMuted, height: 1, tab: true)),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              _breakdown(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(T.rMd)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(LucideIcons.info, size: 15, color: T.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '만남 시각 전까지 자유롭게 취소하면 즉시 환불돼요. 만남 시각이 지나면 예치가 잠겨요.',
                      style: tx(12, FontWeight.w500, T.primary, height: 1.5),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
        _cta(context),
      ]),
    );
  }

  // ── 분개(모임·차수·금액 + 보유에서 차감·부족분) ──
  Widget _breakdown() {
    final rows = [
      ('모임', _meeting),
      ('선택 차수', _rounds),
      ('예치 금액', '${won(_need)}P'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(color: T.gray50, borderRadius: BorderRadius.circular(T.rLg)),
      child: Column(children: [
        for (final (label, value) in rows) ...[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: tx(13, FontWeight.w500, T.textMuted, height: 1)),
            Text(value, style: tx(14, FontWeight.w600, T.textTitle, height: 1, tab: true)),
          ]),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.only(top: 12),
          decoration: const _DashedTopBorder(color: T.borderDefault, width: 1.5),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('보유 포인트에서', style: tx(13, FontWeight.w500, T.textMuted, height: 1)),
              Text('−${won(_fromPoint)}P', style: tx(14, FontWeight.w600, T.textTitle, height: 1, tab: true)),
            ]),
            if (_short > 0) ...[
              const SizedBox(height: 9),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('부족분 충전', style: tx(13, FontWeight.w500, T.amber600, height: 1)), // proto #B45309
                Text('+${won(_short)}P', style: tx(14, FontWeight.w600, T.amber600, height: 1, tab: true)), // proto #B45309
              ]),
            ],
          ]),
        ),
      ]),
    );
  }

  // ── 하단 CTA ──
  Widget _cta(BuildContext context) {
    if (_short > 0) {
      // 부족분 충전 → 카카오페이 레일(KK #FEE500 / KKD #3C1E1E, 충전 레일 한정)
      return StickyBar(
        child: GestureDetector(
          onTap: () => _confirm(context),
          child: Container(
            height: 54,
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFFFEE500), borderRadius: BorderRadius.circular(T.rLg)),
            alignment: Alignment.center,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFF3C1E1E), borderRadius: BorderRadius.circular(5)),
                child: const Text('Pay',
                    style: TextStyle(fontFamily: 'sans-serif', fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFFFEE500), height: 1)),
              ),
              const SizedBox(width: 8),
              Text('${won(_short)}P 충전하고 예치', style: tx(15, FontWeight.w700, const Color(0xFF3C1E1E), height: 1, tab: true)),
            ]),
          ),
        ),
      );
    }
    return StickyBar(
      child: MButton('${won(_need)}P 예치하기', variant: 'primary', size: 'lg', block: true,
          leadingIcon: const Icon(LucideIcons.lock, size: 18, color: T.white), onTap: () => _confirm(context)),
    );
  }
}

/// 점선 상단 보더 — CSS `borderTop: 1.5px dashed` 재현.
class _DashedTopBorder extends Decoration {
  const _DashedTopBorder({required this.color, required this.width});
  final Color color;
  final double width;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _DashedTopPainter(color, width);
}

class _DashedTopPainter extends BoxPainter {
  _DashedTopPainter(this.color, this.strokeWidth);
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final w = configuration.size?.width ?? 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    const dash = 4.0, gap = 4.0;
    var x = offset.dx;
    final y = offset.dy;
    final end = offset.dx + w;
    while (x < end) {
      canvas.drawLine(Offset(x, y), Offset((x + dash).clamp(offset.dx, end), y), paint);
      x += dash + gap;
    }
  }
}
