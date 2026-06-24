// 토스트 — prototype MoishoToastHost. 탭바 위(bottom 80)에서 떠오름.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/tokens.dart';

class MoishoToast {
  MoishoToast._();
  static OverlayEntry? _current;

  static const _toneColor = {
    'success': T.success, 'danger': T.danger, 'accent': T.accent, 'info': T.primary, 'neutral': T.white,
  };

  /// 한 번에 하나. 새 토스트는 이전 것을 교체.
  static void show(BuildContext context, String message, {String tone = 'info', String? title, IconData? icon}) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    _current?.remove();
    _current = null;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message, title: title, tone: tone, icon: icon,
        onDone: () {
          if (_current == entry) {
            entry.remove();
            _current = null;
          }
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final String? title;
  final String tone;
  final IconData? icon;
  final VoidCallback onDone;
  const _ToastWidget({required this.message, this.title, required this.tone, this.icon, required this.onDone});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
  late final Animation<double> _a = CurvedAnimation(parent: _c, curve: const Cubic(0.34, 1.56, 0.64, 1));

  @override
  void initState() {
    super.initState();
    _c.forward();
    Future.delayed(const Duration(milliseconds: 2800), () async {
      if (!mounted) return;
      await _c.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = MoishoToast._toneColor[widget.tone] ?? T.white;
    final media = MediaQuery.of(context);
    return Positioned(
      left: 0, right: 0,
      bottom: 80 + media.padding.bottom,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: T.appMaxWidth - 32),
          child: FadeTransition(
            opacity: _a,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(_a),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                decoration: BoxDecoration(color: T.gray900, borderRadius: BorderRadius.circular(T.rLg), boxShadow: T.shadowPop),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(widget.icon ?? LucideIcons.info, size: 20, color: iconColor),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.title != null) ...[
                            Text(widget.title!, style: tx(14, FontWeight.w700, T.white, height: 1.3)),
                            const SizedBox(height: 2),
                          ],
                          Text(widget.message, style: tx(13, FontWeight.w500, Colors.white.withValues(alpha: 0.82), height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
