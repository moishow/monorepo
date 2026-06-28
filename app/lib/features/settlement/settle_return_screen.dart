// 영수증 증빙·잔액 반납 — prototype SettleReturnScreen (5b8ddc3c:464).
// 결정2(OCR 잔여리스크) 반영: OCR 금액은 '제안'일 뿐 — 총무가 원본과 대조해 직접 수정,
// 반납액은 수정값에서 재계산. 원본 영수증 사진은 항상 노출(눈대조 강제).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static const int _ocrAmount = 412000; // OCR 자동 인식값 = 초기 '제안'(고정 아님)

  // 총무가 원본과 대조해 직접 확정하는 실지출. 반납액은 여기서 파생.
  // 머니수학(분개·반납 확정)은 백엔드 몫 — 여기선 표시/재계산만.
  int _spent = _ocrAmount;
  late final TextEditingController _spentCtl;

  int get _remain => _withdrawn - _spent;
  bool get _over => _spent > _withdrawn;
  bool get _edited => _spent != _ocrAmount;

  static const _ocrRows = [
    ('가게명', '하남돼지집 영통점'),
    ('결제 일시', '2026.06.15 21:34'),
  ];

  @override
  void initState() {
    super.initState();
    _spentCtl = TextEditingController(text: won(_ocrAmount));
  }

  @override
  void dispose() {
    _spentCtl.dispose();
    super.dispose();
  }

  void _onAmountChanged(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    setState(() => _spent = digits.isEmpty ? 0 : int.parse(digits));
  }

  @override
  Widget build(BuildContext context) {
    final canReturn = _scanned && !_over;
    final ctaLabel = !_scanned
        ? '영수증을 먼저 올려주세요'
        : _over
            ? '실지출이 출금액을 초과했어요'
            : '${won(_remain)}P 반납하고 정산';

    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '영수증 증빙 · 잔액 반납', onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const SectionLabel('영수증 증빙'),
              if (!_scanned)
                _dropzone()
              else ...[
                _receiptPhoto(), // 원본 사진 항상 노출
                const SizedBox(height: 12),
                _ocrCard(), // OCR 메타데이터(가게·일시) — 금액은 아래에서 확정
              ],
              const SizedBox(height: 18),

              // 실지출 — OCR값으로 '고정'하지 않고 직접 수정 가능
              const SectionLabel('실지출 금액 — 원본과 비교해 확인하세요'),
              _realSpent(),
              const SizedBox(height: 16),

              // 반납 계산(실지출 수정 시 재계산)
              _returnCalc(),
              const SizedBox(height: 14),
              _compareNote(),
            ],
          ),
        ),
        StickyBar(
          child: MButton(ctaLabel,
              variant: 'primary', size: 'lg', block: true,
              disabled: !canReturn,
              leadingIcon: const Icon(LucideIcons.undo2, size: 18, color: T.white),
              onTap: canReturn ? _onReturn : null),
        ),
      ]),
    );
  }

  void _onReturn() {
    final note = _edited ? ' (OCR값에서 직접 수정함)' : '';
    MoishoToast.show(context, '${won(_remain)}P를 반납했어요$note. 부원에게 자동 정산돼요.',
        tone: 'success', title: '잔액 반납 완료');
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
            Text('금액·가게·일시를 자동으로 읽어요 (인식 후 직접 확인)', style: tx(12, FontWeight.w500, T.textMuted, height: 1.4)),
          ]),
        ),
      );

  // ── 원본 영수증 사진(항상 노출) ──
  Widget _receiptPhoto() => GestureDetector(
        onTap: () => MoishoToast.show(context, '원본 영수증을 크게 봤어요. 금액·가게·일시를 직접 확인하세요.', tone: 'neutral'),
        behavior: HitTestBehavior.opaque,
        child: MCard(
          elevation: 'flat',
          radius: T.rXl,
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // 사진 썸네일(목업 플레이스홀더 — 실제 캡처 자리)
            Container(
              width: 64, height: 84,
              decoration: BoxDecoration(
                color: T.surfaceSunken,
                borderRadius: BorderRadius.circular(T.rMd),
                border: Border.all(color: T.borderDefault),
              ),
              alignment: Alignment.center,
              child: const Icon(LucideIcons.receipt, size: 30, color: T.textFaint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('원본 영수증', style: tx(14, FontWeight.w700, T.textStrong, height: 1)),
                  const SizedBox(width: 6),
                  const MBadge('항상 표시', tone: 'neutral', variant: 'soft'),
                ]),
                const SizedBox(height: 6),
                Text('OCR이 읽은 실제 사진이에요. 금액이 맞는지 눈으로 직접 비교하세요.',
                    style: tx(12, FontWeight.w500, T.textMuted, height: 1.45)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(LucideIcons.maximize2, size: 13, color: T.primary),
                  const SizedBox(width: 4),
                  Text('탭하여 크게 보기', style: tx(12, FontWeight.w600, T.primary, height: 1)),
                ]),
              ]),
            ),
          ]),
        ),
      );

  // ── OCR 인식 메타데이터(가게·일시) — 금액은 편집 필드로 분리 ──
  Widget _ocrCard() => MCard(
        elevation: 'flat',
        radius: T.rXl,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(LucideIcons.scanLine, size: 16, color: T.primary),
            const SizedBox(width: 8),
            Text('OCR 자동 인식', style: tx(13, FontWeight.w700, T.textStrong, height: 1)),
            const SizedBox(width: 8),
            const MBadge('금액 확인 필요', tone: 'warning', variant: 'soft'),
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
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: T.borderSubtle))),
            child: Row(children: [
              const Icon(LucideIcons.info, size: 13, color: T.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text('자동 인식 금액은 아래에 미리 채워 뒀어요. 원본과 다르면 직접 수정하세요.',
                    style: tx(12, FontWeight.w500, T.textMuted, height: 1.4)),
              ),
            ]),
          ),
        ]),
      );

  // ── 실지출 금액(편집 가능 · OCR값 프리필) ──
  Widget _realSpent() {
    if (!_scanned) {
      // 스캔 전: 입력 대기 플레이스홀더
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: T.white,
          borderRadius: BorderRadius.circular(T.rLg),
          border: Border.all(color: T.borderSubtle),
        ),
        child: Row(children: [
          const Icon(LucideIcons.pencil, size: 15, color: T.textDisabled),
          const SizedBox(width: 8),
          Text('영수증을 올리면 자동 입력 · 직접 수정 가능', style: tx(13, FontWeight.w500, T.textMuted, height: 1)),
          const Spacer(),
          Text('—원', style: tx(18, FontWeight.w700, T.textDisabled, height: 1, tab: true)),
        ]),
      );
    }
    final accent = _over ? T.danger : T.primary;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: T.white,
          borderRadius: BorderRadius.circular(T.rLg),
          border: Border.all(color: accent, width: 1.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(LucideIcons.pencil, size: 15, color: accent),
            const SizedBox(width: 8),
            Text('실지출 금액 (직접 수정 가능)', style: tx(13, FontWeight.w600, T.textBody, height: 1)),
            const Spacer(),
            if (_edited) const MBadge('수정됨', tone: 'blue', variant: 'soft'),
          ]),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: TextField(
                controller: _spentCtl,
                onChanged: _onAmountChanged,
                keyboardType: TextInputType.number,
                inputFormatters: [_ThousandsFormatter()],
                textAlign: TextAlign.right,
                cursorColor: accent,
                style: tx(26, FontWeight.w700, _over ? T.danger : T.textStrong, height: 1, ls: -0.02, tab: true),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: '0',
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text('원', style: tx(16, FontWeight.w700, T.textBody, height: 1.3)),
          ]),
        ]),
      ),
      const SizedBox(height: 8),
      Text(
        _over
            ? '실지출이 출금액(${won(_withdrawn)}원)을 넘었어요. 영수증 금액을 다시 확인하세요.'
            : '원본 영수증의 합계와 같은지 확인하고, 다르면 위 금액을 직접 고치세요.',
        style: tx(12, FontWeight.w500, _over ? T.danger : T.textMuted, height: 1.4),
      ),
    ]);
  }

  // ── 반납 계산(실지출에서 재계산) ──
  Widget _returnCalc() {
    final rows = <(String, int)>[
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
                _scanned ? '${value < 0 ? '−' : ''}${won(value.abs())}원' : '—원',
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
            Text(
              !_scanned ? '—P' : '${_remain < 0 ? '−' : ''}${won(_remain.abs())}P',
              style: tx(22, FontWeight.w700, _over ? T.danger : T.primary, height: 1, tab: true),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── 하단 안내(눈대조 강제) ──
  Widget _compareNote() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: T.warningSoft, borderRadius: BorderRadius.circular(T.rMd)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(LucideIcons.scanEye, size: 15, color: T.amber600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '영수증 원본과 금액을 비교해 주세요. OCR이 잘못 읽을 수 있어요 — 실제 결제 금액과 다르면 위에서 직접 수정하면 반납액이 다시 계산돼요.',
              style: tx(12, FontWeight.w500, T.amber600, height: 1.5),
            ),
          ),
        ]),
      );
}

/// 천단위 콤마 입력 포매터 — 편집 중 won() 포맷 유지, 커서는 끝으로.
class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }
    final formatted = won(int.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
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
