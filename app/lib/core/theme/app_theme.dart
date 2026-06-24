import 'package:flutter/material.dart';
import 'tokens.dart';

/// 앱 전역 ThemeData. 토큰(T)·타이포 스케일을 Material3에 매핑.
ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: T.surfacePage,
    fontFamily: kFont,
    colorScheme: ColorScheme.fromSeed(
      seedColor: T.blue500,
      primary: T.blue500,
      secondary: T.purple500,
      surface: T.surfacePage,
      error: T.danger,
      brightness: Brightness.light,
    ),
    splashFactory: InkSparkle.splashFactory,
    textTheme: TextTheme(
      displayLarge: tx(34, FontWeight.w700, T.textStrong, ls: -0.02, height: 1.2, tab: true),
      displaySmall: tx(28, FontWeight.w700, T.textStrong, ls: -0.02, height: 1.2, tab: true),
      headlineSmall: tx(22, FontWeight.w700, T.textStrong, ls: -0.02, height: 1.35),
      titleLarge: tx(18, FontWeight.w700, T.textTitle, ls: -0.01, height: 1.35),
      titleMedium: tx(16, FontWeight.w600, T.textTitle, height: 1.5),
      bodyLarge: tx(15, FontWeight.w500, T.textBody, height: 1.5),
      bodyMedium: tx(14, FontWeight.w500, T.textBody, height: 1.5),
      bodySmall: tx(12, FontWeight.w500, T.textMuted, height: 1.35),
      labelLarge: tx(14, FontWeight.w700, T.white),
    ),
  );
}
