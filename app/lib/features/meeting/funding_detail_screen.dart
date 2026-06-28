// 펀딩 상세(부원 모임 상세) — prototype FundingDetailScreen (6c5465b6:62).
// 모임 기본 정보·참석 현황·총무/불참 액션·하단 CTA·카카오페이 이체 시트.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import '../treasurer/treasurer_screen.dart';
import 'payment_success_screen.dart';

// 카카오페이 브랜드 컬러 — 토큰 매핑 없음(서드파티 브랜드).
const _kakaoYellow = Color(0xFFFFEB00); // proto #FFEB00 카카오페이 brand
const _kakaoDark = Color(0xFF3A1D1D); // proto #3A1D1D 카카오페이 brand

class FundingDetailScreen extends StatefulWidget {
  const FundingDetailScreen({super.key});

  @override
  State<FundingDetailScreen> createState() => _FundingDetailScreenState();
}

class _FundingDetailScreenState extends State<FundingDetailScreen> {
  // "unpaid" | "processing" | "paid"
  String _paymentStatus = 'unpaid';

  // ── 매니저가 제공한 모임 정보(프로토타입 event 리터럴) ──
  static const _title = '정기 대관 연습 및 뒷풀이';
  static const _location = '홍대 사운드스튜디오';
  static const _date = '06/15 (일) 18:00';
  static const _estDuration = '약 3시간';
  static const _costPerPerson = 40000;
  static const _minPeople = 5;
  static const _maxPeople = 10;
  static const _baseCurrentPeople = 7;
  static const _deadline = '23시간 후';

  int get _currentPeople => _paymentStatus == 'paid' ? _baseCurrentPeople + 1 : _baseCurrentPeople;
  int get _progressValue => (_currentPeople / _maxPeople * 100).round();

  void _openKakaoPaySheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: T.gray900.withValues(alpha: 0.55), // surface-overlay
      builder: (sheetCtx) => _KakaoPaySheet(
        amount: _costPerPerson,
        meetingName: _title,
        onConfirm: () {
          Navigator.of(sheetCtx).pop();
          _handleKakaoPayConfirm();
        },
        onClose: () => Navigator.of(sheetCtx).pop(),
      ),
    );
  }

  void _handleKakaoPayConfirm() {
    setState(() => _paymentStatus = 'processing');
    MoishoToast.show(context, '포인트 예치 처리 중이에요...', tone: 'info');
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() => _paymentStatus = 'paid');
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PaymentSuccessScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(
          title: '모임 상세',
          onBack: () => Navigator.of(context).maybePop(),
          actions: [
            MinTapTarget(
              const Icon(LucideIcons.ellipsis, size: 22, color: T.textMuted),
              onTap: () => MoishoToast.show(context, '준비 중', tone: 'info'),
              min: 38,
            ),
          ],
        ),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 16, T.padScreen, 24),
            children: [
              _basicInfoCard(),
              const SizedBox(height: 14),
              _attendanceCard(),
              const SizedBox(height: 14),
              _actionRow(),
            ],
          ),
        ),
        _cta(),
      ]),
    );
  }

  // ── 모임 기본 정보 ──
  Widget _basicInfoCard() {
    final rows = <(IconData, String, String, bool, bool)>[
      (LucideIcons.mapPin, '장소', _location, false, false),
      (LucideIcons.calendar, '일시', _date, false, false),
      (LucideIcons.clock, '예상 시간', _estDuration, false, false),
      (LucideIcons.wallet, '예상 비용', '${won(_costPerPerson)}원/인', true, false),
      (LucideIcons.users, '모집 인원', '최소 $_minPeople명 · 최대 $_maxPeople명', false, false),
      (LucideIcons.timer, '신청 마감', _deadline, false, true),
    ];
    return MCard(
      elevation: 'flat',
      radius: T.rXl,
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_title, style: tx(18, FontWeight.w700, T.textStrong, height: 1.3)),
        const SizedBox(height: 14),
        for (final (icon, label, value, accent, warn) in rows)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: T.borderSubtle))),
            child: Row(children: [
              Icon(icon, size: 15, color: accent ? T.primary : (warn ? T.danger : T.textMuted)),
              const SizedBox(width: 10),
              SizedBox(width: 60, child: Text(label, style: tx(13, FontWeight.w500, T.textMuted, height: 1))),
              Expanded(
                child: Text(
                  value,
                  style: tx(13, accent || warn ? FontWeight.w700 : FontWeight.w600,
                      accent ? T.primary : (warn ? T.danger : T.textBody),
                      height: 1, tab: true),
                ),
              ),
            ]),
          ),
      ]),
    );
  }

  // ── 참석 현황 ──
  Widget _attendanceCard() {
    return MCard(
      elevation: 'raised',
      radius: T.rXl,
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('참석 현황', style: tx(14, FontWeight.w700, T.textTitle, height: 1)),
          Text('$_currentPeople / $_maxPeople명', style: tx(13, FontWeight.w600, T.textMuted, height: 1, tab: true)),
        ]),
        const SizedBox(height: 12),
        ProgressBar(value: _progressValue.toDouble(), height: 12),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
          _statusBadge(),
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.timer, size: 12, color: T.danger),
            const SizedBox(width: 4),
            Text('마감 $_deadline', style: tx(12, FontWeight.w600, T.danger, height: 1)),
          ]),
        ]),
        if (_paymentStatus == 'paid') ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: T.successSoft, borderRadius: BorderRadius.circular(T.rMd)),
            child: Row(children: [
              const Icon(LucideIcons.circleCheck, size: 15, color: T.successStrong),
              const SizedBox(width: 8),
              Text('카카오페이 이체 완료 · 신청됨', style: tx(13, FontWeight.w600, T.successStrong, height: 1)),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _statusBadge() {
    if (_paymentStatus == 'paid') return const MBadge('참석 신청 완료', tone: 'success', variant: 'dot');
    if (_paymentStatus == 'processing') return const MBadge('이체 처리 중...', tone: 'warning', variant: 'dot');
    return const MBadge('미신청', tone: 'neutral', variant: 'soft');
  }

  // ── 총무 전용 / 불참 처리 ──
  Widget _actionRow() {
    return Row(children: [
      if (_paymentStatus == 'paid') ...[
        Expanded(
          child: _outlineAction(
            icon: LucideIcons.userX,
            label: '불참 처리',
            color: T.danger,
            onTap: () => MoishoToast.show(context, '준비 중', tone: 'info'),
          ),
        ),
        const SizedBox(width: 10),
      ],
      Expanded(
        child: _outlineAction(
          icon: LucideIcons.shield,
          label: '총무: 입금 현황',
          color: T.textMuted,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TreasurerScreen()),
          ),
        ),
      ),
    ]);
  }

  Widget _outlineAction({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: T.white,
          borderRadius: BorderRadius.circular(T.rMd),
          border: Border.all(color: T.borderDefault, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(label, style: tx(13, FontWeight.w600, color, height: 1)),
        ]),
      ),
    );
  }

  // ── 하단 CTA ──
  Widget _cta() {
    if (_paymentStatus == 'paid') {
      return StickyBar(
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: T.successSoft, borderRadius: BorderRadius.circular(T.rLg)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.circleCheck, size: 20, color: T.successStrong),
            const SizedBox(width: 10),
            Text('참석 신청 완료!', style: tx(15, FontWeight.w700, T.successStrong, height: 1)),
          ]),
        ),
      );
    }
    if (_paymentStatus == 'processing') {
      return StickyBar(
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: T.gray100, borderRadius: BorderRadius.circular(T.rLg)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.loader, size: 18, color: T.textMuted),
            const SizedBox(width: 10),
            Text('카카오페이 이체 중...', style: tx(15, FontWeight.w600, T.textMuted, height: 1)),
          ]),
        ),
      );
    }
    return StickyBar(
      child: GestureDetector(
        onTap: _openKakaoPaySheet,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 52,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: T.primary, borderRadius: BorderRadius.circular(T.rLg)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.handCoins, size: 20, color: T.white),
            const SizedBox(width: 10),
            Text('참석 신청하기 · ${won(_costPerPerson)}원', style: tx(16, FontWeight.w700, T.white, height: 1)),
          ]),
        ),
      ),
    );
  }
}

