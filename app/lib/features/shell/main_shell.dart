// 메인 셸 — 5탭 IndexedStack + MoishoTabBar. 기본 탭 = 홈(index 1).
import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../discover/discover_screen.dart';
import '../home/show_feed_screen.dart';
import '../showts/showts_screen.dart';
import '../chat/dm_list_screen.dart';
import '../my/my_page_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 1; // 홈

  static const _screens = [
    DiscoverScreen(),
    ShowFeedScreen(),
    ShowtsScreen(),
    DmListScreen(),
    MyPageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      resizeToAvoidBottomInset: false,
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: MoishoTabBar(active: _tab, onTap: (i) => setState(() => _tab = i)),
    );
  }
}
