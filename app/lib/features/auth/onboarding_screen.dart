// 온보딩 — 2스텝(프로필 → 약관 상세) + 푸시 권한 프롬프트. KYC는 강제하지 않음(JIT).
// 진행바 0.5→1.0 의미 회복. 약관 단일 bool → agreements[] 이력(B1). flow doc 01 §3.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/data/fixtures.dart';
import '../../core/data/models.dart';
import '../../core/data/session.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import 'auth_dialogs.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingState();
}

class _OnboardingState extends ConsumerState<OnboardingScreen> {
  int _step = 0; // 0=프로필, 1=약관
  final _nick = TextEditingController();
  final _bio = TextEditingController();
  final _search = TextEditingController();
  final _interests = <String>{}; // bare 토큰
  late final Map<String, bool> _agreed = {for (final d in kLegalDocs) d.code: false};

  bool get _profileReady => _nick.text.trim().isNotEmpty;
  bool get _requiredAgreed => kLegalDocs.where((d) => d.required).every((d) => _agreed[d.code] == true);
  bool get _allAgreed => kLegalDocs.every((d) => _agreed[d.code] == true);

  @override
  void initState() {
    super.initState();
    _bio.addListener(() => setState(() {}));
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nick.dispose();
    _bio.dispose();
    _search.dispose();
    super.dispose();
  }

  void _back() {
    if (_step == 1) {
      setState(() => _step = 0);
    } else {
      context.go('/login');
    }
  }

  Future<void> _finish() async {
    final agreements = kLegalDocs
        .map((d) => AgreementChoice(code: d.code, version: d.version, agreed: _agreed[d.code] ?? false))
        .toList();
    ref.read(sessionProvider.notifier).completeOnboarding(
          nickname: _nick.text.trim(),
          bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
          interests: _interests.toList(),
          agreements: agreements,
        );
    await requestPushPermission(context); // 거부해도 진행
    if (!mounted) return;
    context.go('/app');
  }