// ── 카카오페이 이체 확인 바텀시트 ──
class _KakaoPaySheet extends StatelessWidget {
  final int amount;
  final String meetingName;
  final VoidCallback onConfirm;
  final VoidCallback onClose;
  const _KakaoPaySheet({required this.amount, required this.meetingName, required this.onConfirm, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('수취인', '사운드 모임통장'),
      ('모임', meetingName),
      ('메모', '모임 참석 · 포인트 예치'),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      decoration: const BoxDecoration(
        color: T.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(T.r2xl)),
        boxShadow: [BoxShadow(color: Color(0x24000000), blurRadius: 40, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: T.gray200, borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // 헤더
          Row(children: [
            Container(
              width: 42, height: 42,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: _kakaoYellow, shape: BoxShape.circle),
              child: Text('Pay', style: tx(12, FontWeight.w900, _kakaoDark, ls: -0.02, height: 1)),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text('카카오페이 이체 확인', style: tx(16, FontWeight.w700, T.textStrong, height: 1.2)),
              const SizedBox(height: 3),
              Text('확인 한 번이면 바로 처리돼요', style: tx(12, FontWeight.w500, T.textMuted, height: 1)),
            ]),
          ]),
          const SizedBox(height: 16),

          // 이체 정보 박스
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(color: T.gray50, borderRadius: BorderRadius.circular(T.rLg)),
            child: Column(children: [
              for (final (label, value) in rows) ...[
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(label, style: tx(13, FontWeight.w500, T.textMuted, height: 1)),
                  Flexible(child: Text(value, textAlign: TextAlign.right, style: tx(13, FontWeight.w600, T.textBody, height: 1))),
                ]),
                const SizedBox(height: 13),
              ],
              Container(
                padding: const EdgeInsets.only(top: 13),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: T.borderDefault, width: 1.5, style: BorderStyle.solid)),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Text('이체 금액', style: tx(14, FontWeight.w600, T.textTitle, height: 1)),
                  Text('${won(amount)}원', style: tx(24, FontWeight.w700, T.textStrong, ls: -0.02, height: 1, tab: true)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // 카카오페이 이체 버튼
          GestureDetector(
            onTap: onConfirm,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: _kakaoYellow, borderRadius: BorderRadius.circular(T.rLg)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: _kakaoDark, borderRadius: BorderRadius.circular(5)),
                  child: Text('Pay', style: tx(11, FontWeight.w900, _kakaoYellow, height: 1)),
                ),
                const SizedBox(width: 10),
                Text('포인트로 예치하기', style: tx(16, FontWeight.w700, _kakaoDark, ls: -0.01, height: 1)),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // 취소
          GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(T.rLg),
                border: Border.all(color: T.borderDefault, width: 1.5),
              ),
              child: Text('취소', style: tx(14, FontWeight.w500, T.textMuted, height: 1)),
            ),
          ),
        ]),
      ),
    );
  }
}
