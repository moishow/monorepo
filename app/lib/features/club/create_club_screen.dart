// 동아리 개설 — prototype CreateClubScreen (f566565a:680).
// 대표이미지·이름·카테고리·소개(카운터)·정원·가입옵션 토글 → 하단 CTA로 개설.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import 'club_room_screen.dart';

class CreateClubScreen extends StatefulWidget {
  const CreateClubScreen({super.key});

  @override
  State<CreateClubScreen> createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends State<CreateClubScreen> {
  static const _cats = ['문화·예술', '운동·스포츠', '학술·자기계발', '취미·라이프', '봉사·기타'];

  final _name = TextEditingController();
  final _intro = TextEditingController();
  final _capacity = TextEditingController(text: '30');
  String? _cat;
  bool _openRecruit = true;
  int _introLen = 0;

  bool get _canCreate => _name.text.trim().isNotEmpty && _cat != null && _intro.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    _intro.addListener(() => setState(() => _introLen = _intro.text.length));
  }

  @override
  void dispose() {
    _name.dispose();
    _intro.dispose();
    _capacity.dispose();
    super.dispose();
  }

  void _create() {
    MoishoToast.show(context, "'${_name.text}' 동아리가 개설됐어요! 회장으로 등록됩니다.", tone: 'success');
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ClubRoomScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '동아리 개설', onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            physics: const BouncingScrollPhysics(),
            children: [
              // ── 대표 이미지 ──
              _label('대표 이미지'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => MoishoToast.show(context, '이미지를 선택해 주세요.', tone: 'info'),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 132,
                  decoration: BoxDecoration(
                    color: T.gray50,
                    borderRadius: BorderRadius.circular(T.rLg),
                    border: Border.all(color: T.borderDefault, width: 1.5, style: BorderStyle.solid),
                  ),
                  child: const _DashedHint(),
                ),
              ),
              const SizedBox(height: 22),

              // ── 동아리 이름 ──
              _label('동아리 이름'),
              const SizedBox(height: 8),
              _field(
                controller: _name,
                height: 46,
                hint: "예: 홍대 연합 밴드 '사운드'",
              ),
              const SizedBox(height: 22),

              // ── 카테고리 ──
              _label('카테고리'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in _cats) _catChip(c),
                ],
              ),
              const SizedBox(height: 22),

              // ── 동아리 소개 ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('동아리 소개', style: tx(12, FontWeight.w600, T.textMuted, height: 1)),
                  Text('$_introLen/200', style: tx(11, FontWeight.w500, T.textDisabled, height: 1, tab: true)),
                ],
              ),
              const SizedBox(height: 8),
              _field(
                controller: _intro,
                maxLines: 4,
                maxLength: 200,
                hint: '어떤 동아리인지, 어떤 활동을 하는지 소개해 주세요.',
              ),
              const SizedBox(height: 22),

              // ── 모집 정원 ──
              _label('모집 정원'),
              const SizedBox(height: 8),
              Row(children: [
                SizedBox(
                  width: 120,
                  child: _field(
                    controller: _capacity,
                    height: 46,
                    align: TextAlign.right,
                    numeric: true,
                  ),
                ),
                const SizedBox(width: 10),
                Text('명까지', style: tx(14, FontWeight.w500, T.textMuted, height: 1)),
              ]),
              const SizedBox(height: 22),

              // ── 옵션 ──
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: T.borderSubtle))),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('가입 신청 즉시 받기', style: tx(14, FontWeight.w600, T.textTitle, height: 1.3)),
                      const SizedBox(height: 3),
                      Text('신청서를 받아 운영진이 승인해요', style: tx(12, FontWeight.w500, T.textMuted, height: 1.3)),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  _ToggleSwitch(value: _openRecruit, onChanged: (v) => setState(() => _openRecruit = v)),
                ]),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),

        // ── 고정 CTA ──
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          decoration: const BoxDecoration(
            color: T.white,
            border: Border(top: BorderSide(color: T.borderSubtle)),
          ),
          child: SafeArea(
            top: false,
            child: MButton(
              '동아리 개설하기',
              variant: 'primary',
              size: 'lg',
              block: true,
              disabled: !_canCreate,
              onTap: _canCreate ? _create : null,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _label(String text) => Text(text, style: tx(12, FontWeight.w600, T.textMuted, height: 1));

  Widget _catChip(String c) {
    final on = _cat == c;
    return GestureDetector(
      onTap: () => setState(() => _cat = c),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? T.primary : T.white,
          borderRadius: BorderRadius.circular(T.rPill),
          border: Border.all(color: on ? T.primary : T.borderDefault, width: 1.5),
        ),
        child: Text(c, style: tx(13, on ? FontWeight.w700 : FontWeight.w500, on ? T.white : T.textBody, height: 1)),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    double? height,
    int maxLines = 1,
    int? maxLength,
    String? hint,
    TextAlign align = TextAlign.left,
    bool numeric = false,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: T.white,
        borderRadius: BorderRadius.circular(T.rMd),
        border: Border.all(color: T.borderDefault, width: 1.5),
      ),
      padding: maxLines > 1
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
          : const EdgeInsets.symmetric(horizontal: 14),
      alignment: maxLines > 1 ? Alignment.topLeft : Alignment.centerLeft,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        textAlign: align,
        keyboardType: numeric ? TextInputType.number : null,
        cursorColor: T.primary,
        style: tx(14, FontWeight.w500, T.textStrong, height: maxLines > 1 ? 1.6 : 1, tab: numeric),
        decoration: InputDecoration(
          isCollapsed: true,
          counterText: '',
          border: InputBorder.none,
          hintText: hint,
          hintStyle: tx(14, FontWeight.w500, T.textDisabled, height: maxLines > 1 ? 1.6 : 1),
        ),
      ),
    );
  }
}

// ── 대표 이미지 자리(점선 안내) ──
class _DashedHint extends StatelessWidget {
  const _DashedHint();

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.image, size: 26, color: T.textDisabled),
          const SizedBox(height: 8),
          Text('커버 이미지 추가', style: tx(13, FontWeight.w600, T.textMuted, height: 1)),
        ],
      );
}

// ── 토글 스위치(prototype Switch) ──
class _ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 46,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? T.primary : T.gray200,
          borderRadius: BorderRadius.circular(T.rPill),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(color: T.white, shape: BoxShape.circle, boxShadow: T.shadowXs),
        ),
      ),
    );
  }
}
