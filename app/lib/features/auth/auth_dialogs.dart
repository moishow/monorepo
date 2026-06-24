// 인증 모달 상호작용 — JIT KYC 게이트 · 본인인증 시트 · 약관 보기 · 푸시 권한 프롬프트.
// 머니 액션 직전 ensureVerified()가 403 KYC_REQUIRED 를 클라이언트에서 게이트한다(flow doc §3).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/data/models.dart';
import '../../core/data/session.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/toast.dart';

// ============================================================
// JIT KYC 게이트 — 미인증이면 본인인증, 통과 시 true. 머니 액션의 전제 게이트.
// ============================================================
Future<bool> ensureVerified(BuildContext context, WidgetRef ref, {String? action}) async {
  if (ref.read(sessionProvider).verified) return true;
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x73000000),
    builder: (_) => _KycSheet(ref: ref, action: action),
  );
  if (!context.mounted) return false;
  if (ok == true) {
    MoishoToast.show(context, '포인트 지갑이 열렸어요', tone: 'success', title: '본인인증 완료', icon: LucideIcons.shieldCheck);
  }
  return ok ?? false;
}

/// 약관 본문 보기 시트.
Future<void> showLegalSheet(BuildContext context, LegalDoc doc) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x73000000),
      builder: (_) => _LegalSheet(doc: doc),
    );

/// OS 푸시 권한 프롬프트(클라이언트 전용 — 서버 알림토글과 별개). 거부해도 진행.
Future<bool> requestPushPermission(BuildContext context) async {
  final granted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x73000000),
    builder: (_) => const _PushSheet(),
  );
  return granted ?? false;
}

// ── 공통 시트 셸: 라운드 상단 + 그래버 ──
class _SheetShell extends StatelessWidget {
  final Widget child;
  const _SheetShell({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.86),
      decoration: const BoxDecoration(
        color: T.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(T.r2xl)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              decoration: BoxDecoration(color: T.gray200, borderRadius: BorderRadius.circular(T.rPill)),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 본인인증 시트 — 게이트 안내 + 인증수단 선택(카카오/통신사/아이핀).
// ============================================================
class _KycSheet extends StatefulWidget {
  final WidgetRef ref;
  final String? action;
  const _KycSheet({required this.ref, this.action});
  @override
  State<_KycSheet> createState() => _KycSheetState();
}

class _KycSheetState extends State<_KycSheet> {
  String? _verifying;

  Future<void> _verify(String method) async {
    setState(() => _verifying = method);
    await Future<void>.delayed(const Duration(milliseconds: 750)); // 인증 핸드셰이크 시뮬레이션
    if (!mounted) return; // 시트가 닫혔으면 verified 플립 안 함(유령 상태 방지)
    widget.ref.read(sessionProvider.notifier).verifyKyc(method: method);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.action ?? '회비 예치';
    return _SheetShell(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          Center(
            child: Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(T.rXl)),
              child: const Icon(LucideIcons.shieldCheck, size: 30, color: T.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text('본인인증이 필요해요', textAlign: TextAlign.center, style: tx(20, FontWeight.w700, T.textStrong)),
          const SizedBox(height: 8),
          Text(
            '$action 전에 본인인증을 한 번만 해주세요.\n안전한 자금 보관을 위한 절차예요.',
            textAlign: TextAlign.center,
            style: tx(13.5, FontWeight.w500, T.textMuted, height: 1.5),
          ),
          const SizedBox(height: 20),
          if (_verifying == null) ...[
            _method('kakao', '카카오 인증', '카카오톡으로 간편하게', LucideIcons.messageSquare, const Color(0xFFFEE500), const Color(0xFF191600)),
            const SizedBox(height: 10),
            _method('telecom', '통신사 PASS', '휴대폰 본인확인', LucideIcons.smartphone, T.primarySoft, T.primary),
            const SizedBox(height: 10),
            _method('ipin', '아이핀(i-PIN)', '주민번호 대체 수단', LucideIcons.idCard, T.gray100, T.textBody),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(LucideIcons.lock, size: 13, color: T.textFaint),
              const SizedBox(width: 5),
              Text('인증 정보는 안전하게 암호화돼요', style: tx(11.5, FontWeight.w500, T.textFaint)),
            ]),
          ] else ...[
            const SizedBox(height: 12),
            const Center(child: SizedBox(width: 34, height: 34, child: CircularProgressIndicator(strokeWidth: 3, color: T.primary))),
            const SizedBox(height: 16),
            Text('본인인증을 진행하고 있어요…', textAlign: TextAlign.center, style: tx(14, FontWeight.w600, T.textBody)),
            const SizedBox(height: 24),
          ],
        ]),
      ),
    );
  }

  Widget _method(String id, String title, String sub, IconData icon, Color bg, Color fg) => GestureDetector(
        onTap: () => _verify(id),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: T.white,
            borderRadius: BorderRadius.circular(T.rLg),
            border: Border.all(color: T.borderDefault, width: 1.5),
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(T.rMd)),
              child: Icon(icon, size: 20, color: fg),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: tx(14.5, FontWeight.w700, T.textTitle, height: 1.2)),
                const SizedBox(height: 3),
                Text(sub, style: tx(11.5, FontWeight.w500, T.textMuted, height: 1.2)),
              ]),
            ),
            const Icon(LucideIcons.chevronRight, size: 18, color: T.textFaint),
          ]),
        ),
      );
}

// ============================================================
// 약관 본문 시트.
// ============================================================
class _LegalSheet extends StatelessWidget {
  final LegalDoc doc;
  const _LegalSheet({required this.doc});
  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(children: [
            Expanded(child: Text(doc.title, style: tx(17, FontWeight.w700, T.textStrong))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: T.gray100, borderRadius: BorderRadius.circular(T.rPill)),
              child: Text('v${doc.version}', style: tx(11, FontWeight.w600, T.textMuted, height: 1, tab: true)),
            ),
          ]),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(doc.body, style: tx(13.5, FontWeight.w500, T.textBody, height: 1.7)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(T.rMd)),
              child: Text('확인', style: tx(15, FontWeight.w700, T.primary)),
            ),
          ),
        ),
      ]),
    );
  }
}

// ============================================================
// 푸시 권한 프롬프트 — 거부해도 진행(인앱 알림함은 동작).
// ============================================================
class _PushSheet extends StatelessWidget {
  const _PushSheet();
  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          Center(
            child: Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: T.accentSoft, borderRadius: BorderRadius.circular(T.rXl)),
              child: const Icon(LucideIcons.bell, size: 30, color: T.accent),
            ),
          ),
          const SizedBox(height: 16),
          Text('알림을 받아볼까요?', textAlign: TextAlign.center, style: tx(19, FontWeight.w700, T.textStrong)),
          const SizedBox(height: 8),
          Text(
            '회비 마감, 정산 완료, 새 모임 소식을 놓치지 않게\n알려드려요. 나중에 설정에서 바꿀 수 있어요.',
            textAlign: TextAlign.center,
            style: tx(13.5, FontWeight.w500, T.textMuted, height: 1.5),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(true),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: T.primary, borderRadius: BorderRadius.circular(T.rMd), boxShadow: T.glowBlue),
              child: Text('알림 허용', style: tx(15, FontWeight.w700, T.white)),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 46,
              alignment: Alignment.center,
              child: Text('나중에 할게요', style: tx(14, FontWeight.w600, T.textMuted)),
            ),
          ),
        ]),
      ),
    );
  }
}