  @override
  Widget build(BuildContext context) {
    final ready = _step == 0 ? _profileReady : _requiredAgreed;
    return Scaffold(
      backgroundColor: T.white,
      body: SafeArea(
        child: Column(
          children: [
            const MoishoStatusBar(),
            // 진행바 + 뒤로
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
              child: Row(children: [
                GestureDetector(
                  onTap: _back,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(padding: EdgeInsets.all(6), child: Icon(LucideIcons.arrowLeft, size: 22, color: T.textStrong)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(T.rPill),
                    child: LinearProgressIndicator(
                      value: (_step + 1) / 2,
                      minHeight: 5,
                      backgroundColor: T.borderSubtle,
                      valueColor: const AlwaysStoppedAnimation(T.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${_step + 1}/2', style: tx(12, FontWeight.w700, T.textMuted, tab: true)),
              ]),
            ),
            Expanded(child: _step == 0 ? _profileStep() : _agreementStep()),
            // CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: GestureDetector(
                onTap: ready ? (_step == 0 ? () => setState(() => _step = 1) : _finish) : null,
                child: Opacity(
                  opacity: ready ? 1 : 0.45,
                  child: Container(
                    width: double.infinity, height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: T.primary,
                      borderRadius: BorderRadius.circular(T.rLg),
                      boxShadow: ready ? T.glowBlue : const [],
                    ),
                    child: Text(_step == 0 ? '다음' : '모이쇼 시작하기', style: tx(16, FontWeight.w700, T.white)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: 프로필 ──
  Widget _profileStep() {
    final q = _search.text.trim().replaceAll('#', '');
    final vocab = q.isEmpty ? kInterestVocab : kInterestVocab.where((t) => t.contains(q)).toList();
    final canAddNew = q.isNotEmpty && !kInterestVocab.contains(q) && !_interests.contains(q);
    // 선택된 칩(항상 표시) + 어휘 칩(미선택) 순서로
    final chips = <String>[
      ..._interests,
      ...vocab.where((t) => !_interests.contains(t)),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      physics: const BouncingScrollPhysics(),
      children: [
        Text('프로필을 설정해요', style: tx(24, FontWeight.w700, T.textStrong, ls: -0.02)),
        const SizedBox(height: 6),
        Text('동아리에서 사용할 프로필이에요', style: tx(14, FontWeight.w500, T.textMuted)),
        const SizedBox(height: 26),
        _label('닉네임', required: true),
        const SizedBox(height: 8),
        TextField(controller: _nick, onChanged: (_) => setState(() {}), decoration: _dec('닉네임을 입력하세요')),
        const SizedBox(height: 6),
        Text('동아리 내에서 사용할 이름이에요', style: tx(12, FontWeight.w500, T.textFaint)),
        const SizedBox(height: 22),
        Row(children: [
          _label('자기소개'),
          const Spacer(),
          Text('${_bio.text.characters.length}/60', style: tx(12, FontWeight.w500, T.textFaint, tab: true)),
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: _bio, maxLength: 60, maxLines: 3,
          buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
          decoration: _dec('나를 한 줄로 소개해보세요'),
        ),
        const SizedBox(height: 22),
        _label('관심사'),
        const SizedBox(height: 10),
        TextField(
          controller: _search,
          decoration: _dec('관심사 검색 또는 직접 추가').copyWith(
            prefixIcon: const Icon(LucideIcons.search, color: T.textMuted, size: 18),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: [
            if (canAddNew)
              GestureDetector(
                onTap: () => setState(() {
                  _interests.add(q);
                  _search.clear();
                }),
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: T.accentSoft,
                    borderRadius: BorderRadius.circular(T.rMini),
                    border: Border.all(color: T.accent.withValues(alpha: 0.4)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(LucideIcons.plus, size: 13, color: T.accent),
                    const SizedBox(width: 3),
                    Text('#$q 추가', style: tx(13, FontWeight.w600, T.accent)),
                  ]),
                ),
              ),
            for (final tag in chips) _interestChip(tag),
          ],
        ),
      ],
    );
  }

  // 관심사 칩 — 내용폭(intrinsic) 인라인 필. Wrap 안에서 full-width 로 늘어나지 않도록 alignment 미지정.
  Widget _interestChip(String tag) {
    final on = _interests.contains(tag);
    return GestureDetector(
      onTap: () => setState(() => on ? _interests.remove(tag) : _interests.add(tag)),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: on ? T.primary : T.gray50,
          borderRadius: BorderRadius.circular(T.rMini),
          border: Border.all(color: on ? Colors.transparent : T.borderDefault),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Opacity(opacity: 0.6, child: Text('#', style: tx(13, FontWeight.w600, on ? T.white : T.textBody))),
          Text(tag, style: tx(13, FontWeight.w600, on ? T.white : T.textBody)),
        ]),
      ),
    );
  }

  // ── Step 2: 약관 상세 ──
  Widget _agreementStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      physics: const BouncingScrollPhysics(),
      children: [
        Text('약관에 동의해주세요', style: tx(24, FontWeight.w700, T.textStrong, ls: -0.02)),
        const SizedBox(height: 6),
        Text('안전한 회비 관리를 위해 꼭 필요해요', style: tx(14, FontWeight.w500, T.textMuted)),
        const SizedBox(height: 24),
        // 전체 동의
        GestureDetector(
          onTap: () => setState(() {
            final next = !_allAgreed;
            for (final d in kLegalDocs) {
              _agreed[d.code] = next;
            }
          }),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: _allAgreed ? T.primarySoft : T.gray50,
              borderRadius: BorderRadius.circular(T.rLg),
              border: Border.all(color: _allAgreed ? T.primary : T.borderDefault, width: 1.5),
            ),
            child: Row(children: [
              _check(_allAgreed, big: true),
              const SizedBox(width: 12),
              Expanded(child: Text('약관 전체 동의', style: tx(16, FontWeight.w700, T.textStrong))),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        for (final doc in kLegalDocs) _agreementRow(doc),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: T.gray50, borderRadius: BorderRadius.circular(T.rMd)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(LucideIcons.info, size: 15, color: T.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '본인인증(KYC)은 첫 회비 예치·충전 때 한 번만 진행해요. 지금은 건너뛰어도 돼요.',
                style: tx(12, FontWeight.w500, T.textMuted, height: 1.5),
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _agreementRow(LegalDoc doc) {
    final checked = _agreed[doc.code] == true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        GestureDetector(
          onTap: () => setState(() => _agreed[doc.code] = !checked),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              _check(checked),
              const SizedBox(width: 12),
            ]),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _agreed[doc.code] = !checked),
            behavior: HitTestBehavior.opaque,
            child: Text(doc.summary, style: tx(13.5, FontWeight.w500, T.textBody)),
          ),
        ),
        GestureDetector(
          onTap: () => showLegalSheet(context, doc),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Text('보기', style: tx(12.5, FontWeight.w600, T.textMuted).copyWith(decoration: TextDecoration.underline)),
          ),
        ),
      ]),
    );
  }

  Widget _check(bool on, {bool big = false}) {
    final s = big ? 26.0 : 22.0;
    return Container(
      width: s, height: s,
      decoration: BoxDecoration(
        color: on ? T.primary : T.white,
        borderRadius: BorderRadius.circular(T.rSm),
        border: Border.all(color: on ? T.primary : T.borderStrong, width: 1.5),
      ),
      child: on ? Icon(LucideIcons.check, size: big ? 16 : 14, color: T.white) : null,
    );
  }

  Widget _label(String text, {bool required = false}) => Row(children: [
        Text(text, style: tx(14.5, FontWeight.w700, T.textTitle)),
        if (!required) ...[const SizedBox(width: 4), Text('(선택)', style: tx(12, FontWeight.w500, T.textFaint))],
      ]);

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: kFont, color: T.textMuted, fontWeight: FontWeight.w500),
        filled: true, fillColor: T.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(T.rMd), borderSide: const BorderSide(color: T.borderDefault)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(T.rMd), borderSide: const BorderSide(color: T.borderDefault)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(T.rMd), borderSide: const BorderSide(color: T.primary, width: 1.5)),
      );
}
