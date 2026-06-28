// 차수 예치 확인 — prototype DepositConfirmScreen (5b8ddc3c:228).
// 예치 hero + 분개 + 시간별 취소 위약금 안내(결정1) + 하단 CTA.
// 위약금 스케줄은 백엔드 정책이 정본 — 목업은 표시/시뮬만(money math는 백엔드 몫).
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

  // 시간별 취소 위약금 티어(결정1) — meeting_detail의 시트와 byte-identical 유지.
  static const _penaltyTiers = [
    (label: '신청 마감 ~ 24시간 전', fromHrs: 24, rate: 0),
    (label: '24시간 ~ 6시간 전', fromHrs: 6, rate: 50),
    (label: '6시간 전 ~ 만남 시각', fromHrs: 0, rate: 100),
  ];
  static const int _hrsToMeeting = 72; // 현재 시뮬 시점(만남까지 D-3) — 24h 이전 구간

  int get _short => (_need - _balance) > 0 ? (_need - _balance) : 0; // 부족분
  int get _fromPoint => _need - _short;

  int get _tierIdx {
    for (var i = 0; i < _penaltyTiers.length; i++) {
      if (_hrsToMeeting >= _penaltyTiers[i].fromHrs) return i;
    }
    return _penaltyTiers.length - 1;
  }

  int get _penalty => (_need * _penaltyTiers[_tierIdx].rate / 100).round(); // 정수 원 보장
  int get _refund => _need - _penalty;

  void _confirm(BuildContext context) {
    // 결정1: '자유 취소' 제거 — 마감 24h 전 전액 환불, 이후 시간별 위약금 차감.
    MoishoToast.show(context, '${won(_need)}P를 예치했어요. 마감 24시간 전까진 전액 환불, 이후엔 시간별 위약금이 차감돼요.',
        tone: 'success');
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
              const SectionLabel('취소 위약금 안내'),
              _penaltyCard(),
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

  // ── 취소 위약금 안내(시간별 티어 + 환불 예상 + 공동비용 충당) ──
  Widget _penaltyCard() => MCard(
        elevation: 'flat',
        radius: T.rXl,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(LucideIcons.clock, size: 16, color: T.textBody),
            const SizedBox(width: 8),
            Text('취소 시점별 위약금', style: tx(13, FontWeight.w700, T.textStrong, height: 1)),
            const Spacer(),
            MBadge(_penalty == 0 ? '지금 취소 시 위약금 0' : '지금 ${_penaltyTiers[_tierIdx].rate}%',
                tone: _penalty == 0 ? 'success' : 'warning', variant: 'soft'),
          ]),
          const SizedBox(height: 6),
          Text('신청 마감 후 남은 시간에 따라 위약금이 달라져요. 마감 24시간 전까진 전액 환불돼요.',
              style: tx(12, FontWeight.w500, T.textMuted, height: 1.45)),
          const SizedBox(height: 12),
          for (var i = 0; i < _penaltyTiers.length; i++) _tierRow(i),
          const SizedBox(height: 4),
          // 환불 예상(예치 − 위약금)
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const _DashedTopBorder(color: T.borderDefault, width: 1.5),
            child: Column(children: [
              _calcRow('예치 금액', '${won(_need)}P', T.textTitle),
              const SizedBox(height: 8),
              _calcRow('위약금 (현재 ${_penaltyTiers[_tierIdx].rate}%)', '−${won(_penalty)}P',
                  _penalty == 0 ? T.textMuted : T.danger),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('환불 예상액', style: tx(14, FontWeight.w700, T.textTitle, height: 1)),
                Text('${won(_refund)}P', style: tx(18, FontWeight.w700, T.primary, height: 1, tab: true)),
              ]),
            ]),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: T.surfaceSunken, borderRadius: BorderRadius.circular(T.rMd)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(LucideIcons.users, size: 14, color: T.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text('위약금은 남은 부원들의 그룹 공동비용에 충당돼요. 플랫폼·총무에 귀속되지 않아요(0원).',
                    style: tx(12, FontWeight.w500, T.textBody, height: 1.45)),
              ),
            ]),
          ),
        ]),
      );

  // ── 위약금 티어 한 줄(현재 구간 하이라이트) ──
  Widget _tierRow(int i) {
    final t = _penaltyTiers[i];
    final isCurrent = i == _tierIdx;
    final rateColor = t.rate == 0
        ? T.successStrong
        : t.rate == 100
            ? T.danger
            : T.amber600;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrent ? T.primarySoft : T.surfaceSunken,
        borderRadius: BorderRadius.circular(T.rMd),
        border: isCurrent ? Border.all(color: T.primary, width: 1.5) : null,
      ),
      child: Row(children: [
        if (isCurrent) ...[
          const Icon(LucideIcons.arrowRight, size: 13, color: T.primary),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(t.label,
              style: tx(13, isCurrent ? FontWeight.w700 : FontWeight.w500, isCurrent ? T.textStrong : T.textBody, height: 1.2)),
        ),
        Text('위약금 ${t.rate}%', style: tx(13, FontWeight.w700, rateColor, height: 1, tab: true)),
      ]),
    );
  }

  Widget _calcRow(String label, String value, Color valueColor) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: tx(13, FontWeight.w500, T.textMuted, height: 1)),
          Text(value, style: tx(14, FontWeight.w600, valueColor, height: 1, tab: true)),
        ],
      );

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
