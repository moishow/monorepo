// 모이쇼 디자인 토큰 — design/tokens/*.css(:root 변수)를 Dart 상수로 1:1 이식.
// 프로토타입(design/prototype-app.html)의 CSS 변수 = 여기 T.* 상수.
import 'package:flutter/material.dart';

/// 디자인 토큰. 색·라운드·섀도·타이포 스케일.
/// 값은 design-tokens.md / design/tokens 와 동일. 임의 발명 금지(CLAUDE.md §11).
class T {
  T._();

  // ── Brand: 모이쇼 블루 ──
  static const blue50 = Color(0xFFEEF2FF);
  static const blue100 = Color(0xFFDFE6FF);
  static const blue200 = Color(0xFFBECCFF);
  static const blue300 = Color(0xFF94A9FF);
  static const blue400 = Color(0xFF6781FF);
  static const blue500 = Color(0xFF3B5CFF); // 핵심 브랜드
  static const blue600 = Color(0xFF2E47E6);
  static const blue700 = Color(0xFF2438B8);
  static const blue800 = Color(0xFF1E2E8F);
  static const blue900 = Color(0xFF1A2870);

  // ── Point: 네온 퍼플 ──
  static const purple50 = Color(0xFFF4EEFF);
  static const purple100 = Color(0xFFE9DDFF);
  static const purple200 = Color(0xFFD3BCFF);
  static const purple300 = Color(0xFFB68FFF);
  static const purple400 = Color(0xFF9F6BFF);
  static const purple500 = Color(0xFF8C52FF); // 포인트
  static const purple600 = Color(0xFF7838F0);
  static const purple700 = Color(0xFF6228CC);
  static const purple800 = Color(0xFF4D1F9E);
  static const purple900 = Color(0xFF3B1879);

  // ── Semantic: Success(민트) ──
  static const mint50 = Color(0xFFE5FBF3);
  static const mint100 = Color(0xFFC7F6E5);
  static const mint300 = Color(0xFF67E3BC);
  static const mint500 = Color(0xFF00C781);
  static const mint600 = Color(0xFF00A86D);
  static const mint700 = Color(0xFF008857);

  // ── Semantic: Error/Warning(코랄) ──
  static const coral50 = Color(0xFFFFECEC);
  static const coral100 = Color(0xFFFFD6D6);
  static const coral300 = Color(0xFFFF9A9A);
  static const coral500 = Color(0xFFFF4B4B);
  static const coral600 = Color(0xFFED3535);
  static const coral700 = Color(0xFFC82424);

  // ── Caution(앰버) ──
  static const amber50 = Color(0xFFFFF6E5);
  static const amber100 = Color(0xFFFFE9BF);
  static const amber500 = Color(0xFFFFA722);
  static const amber600 = Color(0xFFF08F00);

  // ── Neutral / Gray ──
  static const white = Color(0xFFFFFFFF);
  static const gray25 = Color(0xFFFAFBFD);
  static const gray50 = Color(0xFFF4F6FA); // 카드 배경
  static const gray100 = Color(0xFFEBEEF4);
  static const gray200 = Color(0xFFDDE2EC);
  static const gray300 = Color(0xFFC5CCDA);
  static const gray400 = Color(0xFF9AA3B5);
  static const gray500 = Color(0xFF6E7689);
  static const gray600 = Color(0xFF525B6E);
  static const gray700 = Color(0xFF3C4456);
  static const gray800 = Color(0xFF272D3B);
  static const gray900 = Color(0xFF161A24);

  // ── Semantic aliases ──
  static const primary = blue500;
  static const primaryHover = blue600;
  static const primaryPress = blue700;
  static const primarySoft = blue50;
  static const accent = purple500;
  static const accentHover = purple600;
  static const accentSoft = purple50;
  static const success = mint500;
  static const successSoft = mint50;
  static const successStrong = mint700;
  static const danger = coral500;
  static const dangerSoft = coral50;
  static const dangerStrong = coral700;
  static const warning = amber500;
  static const warningSoft = amber50;

  // Surfaces
  static const surfacePage = white;
  static const surfaceCard = white;
  static const surfaceSunken = gray50;
  static const surfaceInverse = gray900;

  // Text
  static const textStrong = gray900; // Display / 금액
  static const textTitle = gray800; // 모임명
  static const textBody = gray700; // 본문
  static const textMuted = gray500; // Caption
  static const textDisabled = Color(0xFF767F92); // 메타/타임스탬프
  static const textFaint = gray400; // 장식용
  static const textLink = blue500;

  // Borders
  static const borderSubtle = gray100;
  static const borderDefault = gray200;
  static const borderStrong = gray300;
  static const borderFocus = blue500;

  // ── Radii ──
  static const rMini = 6.0;
  static const rSm = 8.0;
  static const rMd = 12.0; // 입력·버튼
  static const rLg = 16.0;
  static const rXl = 20.0; // 카드
  static const r2xl = 24.0; // 메인 보드
  static const rPill = 999.0;

  // ── Shadows ──
  static const shadowXs = [BoxShadow(color: Color(0x0D161A24), blurRadius: 2, offset: Offset(0, 1))];
  static const shadowSm = [BoxShadow(color: Color(0x0F1E2E8F), blurRadius: 8, offset: Offset(0, 2))];
  static const shadowMd = [BoxShadow(color: Color(0x141E2E8F), blurRadius: 16, offset: Offset(0, 6))];
  static const shadowLg = [BoxShadow(color: Color(0x1A1E2E8F), blurRadius: 28, offset: Offset(0, 12))];
  static const shadowCard = [BoxShadow(color: Color(0x143B5CFF), blurRadius: 20, offset: Offset(0, 4))];
  static const shadowPop = [BoxShadow(color: Color(0x291E2E8F), blurRadius: 40, offset: Offset(0, 16))];
  static const glowBlue = [BoxShadow(color: Color(0x593B5CFF), blurRadius: 20, offset: Offset(0, 6))];
  static const glowPurple = [BoxShadow(color: Color(0x528C52FF), blurRadius: 20, offset: Offset(0, 6))];

  // ── Layout ──
  static const appMaxWidth = 390.0;
  static const appHeight = 844.0;
  static const tabbarHeight = 66.0;
  static const headerHeight = 52.0;
  static const padScreen = 20.0;

  // ── Gradients (자주 쓰는 조합) ──
  static const gradBrand = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [blue500, purple500],
  );
  static const gradEventBanner = LinearGradient(
    begin: Alignment(-0.9, -0.4), end: Alignment(0.9, 0.4),
    colors: [purple500, blue500],
  );
  static const gradWallet = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [blue600, purple600],
  );
}

const kFont = 'Pretendard';
const kTnum = [FontFeature.tabularFigures()];

/// 금액 천단위 콤마 (정수 원). intl 없이 가벼운 helper.
String won(int v) {
  final s = v.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}$b';
}

/// 좋아요/조회수 등 1000+ → 3.2K 포맷 (쇼츠).
String fmtCount(int n) {
  if (n >= 1000) {
    final v = n / 1000;
    return '${v.toStringAsFixed(1)}K';
  }
  return '$n';
}

/// 텍스트 스타일 빌더 — Pretendard + 자간/탭룰러 옵션.
TextStyle tx(double size, FontWeight w, Color c,
        {double ls = -0.01, double height = 1.4, bool tab = false}) =>
    TextStyle(
      fontFamily: kFont, fontSize: size, fontWeight: w, color: c,
      letterSpacing: size * ls, height: height,
      fontFeatures: tab ? kTnum : null,
    );
