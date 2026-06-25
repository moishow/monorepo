// 영수증 증빙·잔액 반납 — prototype SettleReturnScreen (5b8ddc3c:464).
// OCR 영수증 업로드 → 인식 결과 → 실지출 고정 → 반납 잔액 계산 → 반납하고 정산.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import 'settle_auto_screen.dart';

class SettleReturnScreen extends StatefulWidget {
  const SettleReturnScreen({super.key});

  @override
  State<SettleReturnScreen> createState() => _SettleReturnScreenState();
}

class _SettleReturnScreenState extends State<SettleReturnScreen> {
  bool _scanned = false;

  static const int _withdrawn = 480000;
  static const int _spent = 412000;
  int get _remain => _withdrawn - _spent;

  static const _ocrRows = [
    ('가게명', '하남돼지집 영통점'),
    ('결제 일시', '2026.06.15 21:34'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '영수증 증빙 · 잔액 반납', onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const SectionLabel('영수증 OCR'),
              if (!_scanned) _dropzone() else _ocrCard(),
              const SizedBox(height: 16),

              // 실지출 (OCR 강제 매핑)
              const SectionLabel('실지출 금액 (OCR 자동 입력)'),
              _realSpent(),
              const SizedBox(height: 16),

              // 반납 계산
              _returnCalc(),
            ],
          ),
        ),
        StickyBar(
          child: MButton('${won(_remain)}P 반납하고 정산', variant: 'primary', size: 'lg', block: true,
              disabled: !_scanned,
              leadingIcon: const Icon(LucideIcons.undo2, size: 18, color: T.white),
              onTap: _scanned ? _onReturn : null),
        ),
      ]),
    );
  }

  void _onReturn() {
    MoishoToast.show(context, '${won(_remain)}P를 반납했어요. 부원에게 자동 정산돼요.', tone: 'success', title: '잔액 반납 완료');
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettleAutoScreen()));
  }

  // ── 영수증 업로드 드롭존(미스캔) ──
  Widget _dropzone() => GestureDetector(
        onTap: () => setState(() => _scanned = true),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
          decoration: const _DashedBoxBorder(color: T.borderDefault, width: 1.5, radius: T.rXl, fill: T.white),
          child: Column(children: [
            Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(color: T.primarySoft, shape: BoxShape.circle),
              child: const Icon(LucideIcons.camera, size: 22, color: T.primary),
            ),
            const SizedBox(height: 8),
            Text('영수증 촬영 / 업로드', style: tx(14, FontWeight.w700, T.textTitle, height: 1)),
            const SizedBox(height: 8),
            Text('금액·가게·일시를 자동으로 읽어요', style: tx(12, FontWeight.w500, T.textMuted, height: 1.4)),
          ]),
        ),
      );

  // ── OCR 인식 결과 카드(스캔 후) ──
  Widget _ocrCard() => MCard(
        elevation: 'flat',
        radius: T.rXl,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(LucideIcons.scanLine, size: 16, color: T.successStrong),
            const SizedBox(width: 8),
            Text('OCR 인식 완료', style: tx(13, FontWeight.w700, T.successStrong, height: 1)),
            const SizedBox(width: 8),
            const MBadge('신뢰도 98%', tone: 'success', variant: 'soft'),
          ]),
          const SizedBox(height: 12),
          for (var i = 0; i < _ocrRows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: i == 0 ? null : const BoxDecoration(border: Border(top: BorderSide(color: T.borderSubtle))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(_ocrRows[i].$1, style: tx(13, FontWeight.w500, T.textMuted, height: 1)),
                Text(_ocrRows[i].$2, style: tx(13, FontWeight.w600, T.textTitle, height: 1)),
              ]),
            ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: T.borderSubtle))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('인식 금액', style: tx(13, FontWeight.w500, T.textMuted, height: 1)),
              Text('${won(_spent)}원', style: tx(13, FontWeight.w600, T.textTitle, height: 1, tab: true)),
            ]),
          ),
        ]),
      );

  // ── 실지출 금액(OCR 인식값으로 고정) ──
  Widget _realSpent() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: _scanned ? T.gray50 : T.white,
          borderRadius: BorderRadius.circular(T.rLg),
          border: Border.all(color: T.borderSubtle),
        ),
        child: Row(children: [
          const Icon(LucideIcons.lock, size: 15, color: T.textDisabled),
          const SizedBox(width: 8),
          Text('영수증 인식값으로 고정', style: tx(13, FontWeight.w500, T.textMuted, height: 1)),
          const Spacer(),
          Text(
            _scanned ? '${won(_spent)}원' : '—원',
            style: tx(18, FontWeight.w700, _scanned ? T.textStrong : T.textDisabled, height: 1, tab: true),
          ),
        ]),
      );

  // ── 반납 계산 ──
  Widget _returnCalc() {
    const rows = [
      ('출금액', _withdrawn),
      ('실지출', -_spent),
    ];
    return MCard(
      elevation: 'flat',
      radius: T.rXl,
      padding: const EdgeInsets.all(18),
      child: Column(children: [
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(label, style: tx(13, FontWeight.w500, T.textMuted, height: 1)),
              Text(
                '${value < 0 ? '−' : ''}${won(value.abs())}원',
                style: tx(14, FontWeight.w600, T.textTitle, height: 1, tab: true),
              ),
            ]),
          ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.only(top: 12),
          decoration: const _DashedTopBorder(color: T.borderDefault, width: 1.5),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text('반납할 잔액', style: tx(14, FontWeight.w600, T.textTitle, height: 1)),
            Text('${won(_remain)}P', style: tx(22, FontWeight.w700, T.primary, height: 1, tab: true)),
          ]),
        ),
      ]),
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

/// 점선 사각 보더 — CSS `border: 1.5px dashed` + radius 재현(영수증 드롭존).
class _DashedBoxBorder extends Decoration {
  const _DashedBoxBorder({required this.color, required this.width, required this.radius, required this.fill});
  final Color color;
  final double width;
  final double radius;
  final Color fill;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _DashedBoxPainter(color, width, radius, fill);
}

class _DashedBoxPainter extends BoxPainter {
  _DashedBoxPainter(this.color, this.strokeWidth, this.radius, this.fill);
  final Color color;
  final double strokeWidth;
  final double radius;
  final Color fill;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size ?? Size.zero;
    final rect = offset & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    // 배경 채움
    canvas.drawRRect(rrect, Paint()..color = fill);
    // 점선 테두리
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final path = Path()..addRRect(rrect);
    const dash = 4.0, gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, (d + dash).clamp(0, metric.length)), paint);
        d += dash + gap;
      }
    }
  }
}
