// 모이쇼 (Moisho) — dogfood 골격 (단일 파일 시작점)
// 백엔드 미구현 → mock 데이터. 토큰=ThemeData, 위치 선택은 클라이언트에서 실제 적용·필터.
// TODO(next session): feature-first 다파일 구조로 리팩터(core/theme, core/router, features/*),
//   dio + freezed + openapi 클라이언트 연동, 나머지 화면(홈/Showts/DM/마이) 하이파이 완성.
import 'package:flutter/material.dart'; // FontFeature 포함 재export
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(const ProviderScope(child: MoishoApp()));

// ============================================================
// Design Tokens (design/tokens/*.css → Dart)
// ============================================================
class T {
  // Brand
  static const blue = Color(0xFF3B5CFF);
  static const blueHover = Color(0xFF2E47E6);
  static const blueSoft = Color(0xFFEEF2FF);
  static const purple = Color(0xFF8C52FF);
  static const purpleSoft = Color(0xFFF4EEFF);
  // Semantic
  static const success = Color(0xFF00C781);
  static const successSoft = Color(0xFFE5FBF3);
  static const danger = Color(0xFFFF4B4B);
  static const warning = Color(0xFFFFA722);
  // Text / surface / border
  static const textStrong = Color(0xFF161A24);
  static const textTitle = Color(0xFF272D3B);
  static const textBody = Color(0xFF3C4456);
  static const textMuted = Color(0xFF6E7689);
  static const surface = Color(0xFFFFFFFF);
  static const sunken = Color(0xFFF4F6FA);
  static const borderSubtle = Color(0xFFEBEEF4);
  static const borderDefault = Color(0xFFDDE2EC);
  // Radii
  static const rMd = 12.0, rLg = 16.0, rXl = 20.0, r2xl = 24.0, rPill = 999.0;
  // Shadow (파란 기운 핀테크 깊이)
  static const card = [BoxShadow(color: Color(0x143B5CFF), blurRadius: 20, offset: Offset(0, 4))];
  static const pop = [BoxShadow(color: Color(0x291E2E8F), blurRadius: 40, offset: Offset(0, 16))];
}

const _font = 'Pretendard'; // web/index.html에서 CDN으로 로드
const _tnum = [FontFeature.tabularFigures()];

/// 금액 천단위 콤마 (정수 원). intl 없이 가벼운 helper.
String won(int v) {
  final s = v.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}${b.toString()}';
}

ThemeData buildTheme() {
  TextStyle t(double size, FontWeight w, Color c, {double ls = -0.01, bool tab = false}) =>
      TextStyle(fontFamily: _font, fontSize: size, fontWeight: w, color: c, letterSpacing: size * ls,
          height: 1.4, fontFeatures: tab ? _tnum : null);
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: T.sunken,
    fontFamily: _font,
    colorScheme: ColorScheme.fromSeed(
      seedColor: T.blue, primary: T.blue, secondary: T.purple,
      surface: T.surface, error: T.danger, brightness: Brightness.light,
    ),
    splashFactory: InkSparkle.splashFactory,
    textTheme: TextTheme(
      displaySmall: t(28, FontWeight.w800, T.textStrong, ls: -0.02, tab: true),
      headlineSmall: t(22, FontWeight.w800, T.textStrong, ls: -0.02),
      titleLarge: t(18, FontWeight.w700, T.textTitle),
      titleMedium: t(16, FontWeight.w600, T.textTitle),
      bodyMedium: t(14, FontWeight.w500, T.textBody),
      bodySmall: t(12, FontWeight.w500, T.textMuted),
      labelLarge: t(14, FontWeight.w700, T.surface),
    ),
  );
}

// ============================================================
// App + Router
// ============================================================
final loggedInProvider = StateProvider<bool>((_) => false);

class MoishoApp extends ConsumerWidget {
  const MoishoApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
        GoRoute(path: '/app', builder: (_, __) => const MainShell()),
      ],
    );
    return MaterialApp.router(
      title: '모이쇼',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: router,
      builder: (context, child) => _PhoneFrame(child: child ?? const SizedBox()),
    );
  }
}

/// 데스크톱/넓은 화면에선 420px 모바일 캔버스로 레터박싱(폰은 풀폭).
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
          borderRadius: BorderRadius.circular(28),
          child: SizedBox(width: 420, height: 900, child: child),
        ),
      ),
    );
  }
}

// ============================================================
// Login
// ============================================================
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Widget social(String label, Color bg, Color fg, IconData icon) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: 54,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: bg, foregroundColor: fg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(T.rMd)),
                textStyle: const TextStyle(fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              onPressed: () => context.go('/onboarding'),
              icon: Icon(icon, size: 20),
              label: Text(label),
            ),
          ),
        );
    return Scaffold(
      backgroundColor: T.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 84, height: 84,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [T.blue, T.purple]),
                  borderRadius: BorderRadius.circular(T.r2xl),
                  boxShadow: T.pop,
                ),
                child: const Icon(Icons.groups_rounded, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 22),
              Text('모이쇼', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 8),
              Text('회비를 투명하게, 모임을 활기차게',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: T.textMuted)),
              const Spacer(),
              social('카카오톡으로 3초 만에 시작하기', const Color(0xFFFEE500), const Color(0xFF191600), Icons.chat_bubble_rounded),
              social('애플 계정으로 로그인', T.textStrong, Colors.white, Icons.apple_rounded),
              social('구글 계정으로 로그인', T.surface, T.textBody, Icons.g_mobiledata_rounded),
              const SizedBox(height: 8),
              Text('이용약관 · 개인정보처리방침 · 금융거래 가이드라인',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Onboarding (닉네임 + 관심사 + 약관 → 시작)
// ============================================================
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingState();
}

