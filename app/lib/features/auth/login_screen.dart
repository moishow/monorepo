// 로그인 — 소셜 OAuth 3종. 버튼은 폭·높이 통일(full-width), 공식 브랜드 로고 사용.
// 로고는 좌측 고정 슬롯, 라벨은 중앙 정렬 → 텍스트 길이와 무관하게 균일한 외형.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/data/session.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/brand_logos.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;

    void go(String provider) {
      ref.read(sessionProvider.notifier).loginAs(provider);
      final s = ref.read(sessionProvider);
      context.go(s.needsOnboarding ? '/onboarding' : '/app');
    }

    Widget social({
      required String provider,
      required String label,
      required Color bg,
      required Color fg,
      required Widget logo,
      Color? border,
    }) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => go(provider),
            child: Container(
              height: 54,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(T.rLg),
                border: border == null ? null : Border.all(color: border),
              ),
              child: Row(children: [
                SizedBox(width: 20, height: 20, child: Center(child: logo)),
                Expanded(child: Text(label, textAlign: TextAlign.center, style: tx(16, FontWeight.w700, fg))),
                const SizedBox(width: 20), // 좌측 로고 폭만큼 균형 → 라벨 시각적 중앙 정렬
              ]),
            ),
          ),
        );

    return Scaffold(
      backgroundColor: T.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Column(
            children: [
              // 프로토타입: 브랜드+버튼을 하나의 묶음으로 세로 중앙 배치, 푸터만 하단 고정.
              const Spacer(flex: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(gradient: T.gradBrand, borderRadius: BorderRadius.circular(T.rMd)),
                    child: const Icon(Icons.adjust_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 8),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: '모이', style: tt.displaySmall?.copyWith(color: T.textTitle)),
                    TextSpan(text: '쇼', style: tt.displaySmall?.copyWith(color: T.accent)),
                  ])),
                ],
              ),
              const SizedBox(height: 14),
              Text('"모이고, 소통하고, 쇼하라!"', style: tt.bodyMedium?.copyWith(color: T.textMuted)),
              const SizedBox(height: 36), // 브랜드→버튼 고정 간격(프로토타입)
              social(
                provider: 'kakao',
                label: '카카오톡으로 3초 만에 시작하기',
                bg: const Color(0xFFFEE500),
                fg: const Color(0xD9000000), // 카카오 가이드: 라벨 #000 85%
                logo: const KakaoLogo(),
              ),
              social(
                provider: 'apple',
                label: '애플 계정으로 로그인',
                bg: T.textStrong,
                fg: Colors.white,
                logo: const Icon(Icons.apple, size: 22, color: Colors.white),
              ),
              social(
                provider: 'google',
                label: '구글 계정으로 로그인',
                bg: T.white,
                fg: T.textBody,
                logo: const GoogleLogo(),
                border: T.borderDefault,
              ),
              const Spacer(flex: 5), // 버튼 묶음 아래 가변 공간 → 푸터 하단 고정·그룹 중앙화
              Text('이용약관 · 개인정보처리방침 · 금융거래 가이드라인',
                  style: tt.bodySmall?.copyWith(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
