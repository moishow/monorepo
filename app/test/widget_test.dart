// 모이쇼 앱 스모크 테스트.
//
// 백엔드 미구현 단계의 골격이므로, 앱이 정상적으로 빌드되고
// 첫 화면(로그인)이 렌더링되는지만 확인한다. 기능 추가 시 화면별
// 위젯 테스트를 features/* 아래로 분리해 늘려간다.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:moisho/main.dart';

void main() {
  testWidgets('앱이 빌드되고 로그인 화면을 보여준다', (WidgetTester tester) async {
    // Arrange & Act: ProviderScope로 감싼 루트 위젯을 펌프한다.
    await tester.pumpWidget(const ProviderScope(child: MoishoApp()));
    await tester.pumpAndSettle();

    // Assert: 로그인 화면의 브랜드 카피와 카카오 CTA가 보인다.
    expect(find.text('회비를 투명하게, 모임을 활기차게'), findsOneWidget);
    expect(find.text('카카오톡으로 3초 만에 시작하기'), findsOneWidget);
  });
}
