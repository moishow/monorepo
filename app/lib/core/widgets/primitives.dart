// 모이쇼 디자인 시스템 프리미티브 — prototype의 DesignSystem_6afed9 컴포넌트를 Flutter로 이식.
// Badge · Avatar · Tag · Button · Card · ProgressBar · NetImage + dday 헬퍼.
import 'package:flutter/material.dart';
import '../theme/tokens.dart';

double mmax(double a, double b) => a > b ? a : b;

// ============================================================
// Badge — 상태/카운트 배지 (soft | solid | dot)
// 알 수 없는 tone 은 neutral 로 폴백 (prototype과 동일 동작).
// ============================================================
class MBadge extends StatelessWidget {
  final String text;
  final String tone; // neutral | blue | purple | success | danger | warning
  final String variant; // soft | solid | dot
  const MBadge(this.text, {super.key, this.tone = 'neutral', this.variant = 'soft'});

  static const _map = <String, Map<String, dynamic>>{
    'neutral': {'soft': [T.gray100, T.textBody], 'solid': [T.gray700, T.white], 'dot': T.gray400},
    'blue': {'soft': [T.primarySoft, T.primary], 'solid': [T.primary, T.white], 'dot': T.primary},
    'purple': {'soft': [T.accentSoft, T.accent], 'solid': [T.accent, T.white], 'dot': T.accent},
    'success': {'soft': [T.successSoft, T.successStrong], 'solid': [T.success, T.white], 'dot': T.success},
    'danger': {'soft': [T.dangerSoft, T.dangerStrong], 'solid': [T.danger, T.white], 'dot': T.danger},
    'warning': {'soft': [T.warningSoft, T.amber600], 'solid': [T.warning, T.white], 'dot': T.warning},
  };

  @override
  Widget build(BuildContext context) {
    final conf = _map[tone] ?? _map['neutral']!;
    if (variant == 'dot') {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: conf['dot'] as Color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: tx(13, FontWeight.w600, T.textBody)),
      ]);
    }
    final pair = (conf[variant] ?? conf['soft']) as List;
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: pair[0] as Color, borderRadius: BorderRadius.circular(T.rPill)),
      child: Text(text, style: tx(12, FontWeight.w700, pair[1] as Color)),
    );
  }
}

// ============================================================
// MAvatar — 이름 이니셜 또는 네트워크 사진. 상태 점 옵션.
// ============================================================
class MAvatar extends StatelessWidget {
  final String name;
  final String? src;
  final double size;
  final String tone; // auto | blue | purple | mint | coral | gray
  final String? status; // online | success | danger
  final bool square;
  const MAvatar({super.key, required this.name, this.src, this.size = 40, this.tone = 'auto', this.status, this.square = false});

  static const _palette = [
    [T.blue100, T.blue700], [T.purple100, T.purple700], [T.mint100, T.mint700],
    [T.coral100, T.coral700], [T.amber100, T.amber600],
  ];
  static const _toneMap = {
    'blue': [T.blue100, T.blue700], 'purple': [T.purple100, T.purple700], 'mint': [T.mint100, T.mint700],
    'coral': [T.coral100, T.coral700], 'gray': [T.gray100, T.gray600],
  };

  @override
  Widget build(BuildContext context) {
    List pair = _toneMap[tone] ?? const [];
    if (pair.isEmpty) {
      var h = 0;
      for (final c in name.runes) {
        h = (h * 31 + c) & 0x7fffffff;
      }
      pair = _palette[name.isEmpty ? 0 : h % _palette.length];
    }
    final initial = name.trim().isEmpty ? '?' : name.characters.take(2).toString();
    final radius = square ? BorderRadius.circular(T.rMd) : BorderRadius.circular(size);
    final circle = ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: size, height: size,
        child: src != null && src!.isNotEmpty
            ? NetImage(url: src, width: size, height: size, fallback: _initials(initial, pair))
            : _initials(initial, pair),
      ),
    );
    if (status == null) return circle;
    final dot = mmax(10, size * 0.28);
    final statusColor = {
      'online': T.success, 'success': T.success, 'danger': T.danger,
    }[status] ?? T.gray400;
    return SizedBox(
      width: size, height: size,
      child: Stack(clipBehavior: Clip.none, children: [
        circle,
        Positioned(
          right: -1, bottom: -1,
          child: Container(
            width: dot, height: dot,
            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle, border: Border.all(color: T.white, width: 2)),
          ),
        ),
      ]),
    );
  }

  Widget _initials(String initial, List pair) => Container(
        color: pair[0] as Color,
        alignment: Alignment.center,
        child: Text(initial, style: tx((size * 0.38).roundToDouble(), FontWeight.w700, pair[1] as Color, ls: -0.02)),
      );
}

