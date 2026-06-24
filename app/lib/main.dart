// 모이쇼 (Moisho) — 앱 진입점. 라우터 + 테마 + 폰 프레임만.
// 화면은 features/* 에, 토큰·공용 위젯은 core/* 에. (CLAUDE.md §3·§8 feature-first)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/tokens.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/onboarding_screen.dart';
import 'features/shell/main_shell.dart';

void main() => runApp(const ProviderScope(child: MoishoApp()));

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
    GoRoute(path: '/app', builder: (_, _) => const MainShell()),
  ],
);

class MoishoApp extends StatelessWidget {
  const MoishoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '모이쇼',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: _router,
      builder: (context, child) => _PhoneFrame(child: child ?? const SizedBox()),
    );
  }
}

/// 데스크톱/넓은 화면에선 390px 모바일 캔버스로 레터박싱(폰은 풀폭).
class _PhoneFrame extends StatelessWidget {
  final Widget child;
  const _PhoneFrame({required this.child});
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w <= 480) return child;
    return ColoredBox(
      color: const Color(0xFF11131A),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: SizedBox(width: T.appMaxWidth, height: T.appHeight, child: child),
        ),
      ),
    );
  }
}
