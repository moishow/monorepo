// 동아리 가입 신청서 — prototype ClubJoinApplyScreen (6ba1fa1c:11).
// 동아리 헤더 카드 · 담당 파트 · 활동 요일 · 지원 동기 · 연주 경력 · 동의 체크 · 제출 CTA · 완료 화면.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import 'club_detail_screen.dart';

const _instruments = ['🎸 기타', '🎹 키보드', '🎺 보컬', '🥁 드럼', '🎻 베이스', '🎷 관악기', '🎵 기타 악기'];
const _days = ['월', '화', '수', '목', '금', '토', '일'];
const _motivations = ['취미로 악기 연주', '공연 경험 쌓기', '마음 맞는 멤버 만나기', '정기 합주 참여', '친목 & 뒷풀이'];

class ClubJoinApplyScreen extends StatefulWidget {
  const ClubJoinApplyScreen({super.key});

  @override
  State<ClubJoinApplyScreen> createState() => _ClubJoinApplyScreenState();
}

class _ClubJoinApplyScreenState extends State<ClubJoinApplyScreen> {
  final List<String> _instrumentsSel = [];
  final List<String> _daysSel = [];
  final List<String> _motivationsSel = [];
  final TextEditingController _introCtrl = TextEditingController();
  final TextEditingController _experienceCtrl = TextEditingController();
  bool _agreed = false;
  bool _submitted = false;

  @override
  void dispose() {
    _introCtrl.dispose();
    _experienceCtrl.dispose();
    super.dispose();
  }

  int get _introLen => _introCtrl.text.trim().length;
  bool get _canSubmit =>
      _instrumentsSel.isNotEmpty && _daysSel.isNotEmpty && _introLen >= 20 && _agreed;

  void _toggle(List<String> list, String val) {
    setState(() {
      if (list.contains(val)) {
        list.remove(val);
      } else {
        list.add(val);
      }
    });
  }

  void _toggleMotivation(String m) {
    setState(() {
      if (_motivationsSel.contains(m)) {
        _motivationsSel.remove(m);
      } else {
        _motivationsSel.add(m);
      }
      if (!_introCtrl.text.contains(m)) {
        _introCtrl.text = _introCtrl.text.isNotEmpty ? '${_introCtrl.text} $m' : m;
      }
    });
  }

