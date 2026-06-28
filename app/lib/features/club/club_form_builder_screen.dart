// 가입폼 빌더 — prototype ClubFormBuilderScreen (4d2972a5:23).
// 양식 기본정보·기본제공 항목 토글·커스텀 질문 빌더(유형/옵션/필수/순서)·질문 추가 메뉴·항목 요약·저장.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import 'club_join_apply_screen.dart';

// ── 기본 제공 항목(항상 포함 옵션) ──
class _BuiltIn {
  final String id, label, typeLabel, desc;
  final IconData icon;
  const _BuiltIn(this.id, this.label, this.icon, this.typeLabel, this.desc);
}

const _builtInFields = [
  _BuiltIn('days', '활동 가능 요일', LucideIcons.calendar, '요일 선택형', '월~일 중 복수 선택'),
  _BuiltIn('motivation', '지원 동기', LucideIcons.heart, '장문 서술형', '최소 20자 이상 자유 서술'),
  _BuiltIn('experience', '관련 경력', LucideIcons.star, '장문 서술형', '선택 입력 — 비워도 됨'),
];

// ── 질문 유형 ──
class _QType {
  final String id, label, sub;
  final IconData icon;
  const _QType(this.id, this.label, this.icon, this.sub);
}

const _questionTypes = [
  _QType('short', '단답형', LucideIcons.minus, '한 줄 짧은 답변'),
  _QType('long', '장문형', LucideIcons.alignLeft, '여러 줄 서술형 답변'),
  _QType('choice', '객관식', LucideIcons.list, '하나만 선택 가능한 보기'),
  _QType('checkbox', '체크박스', LucideIcons.checkSquare, '여러 개 선택 가능한 보기'),
];

IconData _typeIcon(String t) =>
    _questionTypes.where((q) => q.id == t).map((q) => q.icon).firstOrNull ?? LucideIcons.helpCircle;
String _typeLabel(String t) =>
    _questionTypes.where((q) => q.id == t).map((q) => q.label).firstOrNull ?? t;

// 가변 질문(useState 객체 리터럴 → 가변 모델).
class _Q {
  final int id;
  String type;
  String label;
  bool required;
  List<String> choices;
  _Q({required this.id, required this.type, required this.label, required this.required, required this.choices});
}

class ClubFormBuilderScreen extends StatefulWidget {
  const ClubFormBuilderScreen({super.key});

  @override
  State<ClubFormBuilderScreen> createState() => _ClubFormBuilderScreenState();
}

class _ClubFormBuilderScreenState extends State<ClubFormBuilderScreen> {
  final _titleCtrl = TextEditingController(text: "홍대 연합 밴드 '사운드' 가입 신청서");
  final _descCtrl = TextEditingController(
      text: '밴드 동아리 가입을 희망하시는 분들을 위한 신청서입니다. 성실하게 작성해 주세요 😊');

  final _builtIns = <String, bool>{'days': true, 'motivation': true, 'experience': false};

  final List<_Q> _questions = [
    _Q(id: 1, type: 'choice', label: '담당 파트 (해당 시 선택)', required: true, choices: [
      '🎸 기타', '🎹 키보드', '🎺 보컬', '🥁 드럼', '🎻 베이스', '🎷 관악기',
    ]),
    _Q(id: 2, type: 'short', label: '현재 사용하는 악기 브랜드/모델', required: false, choices: []),
    _Q(id: 3, type: 'choice', label: '합주 경험 있으신가요?', required: true, choices: [
      '있어요 (1년 미만)', '있어요 (1년 이상)', '없어요',
    ]),
  ];

  int _nextId = 100;
  int? _editingId;
  bool _showAddMenu = false;

