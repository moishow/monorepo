// 앱 셸 크롬 — prototype Shell.jsx (MoishoStatusBar/AppHeader/TabBar) 이식.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/tokens.dart';

/// 상단 상태바 — 9:41 + 신호/와이파이/배터리. dark=true 면 흰색(영상 위).
/// 실기기 노치 대응: 상단 안전영역 만큼 추가 패딩(웹 데스크탑은 0 → 정확히 44).
class MoishoStatusBar extends StatelessWidget {
  final bool dark;
  const MoishoStatusBar({super.key, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final c = dark ? T.white : T.textStrong;
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.only(top: top),
      height: 44 + top,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('9:41', style: tx(14, FontWeight.w700, c, ls: 0, height: 1).copyWith(fontFeatures: kTnum)),
            Row(children: [
              Icon(LucideIcons.signal, size: 15, color: c),
              const SizedBox(width: 5),
              Icon(LucideIcons.wifi, size: 15, color: c),
              const SizedBox(width: 5),
              Icon(LucideIcons.batteryFull, size: 17, color: c),
            ]),
          ],
        ),
      ),
    );
  }
}

/// 앱 헤더 — 52px, 타이틀 17/bold, 좌측 back, 우측 액션 슬롯.
class MoishoAppHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final bool transparent;
  const MoishoAppHeader({super.key, required this.title, this.onBack, this.actions = const [], this.transparent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: T.padScreen),
      decoration: BoxDecoration(
        color: transparent ? Colors.transparent : T.white,
        border: transparent ? null : const Border(bottom: BorderSide(color: T.borderSubtle)),
      ),
      child: Row(
        children: [
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.only(right: 4, top: 4, bottom: 4),
                child: Icon(LucideIcons.arrowLeft, size: 23, color: T.textStrong),
              ),
            ),
          Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(17, FontWeight.w700, T.textStrong, height: 1))),
          ...actions,
        ],
      ),
    );
  }
}

/// 스크롤 본문 — 좌우 20 패딩 + 하단 여백. 탭바 안전영역 고려.
class ScrollBody extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final ScrollController? controller;
  const ScrollBody({super.key, required this.children, this.padding = const EdgeInsets.fromLTRB(T.padScreen, 0, T.padScreen, 24), this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: padding,
      physics: const BouncingScrollPhysics(),
      children: children,
    );
  }
}

/// 섹션 라벨 — 대문자 트래킹된 작은 헤더.
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text.toUpperCase(),
            style: TextStyle(fontFamily: kFont, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.66, color: T.textDisabled, height: 1)),
      );
}

/// 하단 고정 CTA 바.
class StickyBar extends StatelessWidget {
  final Widget child;
  const StickyBar({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(T.padScreen, 12, T.padScreen, 10),
        decoration: const BoxDecoration(color: T.white, border: Border(top: BorderSide(color: T.borderSubtle))),
        child: SafeArea(top: false, child: child),
      );
}

/// 탭바 — 5탭. 쇼츠(2)는 중앙 강조 그라데이션 버튼. 채팅(3) 활성 시 퍼플.
class MoishoTabBar extends StatelessWidget {
  final int active;
  final ValueChanged<int> onTap;
  const MoishoTabBar({super.key, required this.active, required this.onTap});

  static const _tabs = [
    (icon: LucideIcons.search, label: '탐색'),
    (icon: LucideIcons.house, label: '홈'),
    (icon: LucideIcons.clapperboard, label: '쇼츠'), // special
    (icon: LucideIcons.messageCircle, label: '채팅'),
    (icon: LucideIcons.user, label: '마이'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: T.white, border: Border(top: BorderSide(color: T.borderSubtle))),
      padding: const EdgeInsets.only(bottom: 8),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: List.generate(5, (i) {
              final on = active == i;
              final tab = _tabs[i];
              if (i == 2) {
                // 쇼츠 — 중앙 강조 버튼
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 46, height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                              colors: on ? const [Color(0xFF3D7DFA), T.accent] : const [Color(0xFF1A1A2E), Color(0xFF3D7DFA)],
                            ),
                            borderRadius: BorderRadius.circular(T.rMd),
                            boxShadow: [BoxShadow(color: const Color(0xFF3D7DFA).withValues(alpha: on ? 0.45 : 0.25), blurRadius: on ? 10 : 6, offset: const Offset(0, 2))],
                          ),
                          child: Icon(tab.icon, size: 20, color: T.white),
                        ),
                        const SizedBox(height: 2),
                        Text(tab.label, style: TextStyle(fontFamily: kFont, fontSize: 10, height: 1, fontWeight: on ? FontWeight.w700 : FontWeight.w500, color: on ? T.primary : T.gray400)),
                      ],
                    ),
                  ),
                );
              }
              final isChat = i == 3;
              final color = on ? (isChat ? T.accent : T.primary) : T.gray400;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(tab.icon, size: 22, color: color),
                      const SizedBox(height: 3),
                      Text(tab.label, style: TextStyle(fontFamily: kFont, fontSize: 10, height: 1, fontWeight: on ? FontWeight.w700 : FontWeight.w500, color: color)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