  void _handleSubmit() {
    if (!_canSubmit) return;
    setState(() => _submitted = true);
    MoishoToast.show(context, '동아리 관리자가 검토 후 연락드릴게요.',
        tone: 'success', title: '신청서 제출 완료! 🎉');
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ClubDetailScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _doneScreen();

    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '가입 신청서', onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 20, T.padScreen, 20),
            physics: const BouncingScrollPhysics(),
            children: [
              _clubHeaderCard(),
              const SizedBox(height: 24),
              _instrumentsSection(),
              const SizedBox(height: 24),
              _daysSection(),
              const SizedBox(height: 24),
              _introSection(),
              const SizedBox(height: 24),
              _experienceSection(),
              _agreementCheck(),
              const SizedBox(height: 8),
              _notice(),
            ],
          ),
        ),
        StickyBar(
          child: MButton(
            '가입 신청서 제출하기',
            variant: 'primary',
            size: 'lg',
            block: true,
            disabled: !_canSubmit,
            leadingIcon: const Icon(LucideIcons.send, size: 17, color: T.white),
            onTap: _handleSubmit,
          ),
        ),
      ]),
    );
  }

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
                  Text('신청서 제출 완료!',
                      textAlign: TextAlign.center,
                      style: tx(22, FontWeight.w700, T.textStrong, ls: -0.02, height: 1.3)),
                  const SizedBox(height: 10),
                  Text("홍대 연합 밴드 '사운드' 관리자가\n검토 후 결과를 알려드릴게요.",
                      textAlign: TextAlign.center,
                      style: tx(14, FontWeight.w500, T.textMuted, height: 1.6)),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final i in _instrumentsSel)
                        MTag(i.length > 3 ? i.substring(3) : i, tone: 'blue', leadingHash: true),
                      for (final d in _daysSel) MTag('$d요일', tone: 'neutral'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]),
      );

  // ── 동아리 헤더 카드 ──
  Widget _clubHeaderCard() => MCard(
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
                  const SizedBox(height: 4),
                  Row(children: [
                    _glassBadge('🎸 밴드'),
                    const SizedBox(width: 6),
                    _glassBadge('👥 멤버 18명'),
                  ]),
                ]),
              ),
            ]),
          ),
          Container(
            width: double.infinity,
            color: T.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Wrap(spacing: 16, runSpacing: 8, children: [
              _metaItem(LucideIcons.calendar, '매주 토요일'),
              _metaItem(LucideIcons.mapPin, '홍대 사운드스튜디오'),
              _metaItem(LucideIcons.coins, '월 20,000원'),
            ]),
          ),
        ]),
      );

  Widget _glassBadge(String text) => Container(
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(T.rPill),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Text(text, style: tx(12, FontWeight.w700, T.white, height: 1)),
      );

  Widget _metaItem(IconData icon, String val) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: T.textMuted),
          const SizedBox(width: 5),
          Text(val, style: tx(11, FontWeight.w500, T.textMuted, height: 1)),
        ],
      );

  // ── 섹션 헤더(번호 + 라벨 + 필수/선택) ──
  Widget _stepHeader(String num, String label, String tag, Color tagColor,
      {Color numBg = T.primary, double bottomGap = 12}) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomGap),
      child: Row(children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: numBg, shape: BoxShape.circle),
          child: Text(num, style: tx(11, FontWeight.w700, T.white, height: 1)),
        ),
        const SizedBox(width: 6),
        Text(label, style: tx(14, FontWeight.w700, T.textTitle, height: 1)),
        const SizedBox(width: 6),
        Text(tag, style: tx(11, FontWeight.w500, tagColor, height: 1)),
      ]),
    );
  }

  // ── 1. 담당 파트 ──
  Widget _instrumentsSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader('1', '담당 파트', '필수', T.danger, bottomGap: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26, bottom: 12),
            child: Text('중복 선택 가능', style: tx(12, FontWeight.w500, T.textMuted, height: 1)),
          ),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final inst in _instruments) _instrumentChip(inst),
          ]),
        ],
      );

  Widget _instrumentChip(String inst) {
    final on = _instrumentsSel.contains(inst);
    return GestureDetector(
      onTap: () => _toggle(_instrumentsSel, inst),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: on ? T.primarySoft : T.white,
          borderRadius: BorderRadius.circular(T.rPill),
          border: Border.all(color: on ? T.primary : T.borderDefault, width: 1.5),
        ),
        child: Text(inst,
            style: tx(13, on ? FontWeight.w700 : FontWeight.w500, on ? T.primary : T.textBody, height: 1)),
      ),
    );
  }

  // ── 2. 활동 가능 요일 ──
  Widget _daysSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader('2', '활동 가능 요일', '필수', T.danger),
          Row(children: [
            for (var i = 0; i < _days.length; i++) ...[
              Expanded(child: _dayChip(_days[i])),
              if (i != _days.length - 1) const SizedBox(width: 6),
            ],
          ]),
        ],
      );

  Widget _dayChip(String day) {
    final on = _daysSel.contains(day);
    return GestureDetector(
      onTap: () => _toggle(_daysSel, day),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? T.primary : T.white,
          borderRadius: BorderRadius.circular(T.rMd),
          border: Border.all(color: on ? T.primary : T.borderDefault, width: 1.5),
        ),
        child: Text(day, style: tx(13, FontWeight.w700, on ? T.white : T.textMuted, height: 1)),
      ),
    );
  }

  // ── 3. 지원 동기 ──
  Widget _introSection() {
    final valid = _introCtrl.text.length >= 20;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader('3', '지원 동기', '필수 · 20자 이상', T.danger, bottomGap: 10),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final m in _motivations) _motivationChip(m),
        ]),
        const SizedBox(height: 10),
        Stack(children: [
          TextField(
            controller: _introCtrl,
            onChanged: (_) => setState(() {}),
            maxLines: null,
            minLines: 4,
            style: tx(14, FontWeight.w500, T.textBody, height: 1.6),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.fromLTRB(14, 12, 14, 30),
              hintText: '예) 대학교 때부터 기타를 쳐왔는데, 혼자 연습하는 것보다 함께 합주하며 성장하고 싶어서 지원합니다…',
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
            child: Text('${_introCtrl.text.length}자',
                style: tx(11, FontWeight.w500, valid ? T.primary : T.textDisabled, height: 1)),
          ),
        ]),
      ],
    );
  }

  Widget _motivationChip(String m) {
    final on = _motivationsSel.contains(m);
    return GestureDetector(
      onTap: () => _toggleMotivation(m),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: on ? T.accentSoft : T.gray50,
          borderRadius: BorderRadius.circular(T.rPill),
          border: Border.all(color: on ? T.purple400 : T.borderSubtle, width: 1.5),
        ),
        child: Text(m, style: tx(12, FontWeight.w500, on ? T.accent : T.textMuted, height: 1)),
      ),
    );
  }

  // ── 4. 연주 경력 (선택) ──
  Widget _experienceSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader('4', '연주 경력', '선택', T.textDisabled, numBg: T.gray300, bottomGap: 10),
          TextField(
            controller: _experienceCtrl,
            maxLines: null,
            minLines: 3,
            style: tx(14, FontWeight.w500, T.textBody, height: 1.6),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              hintText: '예) 대학 밴드 동아리 2년 활동, 인디 공연 3회 참여…',
              hintStyle: tx(14, FontWeight.w500, T.textDisabled, height: 1.6),
              filled: true,
              fillColor: T.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(T.rLg),
                borderSide: const BorderSide(color: T.borderDefault, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(T.rLg),
                borderSide: const BorderSide(color: T.borderDefault, width: 1.5),
              ),
            ),
          ),
        ],
      );

  // ── 동의 체크 ──
  Widget _agreementCheck() => GestureDetector(
        onTap: () => setState(() => _agreed = !_agreed),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _agreed ? T.primarySoft : T.gray50,
            borderRadius: BorderRadius.circular(T.rLg),
            border: Border.all(color: _agreed ? T.primary : T.borderDefault, width: 1.5),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _agreed ? T.primary : T.white,
                borderRadius: BorderRadius.circular(T.rMini),
                border: Border.all(color: _agreed ? T.primary : T.borderDefault, width: 2),
              ),
              child: _agreed ? const Icon(LucideIcons.check, size: 13, color: T.white) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text('동아리 활동 규칙(정기 합주 참석, 회비 납부 등)을 숙지했으며, 성실하게 활동할 것을 서약합니다.',
                  style: tx(13, FontWeight.w500, T.textBody, height: 1.5)),
            ),
          ]),
        ),
      );

  // ── 유의사항 ──
  Widget _notice() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: T.gray50,
          borderRadius: BorderRadius.circular(T.rMd),
          border: Border.all(color: T.borderSubtle),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(LucideIcons.info, size: 13, color: T.textDisabled),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text('가입 심사는 3~5 영업일 내 완료되며, 결과는 앱 알림 및 DM으로 안내됩니다.',
                style: tx(11, FontWeight.w500, T.textDisabled, height: 1.6)),
          ),
        ]),
      );
}
