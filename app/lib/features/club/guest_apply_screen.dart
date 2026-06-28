// 게스트 체험 신청 — F2-1 (신규, /spec 08 §3).
// 외부인이 동아리 번개를 체험 신청한다: 동아리 요약 · 한줄 자기소개 · 희망 활동 태그 · KYC 게이트 · 제출 → GUEST_PENDING.
// 머니수학은 표시만: 예약금 5,000원·시스템 에스크로 보관(결정4)은 안내 카피로 흉내. 실제 분개 미구현.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/data/session.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import '../auth/auth_dialogs.dart';

// 희망 활동(번개 체험 시 관심사) — 자유 선택. 프로토타입 밴드 동아리 맥락.
const _wantOptions = ['보컬', '기타', '베이스', '드럼', '키보드', '합주', '친목', '공연관람'];

class GuestApplyScreen extends ConsumerStatefulWidget {
  const GuestApplyScreen({super.key});

  @override
  ConsumerState<GuestApplyScreen> createState() => _GuestApplyScreenState();
}

class _GuestApplyScreenState extends ConsumerState<GuestApplyScreen> {
  final TextEditingController _introCtrl = TextEditingController();
  final List<String> _wants = [];
  bool _submitted = false;

  @override
  void dispose() {
    _introCtrl.dispose();
    super.dispose();
  }

  int get _introLen => _introCtrl.text.trim().length;
  bool get _canSubmit => _introLen >= 10 && _wants.isNotEmpty;

  void _toggleWant(String w) => setState(() {
        if (_wants.contains(w)) {
          _wants.remove(w);
        } else {
          _wants.add(w);
        }
      });

  // KYC 게이트 — 기존 ensureVerified 시트 재사용(머니 액션과 동일 경로). 통과 시 폼으로 리렌더.
  Future<void> _startKyc() async {
    final ok = await ensureVerified(context, ref, action: '게스트 체험 신청');
    if (ok && mounted) setState(() {});
  }