// ============================================================
// NetImage — 네트워크 이미지 + 폴백(에러/null 시). 페이드인.
// ============================================================
class NetImage extends StatelessWidget {
  final String? url;
  final double? width, height;
  final BoxFit fit;
  final Widget? fallback;
  const NetImage({super.key, required this.url, this.width, this.height, this.fit = BoxFit.cover, this.fallback});

  @override
  Widget build(BuildContext context) {
    final fb = fallback ?? Container(width: width, height: height, color: T.gray100);
    if (url == null || url!.isEmpty) return fb;
    return Image.network(
      url!,
      width: width, height: height, fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => fb,
      // 로딩 중에도 폴백(이니셜/그라데이션)을 보여줘 빈 회색 디스크 방지.
      // (WebGL 미지원 환경에서 CanvasKit 이미지 디코드 실패해도 폴백이 유지됨)
      frameBuilder: (_, child, frame, wasSync) {
        if (wasSync || frame != null) return child;
        return fb;
      },
    );
  }
}

// ============================================================
// MTag — 관심사 칩(#밴드). r=mini, selectable 토글.
// ============================================================
class MTag extends StatelessWidget {
  final String text;
  final String tone; // neutral | blue | purple | mint | coral
  final bool selected;
  final bool selectable;
  final bool leadingHash;
  final VoidCallback? onTap;
  const MTag(this.text, {super.key, this.tone = 'neutral', this.selected = false, this.selectable = false, this.leadingHash = false, this.onTap});

  static const _tones = {
    'neutral': [T.gray50, T.textBody, T.borderDefault],
    'blue': [T.primarySoft, T.primary, Color(0x00000000)],
    'purple': [T.accentSoft, T.accent, Color(0x00000000)],
    'mint': [T.successSoft, T.successStrong, Color(0x00000000)],
    'coral': [T.dangerSoft, T.dangerStrong, Color(0x00000000)],
  };

  @override
  Widget build(BuildContext context) {
    final t = _tones[tone] ?? _tones['neutral']!;
    final active = selectable && selected;
    final fg = active ? T.white : t[1];
    return GestureDetector(
      onTap: selectable ? onTap : null,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? T.primary : t[0],
          borderRadius: BorderRadius.circular(T.rMini),
          border: Border.all(color: active ? Colors.transparent : t[2]),
        ),
        alignment: Alignment.center,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (leadingHash) Opacity(opacity: 0.6, child: Text('#', style: tx(13, FontWeight.w600, fg))),
          Text(text, style: tx(13, FontWeight.w600, fg)),
        ]),
      ),
    );
  }
}