class _OnboardingState extends ConsumerState<OnboardingScreen> {
  final _nick = TextEditingController();
  final _interests = <String>{};
  bool _agree = false;
  static const _tags = ['#밴드', '#독서', '#사진', '#영화', '#등산', '#요리', '#게임', '#여행', '#운동'];

  bool get _ready => _nick.text.trim().isNotEmpty && _agree;

  @override
  void dispose() {
    _nick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(backgroundColor: T.surface, surfaceTintColor: T.surface, title: Text('프로필 설정', style: tt.titleLarge)),
      backgroundColor: T.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          children: [
            Text('닉네임', style: tt.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _nick,
              onChanged: (_) => setState(() {}),
              decoration: _dec('동아리 내에서 사용할 이름이에요'),
            ),
            const SizedBox(height: 22),
            Text('관심사', style: tt.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _tags.map((tag) {
                final on = _interests.contains(tag);
                return GestureDetector(
                  onTap: () => setState(() => on ? _interests.remove(tag) : _interests.add(tag)),
                  child: _Chip(label: tag, active: on),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            InkWell(
              onTap: () => setState(() => _agree = !_agree),
              borderRadius: BorderRadius.circular(T.rMd),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Icon(_agree ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: _agree ? T.blue : T.borderDefault, size: 22),
                  const SizedBox(width: 8),
                  Expanded(child: Text('[필수] 이용약관 및 금융 장부 기록 이용 동의', style: tt.bodyMedium)),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 54,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: T.blue, disabledBackgroundColor: T.borderDefault,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(T.rMd)),
                  textStyle: const TextStyle(fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                onPressed: _ready
                    ? () {
                        ref.read(loggedInProvider.notifier).state = true;
                        context.go('/app');
                      }
                    : null,
                child: const Text('모이쇼 시작하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: _font, color: T.textMuted, fontWeight: FontWeight.w500),
        filled: true, fillColor: T.sunken,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(T.rMd), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(T.rMd), borderSide: const BorderSide(color: T.blue, width: 1.5)),
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  const _Chip({required this.label, required this.active});
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? T.blue : T.sunken,
          borderRadius: BorderRadius.circular(T.rPill),
          border: Border.all(color: active ? T.blue : T.borderDefault),
        ),
        child: Text(label,
            style: TextStyle(
                fontFamily: _font, fontSize: 13, fontWeight: FontWeight.w600,
                color: active ? Colors.white : T.textBody)),
      );
}

// ============================================================
// Main shell (5 tabs)
// ============================================================
final tabProvider = StateProvider<int>((_) => 0);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});
  static const _tabs = [
    (icon: Icons.explore_rounded, label: '탐색'),
    (icon: Icons.home_rounded, label: '홈'),
    (icon: Icons.play_circle_fill_rounded, label: 'Showts'),
    (icon: Icons.chat_rounded, label: 'DM'),
    (icon: Icons.person_rounded, label: '마이'),
  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i = ref.watch(tabProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: i, children: const [
          DiscoverScreen(),
          _Placeholder(title: '홈', sub: '쇼 피드 — 다음 세션에서 구현'),
          _Placeholder(title: 'Showts', sub: '숏폼 피드 — 다음 세션에서 구현'),
          _Placeholder(title: 'DM', sub: '메시지 — 다음 세션에서 구현'),
          _Placeholder(title: '마이', sub: '지갑·신뢰등급 — 다음 세션에서 구현'),
        ]),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: T.surface,
          border: Border(top: BorderSide(color: T.borderSubtle)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(_tabs.length, (idx) {
                final on = idx == i;
                final tab = _tabs[idx];
                return Expanded(
                  child: InkWell(
                    onTap: () => ref.read(tabProvider.notifier).state = idx,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tab.icon, size: 24, color: on ? T.blue : T.textMuted),
                        const SizedBox(height: 3),
                        Text(tab.label,
                            style: TextStyle(
                                fontFamily: _font, fontSize: 11,
                                fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                                color: on ? T.blue : T.textMuted)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String title, sub;
  const _Placeholder({required this.title, required this.sub});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction_rounded, size: 44, color: T.borderDefault),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(sub, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
}

// ============================================================
// Discover (탐색) — 위치 선택이 실제로 적용·필터됨 (mock)
// ============================================================
class Meeting {
  final String title, place, region, category;
  final int distKm10; // 거리*10 (예: 4 = 0.4km) — mock
  final int cost, cur, max;
  const Meeting(this.title, this.place, this.region, this.category, this.distKm10, this.cost, this.cur, this.max);
}

const _regions = ['역삼동', '강남구', '마포구', '성수동', '판교'];

const _meetings = <Meeting>[
  Meeting('금요 밴드 합주 & 뒷풀이', '홍대 사운드스튜디오', '마포구', '음악', 4, 27000, 7, 12),
  Meeting('주말 아침 러닝크루', '한강공원 잠원지구', '강남구', '운동', 12, 5000, 14, 20),
  Meeting('보드게임 정모', '강남 보드게임카페', '강남구', '취미', 8, 12000, 6, 8),
  Meeting('사진 출사 — 성수 골목', '성수동 카페거리', '성수동', '취미', 22, 0, 4, 10),
  Meeting('주식 스터디 9기', '역삼 스터디룸', '역삼동', '학술', 6, 10000, 9, 12),
  Meeting('등산 — 관악산 일출', '관악산 입구', '판교', '운동', 76, 8000, 5, 15),
  Meeting('와인 클래스 입문', '역삼 와인바', '역삼동', '식사', 5, 45000, 8, 10),
];

final regionProvider = StateProvider<String>((_) => '역삼동');
final distanceProvider = StateProvider<int>((_) => 5); // km

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final region = ref.watch(regionProvider);
    final dist = ref.watch(distanceProvider);

    // 클라이언트 필터: 선택 지역 + 반경(거리) 이내. (실제 좌표 거리는 백엔드 /discover/meetings)
    final filtered = _meetings.where((m) => m.region == region && m.distKm10 <= dist * 10).toList()
      ..sort((a, b) => a.distKm10.compareTo(b.distKm10));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더: 지정 위치 (탭하면 지역 선택 시트)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              InkWell(
                onTap: () => _pickRegion(context, ref),
                borderRadius: BorderRadius.circular(T.rPill),
                child: Row(children: [
                  const Icon(Icons.location_on_rounded, color: T.blue, size: 22),
                  const SizedBox(width: 4),
                  Text(region, style: tt.titleLarge),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: T.textTitle),
                ]),
              ),
              const Spacer(),
              const Icon(Icons.search_rounded, color: T.textMuted),
            ],
          ),
        ),
        // 거리 칩 (반경)
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [1, 3, 5].map((km) {
              final on = km == dist;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => ref.read(distanceProvider.notifier).state = km,
                  child: _Chip(label: '${km}km 이내', active: on),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Text('$region · ${dist}km 이내 · ${filtered.length}개 모임', style: tt.bodySmall),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text('이 조건에 맞는 모임이 없어요\n반경을 넓혀보세요',
                      textAlign: TextAlign.center, style: tt.bodySmall))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, idx) => _MeetingCard(m: filtered[idx]),
                ),
        ),
      ],
    );
  }

  void _pickRegion(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: T.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(T.r2xl))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(
                color: T.borderDefault, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('지역 선택', style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            ..._regions.map((r) {
              final on = r == ref.read(regionProvider);
              return ListTile(
                title: Text(r,
                    style: TextStyle(
                        fontFamily: _font, fontSize: 16,
                        fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                        color: on ? T.blue : T.textBody)),
                trailing: on ? const Icon(Icons.check_rounded, color: T.blue) : null,
                onTap: () {
                  ref.read(regionProvider.notifier).state = r;
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final Meeting m;
  const _MeetingCard({required this.m});
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pct = (m.cur / m.max).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: T.surface,
        borderRadius: BorderRadius.circular(T.rXl),
        border: Border.all(color: T.borderSubtle),
        boxShadow: T.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _tag(m.category),
            const Spacer(),
            Text('${(m.distKm10 / 10).toStringAsFixed(1)}km',
                style: tt.bodySmall?.copyWith(fontFeatures: _tnum)),
          ]),
          const SizedBox(height: 10),
          Text(m.title, style: tt.titleMedium),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.place_outlined, size: 14, color: T.textMuted),
            const SizedBox(width: 3),
            Expanded(child: Text(m.place, style: tt.bodySmall, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 12),
          // 펀딩 게이지
          ClipRRect(
            borderRadius: BorderRadius.circular(T.rPill),
            child: LinearProgressIndicator(
              value: pct, minHeight: 8, backgroundColor: T.sunken,
              valueColor: const AlwaysStoppedAnimation(T.blue),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Text('${m.cur}/${m.max}명',
                style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: T.textBody, fontFeatures: _tnum)),
            const Spacer(),
            Text(m.cost == 0 ? '무료' : '${won(m.cost)}원',
                style: tt.titleMedium?.copyWith(color: T.blue, fontFeatures: _tnum)),
          ]),
        ],
      ),
    );
  }

  Widget _tag(String c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(color: T.purpleSoft, borderRadius: BorderRadius.circular(T.rPill)),
        child: Text('#$c',
            style: const TextStyle(fontFamily: _font, fontSize: 11, fontWeight: FontWeight.w700, color: T.purple)),
      );
}
