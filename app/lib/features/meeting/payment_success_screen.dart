// 결제(예치) 완료 — prototype PaymentSuccessScreen (6c5465b6:312).
// 또로롱 체크 애니메이션 + 참석 신청 완료 안내 + 예치 내역 카드 + 동아리로 돌아가기.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../club/club_room_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  // 프로토타입: setTimeout(()=>setAnimated(true),100) + transition 0.4s ease-spring.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final Animation<double> _a =
      CurvedAnimation(parent: _c, curve: const Cubic(0.34, 1.56, 0.64, 1));

  // ── 예치 내역(프로토타입 리터럴) ──
  static const _rows = [
    ('모임', '정기 대관 연습 및 뒷풀이'),
    ('예치 금액', '40,000원'),
    ('처리 시각', '2026.06.14 17:52'),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.white,
      body: Column(children: [
        const MoishoStatusBar(),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: T.padScreen),
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 또로롱 체크 애니메이션
                  Center(child: _checkCircle()),
                  const SizedBox(height: 28),
                  Text(
                    '참석 신청 완료! 🎉',
                    textAlign: TextAlign.center,
                    style: tx(28, FontWeight.w700, T.textStrong, ls: -0.02, height: 1.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '40,000원 이체가 안전하게 완료됐어요',
                    textAlign: TextAlign.center,
                    style: tx(16, FontWeight.w600, T.textMuted, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '참석자 명단에\n바로 반영됐어요 ✅',
                    textAlign: TextAlign.center,
                    style: tx(14, FontWeight.w500, T.textMuted, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  _detailCard(),
                  const SizedBox(height: 28),
                  MButton(
                    '동아리로 돌아가기',
                    variant: 'primary',
                    size: 'lg',
                    block: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ClubRoomScreen()),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ── 스프링 체크 원 ──
  Widget _checkCircle() => AnimatedBuilder(
        animation: _a,
        builder: (_, _) {
          final t = _a.value.clamp(0.0, 1.0);
          final scale = 0.6 + 0.4 * t;
          final bg = Color.lerp(T.successSoft, T.success, t)!;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                // 프로토타입: animated 시 0 0 0 16px var(--color-success-soft) 링.
                boxShadow: t > 0
                    ? [
                        BoxShadow(
                          color: T.successSoft.withValues(alpha: t),
                          blurRadius: 0,
                          spreadRadius: 16 * t,
                        ),
                      ]
                    : const [],
              ),
              alignment: Alignment.center,
              child: const Icon(LucideIcons.check, size: 52, color: T.white),
            ),
          );
        },
      );

  // ── 예치 내역 카드 ──
  Widget _detailCard() => MCard(
        elevation: 'flat',
        radius: T.rXl,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: Column(
          children: [
            for (final (label, value) in _rows)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: T.borderSubtle)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: tx(13, FontWeight.w500, T.textMuted, height: 1)),
                    Text(value, style: tx(13, FontWeight.w700, T.textStrong, height: 1, tab: true)),
                  ],
                ),
              ),
          ],
        ),
      );
}