// ============================================================
// MButton — primary/accent/secondary/ghost/danger/success · sm/md/lg
// ============================================================
class MButton extends StatelessWidget {
  final String label;
  final String variant;
  final String size;
  final bool block;
  final bool disabled;
  final Widget? leadingIcon;
  final VoidCallback? onTap;
  const MButton(this.label, {super.key, this.variant = 'primary', this.size = 'md', this.block = false, this.disabled = false, this.leadingIcon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final sizes = {
      'sm': [36.0, 14.0, 13.0, T.rSm], 'md': [48.0, 18.0, 15.0, T.rMd], 'lg': [56.0, 22.0, 16.0, T.rMd],
    }[size]!;
    final variants = {
      'primary': [T.primary, T.white, Colors.transparent, T.glowBlue],
      'accent': [T.accent, T.white, Colors.transparent, T.glowPurple],
      'secondary': [T.primarySoft, T.primary, Colors.transparent, const <BoxShadow>[]],
      'ghost': [Colors.transparent, T.textBody, T.borderDefault, const <BoxShadow>[]],
      'danger': [T.danger, T.white, Colors.transparent, const <BoxShadow>[]],
      'success': [T.success, T.white, Colors.transparent, const <BoxShadow>[]],
    }[variant]!;
    final fw = size == 'sm' ? FontWeight.w600 : FontWeight.w700;
    final child = Container(
      height: sizes[0],
      width: block ? double.infinity : null,
      padding: EdgeInsets.symmetric(horizontal: sizes[1]),
      decoration: BoxDecoration(
        color: variants[0] as Color,
        borderRadius: BorderRadius.circular(sizes[3]),
        border: Border.all(color: variants[2] as Color),
        boxShadow: disabled ? const [] : variants[3] as List<BoxShadow>,
      ),
      alignment: Alignment.center,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (leadingIcon != null) ...[leadingIcon!, const SizedBox(width: 8)],
        Text(label, style: tx(sizes[2], fw, variants[1] as Color)),
      ]),
    );
    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: GestureDetector(onTap: disabled ? null : onTap, child: child),
    );
  }
}

// ============================================================
// MCard — flat(sunken) | raised(shadow) | outline. accent 좌측 바.
// ============================================================
class MCard extends StatelessWidget {
  final Widget child;
  final String elevation; // flat | raised | outline
  final double radius;
  final EdgeInsets padding;
  final Color? accent;
  final VoidCallback? onTap;
  final Color? borderColor;
  const MCard({
    super.key, required this.child, this.elevation = 'raised', this.radius = T.rXl,
    this.padding = const EdgeInsets.all(20), this.accent, this.onTap, this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = elevation == 'flat' ? T.surfaceSunken : T.surfaceCard;
    final shadow = elevation == 'raised' ? T.shadowCard : const <BoxShadow>[];
    final border = borderColor != null
        ? Border.all(color: borderColor!, width: 1.5)
        : (elevation == 'outline' ? Border.all(color: T.borderDefault) : null);
    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(radius), boxShadow: shadow, border: border),
      child: child,
    );
    if (accent != null) {
      content = Stack(children: [
        content,
        Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 4, color: accent)),
      ]);
    }
    content = ClipRRect(borderRadius: BorderRadius.circular(radius), child: content);
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }
}

// ============================================================
// ProgressBar — 펀딩 달성률 게이지. 100% → 블루→퍼플 그라데이션.
// ============================================================
class ProgressBar extends StatelessWidget {
  final double value; // 0–100
  final double height;
  final String tone; // primary | accent | success | gradient
  const ProgressBar({super.key, required this.value, this.height = 12, this.tone = 'primary'});

  @override
  Widget build(BuildContext context) {
    final pct = value.clamp(0, 100).toDouble();
    final done = pct >= 100;
    final solid = {'primary': T.primary, 'accent': T.accent, 'success': T.success}[tone];
    return ClipRRect(
      borderRadius: BorderRadius.circular(T.rPill),
      child: Container(
        height: height,
        color: T.gray100,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: pct / 100,
            child: Container(
              decoration: BoxDecoration(
                color: (done || tone == 'gradient') ? null : solid,
                gradient: (done || tone == 'gradient')
                    ? const LinearGradient(colors: [T.blue500, T.purple500])
                    : null,
                borderRadius: BorderRadius.circular(T.rPill),
                boxShadow: done ? T.glowPurple : const [],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// dday 시맨틱 — 긴급도 색. (prototype window.moishoDday)
//   D-1↓ 빨강 · D-2~3 주황 · D-4~7 파랑 · D-8+ 회색
// ============================================================
({Color bg, Color color, String label}) ddayInfo(Object dday) {
  final label = dday is int ? 'D-$dday' : dday.toString();
  final n = dday is int ? dday : int.tryParse(label.replaceAll(RegExp(r'[^0-9]'), ''));
  if (n == null || n <= 1) return (bg: T.coral50, color: T.coral600, label: label);
  if (n <= 3) return (bg: T.amber50, color: T.amber600, label: label);
  if (n <= 7) return (bg: T.primarySoft, color: T.primary, label: label);
  return (bg: T.gray100, color: T.textMuted, label: label);
}