  // 현재 편집 중인 질문의 라이브 컨트롤러(editingId 단일 → 한 번에 하나만 존재).
  TextEditingController? _labelCtrl;
  List<TextEditingController> _choiceCtrls = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _disposeEditCtrls();
    super.dispose();
  }

  void _disposeEditCtrls() {
    _labelCtrl?.dispose();
    _labelCtrl = null;
    for (final c in _choiceCtrls) {
      c.dispose();
    }
    _choiceCtrls = [];
  }

  void _beginEdit(_Q q) {
    _disposeEditCtrls();
    _labelCtrl = TextEditingController(text: q.label);
    _choiceCtrls = q.choices.map((c) => TextEditingController(text: c)).toList();
    setState(() {
      _editingId = q.id;
      _showAddMenu = false;
    });
  }

  void _endEdit() {
    _disposeEditCtrls();
    setState(() => _editingId = null);
  }


  void _toggleBuiltIn(String id) => setState(() => _builtIns[id] = !(_builtIns[id] ?? false));

  void _addQuestion(String type) {
    final q = _Q(
      id: _nextId++,
      type: type,
      label: '',
      required: false,
      choices: (type == 'choice' || type == 'checkbox') ? ['옵션 1', '옵션 2'] : [],
    );
    setState(() => _questions.add(q));
    _beginEdit(q);
  }

  void _setType(_Q q, String type) {
    // 프로토타입과 동일 — 유형만 바꾸고 choices 는 그대로(빈 채로) 둔다.
    setState(() => q.type = type);
  }

  void _removeQ(int id) {
    if (_editingId == id) _disposeEditCtrls();
    setState(() {
      _questions.removeWhere((q) => q.id == id);
      if (_editingId == id) _editingId = null;
    });
  }

  void _moveQ(int id, int dir) {
    final idx = _questions.indexWhere((q) => q.id == id);
    if (idx + dir < 0 || idx + dir >= _questions.length) return;
    setState(() {
      final tmp = _questions[idx];
      _questions[idx] = _questions[idx + dir];
      _questions[idx + dir] = tmp;
    });
  }

  void _addChoice(_Q q) {
    setState(() {
      q.choices = [...q.choices, '옵션 ${q.choices.length + 1}'];
      _choiceCtrls = [..._choiceCtrls, TextEditingController(text: q.choices.last)];
    });
  }

  void _removeChoice(_Q q, int ci) {
    final ctrl = _choiceCtrls[ci];
    setState(() {
      q.choices = [for (var i = 0; i < q.choices.length; i++) if (i != ci) q.choices[i]];
      _choiceCtrls = [for (var i = 0; i < _choiceCtrls.length; i++) if (i != ci) _choiceCtrls[i]];
    });
    ctrl.dispose();
  }

  int get _totalFields => _builtIns.values.where((v) => v).length + _questions.length;

  void _handleSave() {
    MoishoToast.show(context, '총 $_totalFields개 항목으로 저장됐어요.',
        tone: 'success', title: '신청서 양식 저장 완료!');
    Navigator.of(context).maybePop();
  }

  void _preview() => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ClubJoinApplyScreen()),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(
          title: '신청서 양식 만들기',
          onBack: () => Navigator.of(context).maybePop(),
          actions: [
            MinTapTarget(
              Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(LucideIcons.eye, size: 15, color: T.primary),
                const SizedBox(width: 4),
                Text('미리보기', style: tx(13, FontWeight.w600, T.primary, height: 1)),
              ]),
              onTap: _preview,
              min: 38,
            ),
          ],
        ),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              _basicInfoCard(),
              const SizedBox(height: 20),
              _builtInSection(),
              if (_questions.isNotEmpty) ...[
                const SizedBox(height: 20),
                _questionsSection(),
              ],
              const SizedBox(height: 16),
              _addQuestionBlock(),
              const SizedBox(height: 20),
              _summary(),
            ],
          ),
        ),
        StickyBar(
          child: MButton('신청서 양식 저장하기',
              variant: 'primary', size: 'lg', block: true,
              leadingIcon: const Icon(LucideIcons.save, size: 17, color: T.white),
              onTap: _handleSave),
        ),
      ]),
    );
  }

  // ── 양식 기본 정보 ──
  Widget _basicInfoCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: T.white,
          borderRadius: BorderRadius.circular(T.r2xl),
          boxShadow: T.shadowCard,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(T.rMd)),
              child: const Icon(LucideIcons.fileText, size: 14, color: T.primary),
            ),
            const SizedBox(width: 8),
            Text('양식 기본 정보', style: tx(14, FontWeight.w700, T.textTitle, height: 1)),
          ]),
          const SizedBox(height: 14),
          Text('양식 제목', style: tx(12, FontWeight.w600, T.textMuted, height: 1)),
          const SizedBox(height: 6),
          _field(
            controller: _titleCtrl,
            height: 42,
            style: tx(14, FontWeight.w600, T.textTitle, height: 1),
          ),
          const SizedBox(height: 12),
          Text('안내 문구', style: tx(12, FontWeight.w600, T.textMuted, height: 1)),
          const SizedBox(height: 6),
          _field(
            controller: _descCtrl,
            minLines: 2,
            maxLines: 2,
            contentPad: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            style: tx(13, FontWeight.w500, T.textBody, height: 1.5),
          ),
        ]),
      );

  Widget _field({
    required TextEditingController controller,
    required TextStyle style,
    double? height,
    int minLines = 1,
    int maxLines = 1,
    EdgeInsets contentPad = const EdgeInsets.symmetric(horizontal: 12),
    ValueChanged<String>? onChanged,
  }) =>
      SizedBox(
        height: height,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          minLines: minLines,
          maxLines: maxLines,
          style: style,
          cursorColor: T.primary,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: contentPad,
            filled: true,
            fillColor: T.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(T.rMd),
              borderSide: const BorderSide(color: T.borderDefault, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(T.rMd),
              borderSide: const BorderSide(color: T.primary, width: 1.5),
            ),
          ),
        ),
      );

  // ── 기본 제공 항목 ──
  Widget _builtInSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(LucideIcons.layers, size: 14, color: T.textMuted),
          const SizedBox(width: 6),
          Text('기본 제공 항목', style: tx(13, FontWeight.w700, T.textTitle, height: 1)),
          const SizedBox(width: 6),
          const MBadge('체크하면 신청서에 포함돼요', tone: 'neutral', variant: 'soft'),
        ]),
        const SizedBox(height: 12),
        for (var i = 0; i < _builtInFields.length; i++) ...[
          _builtInRow(_builtInFields[i]),
          if (i < _builtInFields.length - 1) const SizedBox(height: 8),
        ],
      ]);

  Widget _builtInRow(_BuiltIn f) {
    final on = _builtIns[f.id] ?? false;
    return GestureDetector(
      onTap: () => _toggleBuiltIn(f.id),
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: on ? 1 : 0.6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: on ? T.primarySoft : T.white,
            borderRadius: BorderRadius.circular(T.rXl),
            border: Border.all(color: on ? T.primary : T.borderSubtle, width: 1.5),
          ),
          child: Row(children: [
            // 체크박스
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: on ? T.primary : T.white,
                borderRadius: BorderRadius.circular(T.rMini),
                border: Border.all(color: on ? T.primary : T.borderDefault, width: 2),
              ),
              child: on ? const Icon(LucideIcons.check, size: 13, color: T.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(
                    child: Text(f.label,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: tx(13, FontWeight.w700, on ? T.primary : T.textTitle, height: 1)),
                  ),
                  const SizedBox(width: 6),
                  // 입력 타입 뱃지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: on
                          ? T.primary.withValues(alpha: 0.12) // proto rgba(99,102,241,0.12)
                          : T.gray100,
                      borderRadius: BorderRadius.circular(T.rPill),
                      border: Border.all(
                        color: on
                            ? T.primary.withValues(alpha: 0.25) // proto rgba(99,102,241,0.25)
                            : T.borderSubtle,
                      ),
                    ),
                    child: Text(f.typeLabel,
                        style: tx(10, FontWeight.w600, on ? T.primary : T.textDisabled, height: 1)),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(f.desc, style: tx(11, FontWeight.w500, T.textDisabled, height: 1)),
              ]),
            ),
            const SizedBox(width: 8),
            Text(on ? '포함' : '제외',
                style: tx(11, FontWeight.w700, on ? T.primary : T.textDisabled, height: 1)),
          ]),
        ),
      ),
    );
  }

  // ── 커스텀 질문 목록 ──
  Widget _questionsSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(LucideIcons.plusCircle, size: 14, color: T.textMuted),
          const SizedBox(width: 6),
          Text('추가 질문 (${_questions.length}개)', style: tx(13, FontWeight.w700, T.textTitle, height: 1)),
        ]),
        const SizedBox(height: 12),
        for (var i = 0; i < _questions.length; i++) ...[
          _questionCard(_questions[i], i),
          if (i < _questions.length - 1) const SizedBox(height: 10),
        ],
      ]);

  Widget _questionCard(_Q q, int idx) {
    final editing = _editingId == q.id;
    return ClipRRect(
      borderRadius: BorderRadius.circular(T.rXl),
      child: Container(
        decoration: BoxDecoration(
          color: T.white,
          borderRadius: BorderRadius.circular(T.rXl),
          boxShadow: T.shadowCard,
          // 편집 시 2px primary, 평소 2px transparent → 레이아웃 점프 방지.
          border: Border.all(color: editing ? T.primary : Colors.transparent, width: 2),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _questionHeader(q, idx, editing),
          if (editing) _editPanel(q),
        ]),
      ),
    );
  }

  // ── 질문 헤더 ──
  Widget _questionHeader(_Q q, int idx, bool editing) {
    final isFirst = idx == 0;
    final isLast = idx == _questions.length - 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: editing ? T.primarySoft : T.white,
        border: const Border(bottom: BorderSide(color: T.borderSubtle)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 28, height: 28,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(color: T.gray50, borderRadius: BorderRadius.circular(T.rSm)),
          child: Icon(_typeIcon(q.type), size: 13, color: T.textMuted),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (editing)
              TextField(
                controller: _labelCtrl,
                autofocus: true,
                onChanged: (v) => setState(() => q.label = v),
                style: tx(13, FontWeight.w600, T.textTitle, height: 1),
                cursorColor: T.primary,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: '질문 내용을 입력하세요',
                  hintStyle: tx(13, FontWeight.w600, T.textDisabled, height: 1),
                ),
              )
            else
              GestureDetector(
                onTap: () => _beginEdit(q),
                behavior: HitTestBehavior.opaque,
                child: Text(
                  q.label.isEmpty ? '질문 내용을 입력하세요…' : q.label,
                  style: tx(13, FontWeight.w600, q.label.isEmpty ? T.textDisabled : T.textTitle, height: 1.3),
                ),
              ),
            const SizedBox(height: 4),
            Row(children: [
              MTag(_typeLabel(q.type), tone: 'neutral'),
              if (q.required) ...[
                const SizedBox(width: 6),
                const MBadge('필수', tone: 'danger', variant: 'soft'),
              ],
            ]),
          ]),
        ),
        const SizedBox(width: 6),
        // 순서 이동
        Row(mainAxisSize: MainAxisSize.min, children: [
          _moveBtn(LucideIcons.chevronUp, disabled: isFirst, onTap: () => _moveQ(q.id, -1)),
          const SizedBox(width: 2),
          _moveBtn(LucideIcons.chevronDown, disabled: isLast, onTap: () => _moveQ(q.id, 1)),
        ]),
      ]),
    );
  }

  Widget _moveBtn(IconData icon, {required bool disabled, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: disabled ? null : onTap,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: disabled ? 0.3 : 1,
          child: Container(
            width: 26, height: 26,
            decoration: BoxDecoration(color: T.gray50, borderRadius: BorderRadius.circular(T.rSm)),
            child: Icon(icon, size: 13, color: T.textMuted),
          ),
        ),
      );

  // ── 편집 패널 ──
  Widget _editPanel(_Q q) {
    final hasChoices = q.type == 'choice' || q.type == 'checkbox';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: T.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 질문 유형 선택
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final t in _questionTypes) _typeChip(q, t),
        ]),
        if (hasChoices) ...[
          const SizedBox(height: 10),
          _choiceEditor(q),
        ],
        const SizedBox(height: 10),
        // 필수 여부 + 완료/삭제
        Container(
          padding: const EdgeInsets.only(top: 6),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: T.borderSubtle))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            GestureDetector(
              onTap: () => setState(() => q.required = !q.required),
              behavior: HitTestBehavior.opaque,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _requiredToggle(q.required),
                const SizedBox(width: 7),
                Text('필수 항목',
                    style: tx(12, FontWeight.w600, q.required ? T.danger : T.textMuted, height: 1)),
              ]),
            ),
            Row(mainAxisSize: MainAxisSize.min, children: [
              _panelBtn('완료', bg: T.primarySoft, fg: T.primary, onTap: _endEdit),
              const SizedBox(width: 6),
              _panelBtn('삭제', bg: T.dangerSoft, fg: T.danger, onTap: () => _removeQ(q.id)),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _typeChip(_Q q, _QType t) {
    final on = q.type == t.id;
    return GestureDetector(
      onTap: () => _setType(q, t.id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: on ? T.primarySoft : T.gray50,
          borderRadius: BorderRadius.circular(T.rPill),
          border: Border.all(color: on ? T.primary : T.borderSubtle, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(t.icon, size: 11, color: on ? T.primary : T.textMuted),
          const SizedBox(width: 4),
          Text(t.label, style: tx(11, FontWeight.w600, on ? T.primary : T.textMuted, height: 1)),
        ]),
      ),
    );
  }

  Widget _choiceEditor(_Q q) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var ci = 0; ci < q.choices.length; ci++) ...[
          if (ci > 0) const SizedBox(height: 6),
          Row(children: [
            Container(
              width: 14, height: 14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(q.type == 'checkbox' ? 4 : 7),
                border: Border.all(color: T.borderDefault, width: 1.5),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _field(
                controller: _choiceCtrls[ci],
                height: 32,
                contentPad: const EdgeInsets.symmetric(horizontal: 10),
                style: tx(13, FontWeight.w500, T.textBody, height: 1),
                onChanged: (v) => setState(() => q.choices[ci] = v),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _removeChoice(q, ci),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 26, height: 26,
                decoration: BoxDecoration(color: T.gray50, borderRadius: BorderRadius.circular(T.rSm)),
                child: const Icon(LucideIcons.x, size: 12, color: T.textMuted),
              ),
            ),
          ]),
        ],
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _addChoice(q),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(T.rMd),
              border: Border.all(color: T.borderDefault, width: 1.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(LucideIcons.plus, size: 13, color: T.textMuted),
              const SizedBox(width: 5),
              Text('옵션 추가', style: tx(12, FontWeight.w600, T.textMuted, height: 1)),
            ]),
          ),
        ),
      ]);

  Widget _requiredToggle(bool on) => SizedBox(
        width: 36, height: 20,
        child: Stack(children: [
          Container(
            decoration: BoxDecoration(
              color: on ? T.danger : T.gray200,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: 3,
            left: on ? 19 : 3,
            child: Container(
              width: 14, height: 14,
              decoration: BoxDecoration(
                color: T.white,
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 2, offset: Offset(0, 1))],
              ),
            ),
          ),
        ]),
      );

  Widget _panelBtn(String label, {required Color bg, required Color fg, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(T.rMd)),
          child: Text(label, style: tx(12, FontWeight.w600, fg, height: 1)),
        ),
      );

  // ── 질문 추가 버튼 + 메뉴 ──
  Widget _addQuestionBlock() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        GestureDetector(
          onTap: () => setState(() => _showAddMenu = !_showAddMenu),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _showAddMenu ? T.primarySoft : T.white,
              borderRadius: BorderRadius.circular(T.rXl),
              border: Border.all(
                color: T.borderDefault,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_showAddMenu ? LucideIcons.minus : LucideIcons.plus,
                  size: 16, color: _showAddMenu ? T.primary : T.textMuted),
              const SizedBox(width: 8),
              Text('질문 추가하기',
                  style: tx(13, FontWeight.w700, _showAddMenu ? T.primary : T.textMuted, height: 1)),
            ]),
          ),
        ),
        if (_showAddMenu) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: T.white,
              borderRadius: BorderRadius.circular(T.rXl),
              border: Border.all(color: T.borderDefault, width: 1.5),
              boxShadow: T.shadowLg,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(T.rXl),
              child: Column(children: [
                for (var i = 0; i < _questionTypes.length; i++)
                  _addMenuRow(_questionTypes[i], last: i == _questionTypes.length - 1),
              ]),
            ),
          ),
        ],
      ]);

  Widget _addMenuRow(_QType t, {required bool last}) => GestureDetector(
        onTap: () => _addQuestion(t.id),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            border: last ? null : const Border(bottom: BorderSide(color: T.borderSubtle)),
          ),
          child: Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: T.gray50, borderRadius: BorderRadius.circular(T.rMd)),
              child: Icon(t.icon, size: 15, color: T.textMuted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.label, style: tx(13, FontWeight.w700, T.textTitle, height: 1)),
                const SizedBox(height: 3),
                Text(t.sub, style: tx(11, FontWeight.w500, T.textDisabled, height: 1.3)),
              ]),
            ),
          ]),
        ),
      );

  // ── 현재 항목 요약 ──
  Widget _summary() {
    final includedBuiltIns =
        _builtInFields.where((f) => _builtIns[f.id] ?? false).toList();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: T.gray50, borderRadius: BorderRadius.circular(T.rLg)),
      child: Row(children: [
        const Icon(LucideIcons.clipboardList, size: 14, color: T.textMuted),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(style: tx(12, FontWeight.w500, T.textMuted, height: 1), children: [
            const TextSpan(text: '총 '),
            TextSpan(text: '$_totalFields개', style: tx(12, FontWeight.w700, T.primary, height: 1)),
            const TextSpan(text: ' 항목'),
          ]),
        ),
        const Spacer(),
        Flexible(
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 5, runSpacing: 5,
            children: [
              for (final f in includedBuiltIns) MTag(f.label, tone: 'blue'),
              if (_questions.isNotEmpty) MTag('+추가 ${_questions.length}개', tone: 'neutral'),
            ],
          ),
        ),
      ]),
    );
  }
}