  void _submit() {
    if (!_canSubmit) return;
    setState(() => _submitted = true);
    MoishoToast.show(context, '관리자가 체험 날짜 투표를 열면 알림으로 알려드릴게요.',
        tone: 'success', title: '게스트 신청 완료 🎉');
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _doneScreen();
    final verified = ref.watch(sessionProvider.select((s) => s.verified));

    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '게스트 체험 신청', onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 20, T.padScreen, 24),
            children: [
              _clubSummaryCard(),
              const SizedBox(height: 18),
              _flowNotice(),
              const SizedBox(height: 24),
              if (!verified)
                _kycGate()
              else ...[
                _introSection(),
                const SizedBox(height: 24),
                _wantsSection(),
                const SizedBox(height: 16),
                _escrowNote(),
              ],
            ],
          ),
        ),
        if (verified)
          StickyBar(
            child: MButton(
              '게스트로 체험 신청하기',
              variant: 'primary',
              size: 'lg',
              block: true,
              disabled: !_canSubmit,
              leadingIcon: const Icon(LucideIcons.userPlus, size: 17, color: T.white),
              onTap: _submit,
            ),
          ),
      ]),
    );
  }

  // ── 동아리 요약 카드 ──
  Widget _clubSummaryCard() => MCard(
        elevation: 'raised',
        radius: T.r2xl,
        padding: EdgeInsets.zero,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            decoration: const BoxDecoration(gradient: T.gradBrand),
            child: Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(T.rMd),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(T.rMd - 2),
                  child: const NetImage(
                    url: 'https://images.unsplash.com/photo-1501612780327-45045538702b?w=80&h=80&fit=crop&auto=format&q=80',
                    width: 48,
                    height: 48,
                    fallback: ColoredBox(color: T.blue400),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("홍대 연합 밴드 '사운드'", style: tx(15, FontWeight.w700, T.white, height: 1.2)),
                  const SizedBox(height: 5),
                  Row(children: [
                    _glassBadge(LucideIcons.zap, '게스트 번개 모집 중'),
                  ]),
                ]),
              ),
            ]),
          ),
          Container(
            width: double.infinity,
            color: T.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Text(
              '정식 가입 전에 단발성 번개로 동아리를 먼저 체험해 볼 수 있어요. 신청하면 관리자가 체험 날짜 투표를 열어요.',
              style: tx(12.5, FontWeight.w500, T.textMuted, height: 1.6),
            ),
          ),
        ]),
      );

  Widget _glassBadge(IconData icon, String text) => Container(
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(T.rPill),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: T.white),
          const SizedBox(width: 4),
          Text(text, style: tx(11, FontWeight.w700, T.white, height: 1)),
        ]),
      );

  // ── 3-step 흐름 안내(신청 → 날짜투표 → 번개) ──
  Widget _flowNotice() {
    const steps = [
      ('1', '체험 신청', LucideIcons.send),
      ('2', '관리자 날짜 투표', LucideIcons.calendarCheck),
      ('3', '단발성 번개 참여', LucideIcons.zap),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: T.primarySoft,
        borderRadius: BorderRadius.circular(T.rLg),
      ),
      child: Row(children: [
        for (var i = 0; i < steps.length; i++) ...[
          Expanded(
            child: Column(children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: T.white, shape: BoxShape.circle),
                child: Icon(steps[i].$3, size: 16, color: T.primary),
              ),
              const SizedBox(height: 6),
              Text(steps[i].$2,
                  textAlign: TextAlign.center, style: tx(10.5, FontWeight.w600, T.primary, height: 1.3)),
            ]),
          ),
          if (i < steps.length - 1)
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: Icon(LucideIcons.chevronRight, size: 14, color: T.primary),
            ),
        ],
      ]),
    );
  }

  // ── KYC 게이트(미인증 시 폼 대체) ──
  Widget _kycGate() => MCard(
        elevation: 'outline',
        radius: T.rXl,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(T.rXl)),
              child: const Icon(LucideIcons.shieldQuestion, size: 30, color: T.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text('본인인증 후 신청할 수 있어요',
              textAlign: TextAlign.center, style: tx(16, FontWeight.w700, T.textStrong, height: 1.3)),
          const SizedBox(height: 8),
          Text(
            '게스트 체험도 예약금이 오가요. 안전한 자금 보관을 위해\n본인인증을 한 번만 해주세요.',
            textAlign: TextAlign.center,
            style: tx(13, FontWeight.w500, T.textMuted, height: 1.6),
          ),
          const SizedBox(height: 20),
          MButton(
            '본인인증 하기',
            variant: 'primary',
            size: 'lg',
            block: true,
            leadingIcon: const Icon(LucideIcons.shieldCheck, size: 17, color: T.white),
            onTap: _startKyc,
          ),
        ]),
      );

  // ── 1. 한줄 자기소개 ──
  Widget _introSection() {
    final valid = _introLen >= 10;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader('1', '한줄 자기소개', '필수 · 10자 이상', T.danger),
        Stack(children: [
          TextField(
            controller: _introCtrl,
            onChanged: (_) => setState(() {}),
            maxLines: null,
            minLines: 3,
            style: tx(14, FontWeight.w500, T.textBody, height: 1.6),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.fromLTRB(14, 12, 14, 30),
              hintText: '예) 보컬 지망이고 합주 경험 있어요. 분위기 보고 가입 고민 중이에요!',
              hintStyle: tx(14, FontWeight.w500, T.textDisabled, height: 1.6),
              filled: true,
              fillColor: T.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(T.rLg),
                borderSide: BorderSide(color: valid ? T.primary : T.borderDefault, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(T.rLg),
                borderSide: BorderSide(color: valid ? T.primary : T.borderDefault, width: 1.5),
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 10,
            child: Text('$_introLen자',
                style: tx(11, FontWeight.w500, valid ? T.primary : T.textDisabled, height: 1)),
          ),
        ]),
      ],
    );
  }

  // ── 2. 희망 활동 ──
  Widget _wantsSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader('2', '희망 활동', '필수 · 중복 선택', T.danger, bottomGap: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final w in _wantOptions) _wantChip(w),
          ]),
        ],
      );

  Widget _wantChip(String w) {
    final on = _wants.contains(w);
    return GestureDetector(
      onTap: () => _toggleWant(w),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: on ? T.primarySoft : T.white,
          borderRadius: BorderRadius.circular(T.rPill),
          border: Border.all(color: on ? T.primary : T.borderDefault, width: 1.5),
        ),
        child: Text('#$w',
            style: tx(13, on ? FontWeight.w700 : FontWeight.w500, on ? T.primary : T.textBody, height: 1)),
      ),
    );
  }

  // ── 섹션 헤더(번호 + 라벨 + 필수태그) — join_apply 패턴 ──
  Widget _stepHeader(String num, String label, String tag, Color tagColor, {double bottomGap = 12}) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomGap),
      child: Row(children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: T.primary, shape: BoxShape.circle),
          child: Text(num, style: tx(11, FontWeight.w700, T.white, height: 1)),
        ),
        const SizedBox(width: 6),
        Text(label, style: tx(14, FontWeight.w700, T.textTitle, height: 1)),
        const SizedBox(width: 6),
        Text(tag, style: tx(11, FontWeight.w500, tagColor, height: 1)),
      ]),
    );
  }

  // ── 에스크로 안내(결정4: 게스트→관리자 직접송금 아님) ──
  Widget _escrowNote() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: T.gray50,
          borderRadius: BorderRadius.circular(T.rMd),
          border: Border.all(color: T.borderSubtle),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(LucideIcons.shieldCheck, size: 13, color: T.textDisabled),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '날짜가 정해지면 5,000원 예약금으로 단발성 번개에 참여해요. 예약금은 관리자가 아닌 시스템 에스크로가 보관하고, 노쇼가 없으면 모임 후 정산돼요.',
              style: tx(11, FontWeight.w500, T.textDisabled, height: 1.6),
            ),
          ),
        ]),
      );

  // ── 완료 화면 ──
  Widget _doneScreen() => Scaffold(
        backgroundColor: T.white,
        body: Column(children: [
          const MoishoStatusBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(color: T.primarySoft, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.circleCheck, size: 42, color: T.primary),
                  ),
                  const SizedBox(height: 20),
                  Text('게스트 신청 완료!',
                      textAlign: TextAlign.center, style: tx(22, FontWeight.w700, T.textStrong, ls: -0.02, height: 1.3)),
                  const SizedBox(height: 10),
                  Text('관리자가 체험 날짜 투표를 열면\n앱 알림으로 알려드릴게요.',
                      textAlign: TextAlign.center, style: tx(14, FontWeight.w500, T.textMuted, height: 1.6)),
                  if (_wants.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [for (final w in _wants) MTag(w, tone: 'blue', leadingHash: true)],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ]),
      );
}
