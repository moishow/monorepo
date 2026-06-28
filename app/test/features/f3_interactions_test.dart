// F3 인터랙션 위젯 테스트 — 빌드·렌더 검증(Task 6).
//
// 정적 `flutter analyze`로는 못 잡고, 렌더 캔버스(CanvasKit)는 불투명해 브라우저
// 자동화로도 못 보는 두 가지를 "위젯 트리"에서 실제로 확인한다. (위젯 테스트는
// 렌더 캔버스가 아니라 트리를 검사하므로 CanvasKit 불투명성과 무관하다.)
//   1) F3-6 알림 인라인 동의/거절 — 행 전체가 GestureDetector이고 그 안에 동의/거절
//      MButton(역시 GestureDetector)이 중첩돼 있다. 탭 시 "안쪽 버튼"이 arena를 이겨
//      _resolveConsent가 돌아야 한다(행 탭 _tapNotif가 가로채면 안 됨).
//   2) F3-2 예치 취소 위약금 시트 — '자유 취소'가 아니라 시간별 위약금 안내 시트가
//      실제로 떠오르고 확정 시 닫히는지.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:moisho/features/meeting/meeting_detail_screen.dart';
import 'package:moisho/features/social/notifications_screen.dart';

void main() {
  // 390x844 폰 캔버스로 고정 — 기본 800x600에서 생길 수 있는 RenderFlex 오버플로
  // 예외(테스트 실패)를 막고 앱의 디자인 폭과 동일한 레이아웃을 검사한다.
  void usePhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }

  // 토스트는 Overlay + Future.delayed(2800ms)로 자동 소멸한다. 테스트가 그 전에
  // 끝나면 pending 타이머가 남아 실패하므로, 시계를 진행시켜 타이머를 비운다.
  Future<void> drainToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3)); // delayed(2800) 발화 → reverse 시작
    await tester.pumpAndSettle(); // reverse 완료 → OverlayEntry 제거
  }

  group('F3-6 알림 인라인 출금동의', () {
    testWidgets('동의 탭 → 중첩 제스처에서 버튼이 행 탭을 이기고 동의 칩이 뜬다', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(const MaterialApp(home: NotificationsScreen()));
      await tester.pumpAndSettle();

      // 사전: actionable 알림 1건이므로 인라인 동의/거절 버튼이 정확히 하나씩.
      expect(find.text('동의'), findsOneWidget);
      expect(find.text('거절'), findsOneWidget);

      await tester.tap(find.text('동의'));
      await tester.pump(); // setState 리빌드 → 칩 등장, 토스트 삽입

      // 안쪽 버튼이 arena를 이겼다면 _resolveConsent가 실행돼 결과 칩이 뜬다.
      // (행 GestureDetector가 가로챘다면 _tapNotif만 돌아 칩은 안 뜬다.)
      expect(find.text('동의함 · 정산 투명성 확인'), findsOneWidget);
      expect(find.text('동의'), findsNothing); // 버튼이 칩으로 교체됨
      expect(find.text('거절'), findsNothing);

      await drainToast(tester);
    });

    testWidgets('거절 탭 → 이의 기록(출금 비차단) 칩이 뜬다', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(const MaterialApp(home: NotificationsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('거절'));
      await tester.pump();

      expect(find.text('이의 기록됨 · 출금은 진행'), findsOneWidget);
      expect(find.text('거절'), findsNothing);

      await drainToast(tester);
    });
  });

  group('F3-2 예치 취소 위약금 시트', () {
    testWidgets('예치 취소 → 위약금 안내 시트 등장 → 확정 시 닫힘', (tester) async {
      // 넓은 캔버스(600px)로 검사한다. flutter_test는 앱의 kFont를 로드하지 않아
      // 폴백 폰트(CJK 글자 폭이 더 넓음)로 텍스트를 재므로, 390px에선 하단 lg CTA
      // (아이콘+한글) Row가 ~19px 오버플로한다. 실앱은 좁은 kFont라 정상이며, 이
      // 테스트의 목적은 위약금 시트의 동작이지 픽셀 레이아웃이 아니다(레이아웃 충실도는
      // 별도 검증 대상). 폰트 여유를 흡수해 동작 검증에 집중한다.
      tester.view.physicalSize = const Size(1800, 3000); // 600x1000 logical @ dpr 3
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: MeetingDetailScreen(status: 'deposited')));
      await tester.pumpAndSettle();

      // 예치 상태이므로 하단 CTA에 '예치 취소'가 보인다.
      expect(find.text('예치 취소'), findsOneWidget);

      await tester.tap(find.text('예치 취소'));
      await tester.pumpAndSettle(); // 모달 바텀시트 진입 애니메이션

      // 결정1: '자유 취소'가 아니라 시간별 위약금 안내 시트.
      expect(find.text('예치 취소 — 위약금 안내'), findsOneWidget);
      expect(find.text('취소하고 환불받기'), findsOneWidget);

      // 확정 → 시트가 닫힌다(상태 none 전환 + 전액 환불 토스트가 뒤따름).
      await tester.tap(find.text('취소하고 환불받기'));
      await tester.pumpAndSettle();
      expect(find.text('예치 취소 — 위약금 안내'), findsNothing);

      await drainToast(tester);
    });
  });
}
