// 모임 만들기(폼) — prototype CreateMeetingScreen (f566565a:285).
// 동아리 선택·모임명·카테고리·일시·장소·소개·비용추산·사전펀딩세팅 → 하단 CTA로 개설.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import '../club/club_room_screen.dart';

class _Club {
  final String id, name, role, img;
  final int members;
  final bool canCreate;
  const _Club(this.id, this.name, this.role, this.members, this.canCreate, this.img);
}

class _Category {
  final String id, label;
  final Color color;
  const _Category(this.id, this.label, this.color);
}

class _CostItem {
  final TextEditingController name;
  final TextEditingController amount;
  _CostItem(String n, String a)
      : name = TextEditingController(text: n),
        amount = TextEditingController(text: a);
  void dispose() {
    name.dispose();
    amount.dispose();
  }
}

class CreateMeetingScreen extends StatefulWidget {
  const CreateMeetingScreen({super.key});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  // 내가 속한 동아리 중 개설 권한(canCreate)이 있는 곳만 노출.
  static const _myClubs = [
    _Club('sound', "홍대 연합 밴드 '사운드'", '운영진', 18, true,
        'https://images.unsplash.com/photo-1501612780327-45045538702b?w=96&h=96&fit=crop&auto=format&q=80'),
    _Club('book', '책과 사람들 독서모임', '총무', 9, true,
        'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=96&h=96&fit=crop&auto=format&q=80'),
    _Club('film', '필름 사진 동호회', '부원', 24, false,
        'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=96&h=96&fit=crop&auto=format&q=80'),
    _Club('cook', '맛컰 요리 소모임', '운영진', 12, true,
        'https://images.unsplash.com/photo-1540317580384-e5d43616b9aa?w=96&h=96&fit=crop&auto=format&q=80'),
  ];

  static const _categories = [
    _Category('music', '공연·음악', T.accent),
    _Category('sports', '운동·스포츠', T.warning),
    _Category('study', '학술·스터디', T.primary),
    _Category('hobby', '취미·라이프', T.success),
    _Category('meal', '친목·식사', Color(0xFFEC4899)), // proto #EC4899
  ];

  late final List<_Club> _eligible = _myClubs.where((c) => c.canCreate).toList();
  late String _selClub = _eligible.first.id;
  String _selCategory = 'music';

  final _nameCtrl = TextEditingController(text: '정기 대관 연습 및 뒷풀이');
  final _placeCtrl = TextEditingController(text: '합주실 A (홍대입구역 3분)');
  final _descCtrl = TextEditingController(text: '6월 정기 공연을 앞둔 합주 연습입니다. 연습 후 간단한 뒷풀이까지 함께해요!');
  final _minCtrl = TextEditingController(text: '5');
  final _headCtrl = TextEditingController(text: '10');

  final List<_CostItem> _items = [
    _CostItem('합주실 대관료', '150000'),
    _CostItem('뒷풀이 식비', '250000'),
  ];

  // 모임 일시 / 펀딩 데드라인 — 탭하면 펼쳐지는 인라인 피커.
  bool _mtOpen = false;
  DateTime _mtDate = DateTime(2026, 6, 15);
  String _mtTime = '18:00';
  bool _dlOpen = false;
  DateTime _dlDate = DateTime(2026, 6, 14);
  String _dlTime = '18:00';

  @override
  void initState() {
    super.initState();
    _headCtrl.addListener(() => setState(() {}));
    for (final it in _items) {
      it.amount.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _placeCtrl.dispose();
    _descCtrl.dispose();
    _minCtrl.dispose();
    _headCtrl.dispose();
    for (final it in _items) {
      it.dispose();
    }
    super.dispose();
  }

  int get _total => _items.fold(0, (s, it) => s + (int.tryParse(it.amount.text.trim()) ?? 0));
  int get _perHead {
    final hc = int.tryParse(_headCtrl.text.trim()) ?? 0;
    if (hc <= 0) return 0;
    return (_total / hc / 100).ceil() * 100;
  }

  void _addItem() {
    final it = _CostItem('', '');
    it.amount.addListener(() => setState(() {}));
    setState(() => _items.add(it));
  }

  static const _days = ['일', '월', '화', '수', '목', '금', '토'];
  String _fmtDT(DateTime d, String time) {
    final dateStr = '${d.year}년 ${d.month}월 ${d.day}일 (${_days[d.weekday % 7]})';
    return time.isNotEmpty ? '$dateStr $time' : dateStr;
  }

  void _submit() {
    MoishoToast.show(context, '부원들에게 펀딩 알림을 발송했어요.', tone: 'success', title: '모임 개설 완료! 🎉');
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ClubRoomScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.white,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '모임 생성 (사전 펀딩형)', onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: 20, bottom: 24),
            physics: const BouncingScrollPhysics(),
            children: [
              _clubSelect(),
              const SizedBox(height: 20),
              _pad(_labeledField('모임 명', _nameCtrl, hint: '모임 이름을 입력하세요', height: 48)),
              const SizedBox(height: 20),
              _pad(_categorySection()),
              const SizedBox(height: 20),
              _pad(_dateTimeSection()),
              const SizedBox(height: 20),
              _pad(_labeledField('장소', _placeCtrl, hint: '모임 장소를 입력하세요', height: 48)),
              const SizedBox(height: 20),
              _pad(_descSection()),
              const SizedBox(height: 20),
              _pad(_costSection()),
              const SizedBox(height: 20),
              _pad(_fundingCard()),
            ],
          ),
        ),
        StickyBar(
          child: MButton('사전 펀딩 모임 개설하기', variant: 'primary', size: 'lg', block: true, onTap: _submit),
        ),
      ]),
    );
  }

  Widget _pad(Widget child) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: child);

  // ── 동아리 선택 (가로 스크롤, 풀블리드) ──
  Widget _clubSelect() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
          child: Text('어느 동아리 모임인가요?', style: tx(14, FontWeight.w700, T.textTitle, height: 1)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text('모임 개설 권한이 있는 동아리만 표시돼요', style: tx(12, FontWeight.w500, T.textMuted, height: 1)),
        ),
        SizedBox(
          height: 152,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
            physics: const BouncingScrollPhysics(),
            itemCount: _eligible.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _clubCard(_eligible[i]),
          ),
        ),
      ]);

  Widget _clubCard(_Club c) {
    final on = _selClub == c.id;
    return GestureDetector(
      onTap: () => setState(() => _selClub = c.id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 132,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: on ? T.primarySoft : T.white,
          borderRadius: BorderRadius.circular(T.rXl),
          border: Border.all(color: on ? T.primary : T.borderSubtle, width: 1.5),
          boxShadow: on ? const [] : T.shadowXs,
        ),
        child: Stack(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(T.rMd),
              child: NetImage(url: c.img, width: 44, height: 44, fallback: Container(width: 44, height: 44, color: T.gray100)),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 31,
              child: Text(c.name,
                  maxLines: 2, overflow: TextOverflow.ellipsis, style: tx(12, FontWeight.w700, T.textTitle, height: 1.3)),
            ),
            const SizedBox(height: 7),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: on ? T.primary : T.gray100, borderRadius: BorderRadius.circular(T.rPill)),
                child: Text(c.role, style: tx(9, FontWeight.w700, on ? T.white : T.textMuted, height: 1)),
              ),
              const SizedBox(width: 5),
              Text('${c.members}명', style: tx(10, FontWeight.w500, T.textDisabled, height: 1)),
            ]),
          ]),
          if (on)
            Positioned(
              top: 0, right: 0,
              child: Container(
                width: 18, height: 18,
                decoration: const BoxDecoration(color: T.primary, shape: BoxShape.circle),
                child: const Icon(LucideIcons.check, size: 10, color: T.white),
              ),
            ),
        ]),
      ),
    );
  }

  // ── 카테고리 ──
  Widget _categorySection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('카테고리', style: tx(13, FontWeight.w600, T.textTitle, height: 1)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final cat in _categories) _catChip(cat),
        ]),
      ]);

  Widget _catChip(_Category cat) {
    final on = _selCategory == cat.id;
    return GestureDetector(
      onTap: () => setState(() => _selCategory = cat.id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: on ? cat.color : T.white,
          borderRadius: BorderRadius.circular(T.rPill),
          border: Border.all(color: on ? cat.color : T.borderDefault, width: 1.5),
        ),
        child: Text(cat.label, style: tx(13, FontWeight.w600, on ? T.white : T.textMuted, height: 1)),
      ),
    );
  }

  // ── 모임 일시 (인라인 피커) ──
  Widget _dateTimeSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('모임 일시', style: tx(13, FontWeight.w600, T.textTitle, height: 1)),
        const SizedBox(height: 6),
        _pickerTrigger(
          open: _mtOpen,
          label: _fmtDT(_mtDate, _mtTime),
          onTap: () => setState(() => _mtOpen = !_mtOpen),
        ),
        if (_mtOpen)
          _pickerPanel(
            date: _mtDate,
            time: _mtTime,
            onDate: (d) => setState(() => _mtDate = d),
            onTime: (t) => setState(() => _mtTime = t),
            onConfirm: () => setState(() => _mtOpen = false),
          ),
      ]);

  Widget _pickerTrigger({required bool open, required String label, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: T.white,
            borderRadius: BorderRadius.circular(T.rMd),
            border: Border.all(color: open ? T.primary : T.borderDefault, width: 1.5),
          ),
          child: Row(children: [
            Icon(LucideIcons.calendar, size: 18, color: open ? T.primary : T.textMuted),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: tx(14, FontWeight.w600, T.textStrong, height: 1, tab: true))),
            Icon(open ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 16, color: T.textMuted),
          ]),
        ),
      );

  Widget _pickerPanel({
    required DateTime date,
    required String time,
    required ValueChanged<DateTime> onDate,
    required ValueChanged<String> onTime,
    required VoidCallback onConfirm,
    List<Widget>? quickChips,
  }) =>
      Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: T.gray50,
          borderRadius: BorderRadius.circular(T.rLg),
          border: Border.all(color: T.borderSubtle, width: 1.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('날짜', style: tx(11, FontWeight.w500, T.textMuted, height: 1)),
          const SizedBox(height: 6),
          _pickerField(
            text: '${date.year}-${_two(date.month)}-${_two(date.day)}',
            icon: LucideIcons.calendar,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
              );
              if (picked != null) onDate(picked);
            },
          ),
          const SizedBox(height: 12),
          Text('시간', style: tx(11, FontWeight.w500, T.textMuted, height: 1)),
          const SizedBox(height: 6),
          _pickerField(
            text: time,
            icon: LucideIcons.clock,
            onTap: () async {
              final parts = time.split(':');
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                    hour: int.tryParse(parts.first) ?? 18, minute: int.tryParse(parts.last) ?? 0),
              );
              if (picked != null) onTime('${_two(picked.hour)}:${_two(picked.minute)}');
            },
          ),
          if (quickChips != null) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 6, runSpacing: 6, children: quickChips),
          ],
          const SizedBox(height: 12),
          MButton('확인', variant: 'primary', size: 'sm', block: true, onTap: onConfirm),
        ]),
      );

  Widget _pickerField({required String text, required IconData icon, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: T.white,
            borderRadius: BorderRadius.circular(T.rMd),
            border: Border.all(color: T.borderDefault, width: 1.5),
          ),
          child: Row(children: [
            Expanded(child: Text(text, style: tx(14, FontWeight.w600, T.textStrong, height: 1, tab: true))),
            Icon(icon, size: 16, color: T.textMuted),
          ]),
        ),
      );

  static String _two(int v) => v.toString().padLeft(2, '0');

  // ── 모임 소개 ──
  Widget _descSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('모임 소개', style: tx(13, FontWeight.w600, T.textTitle, height: 1)),
        const SizedBox(height: 8),
        _field(controller: _descCtrl, maxLines: 3, hint: '모임에 대한 소개를 적어주세요'),
      ]);

  // ── 비용 추산 ──
  Widget _costSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(LucideIcons.chartColumn, size: 18, color: T.textTitle),
          const SizedBox(width: 8),
          Text('비용 추산', style: tx(14, FontWeight.w700, T.textTitle, height: 1)),
        ]),
        const SizedBox(height: 4),
        Text('비용 불확실성을 없애드려요', style: tx(12, FontWeight.w500, T.textMuted, height: 1)),
        const SizedBox(height: 14),
        for (final it in _items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(child: _field(controller: it.name, height: 44, hint: '항목명')),
              const SizedBox(width: 8),
              Expanded(child: _amountField(it.amount)),
            ]),
          ),
        GestureDetector(
          onTap: _addItem,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: T.white,
              borderRadius: BorderRadius.circular(T.rMd),
              border: Border.all(color: T.borderDefault, width: 1.5, style: BorderStyle.solid),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(LucideIcons.plusCircle, size: 16, color: T.textMuted),
              const SizedBox(width: 6),
              Text('지출 항목 추가하기', style: tx(13, FontWeight.w600, T.textMuted, height: 1)),
            ]),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 14),
          padding: const EdgeInsets.only(top: 14),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: T.borderDefault, width: 1.5))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('총 예상 비용', style: tx(14, FontWeight.w600, T.textMuted, height: 1)),
            Text('${won(_total)}원', style: tx(20, FontWeight.w700, T.primary, ls: -0.02, height: 1, tab: true)),
          ]),
        ),
      ]);

  Widget _amountField(TextEditingController c) => Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: T.white,
          borderRadius: BorderRadius.circular(T.rMd),
          border: Border.all(color: T.borderDefault, width: 1.5),
        ),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: c,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              cursorColor: T.primary,
              style: tx(14, FontWeight.w500, T.textStrong, height: 1, tab: true),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: '금액',
                hintStyle: tx(14, FontWeight.w500, T.textDisabled, height: 1),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text('원', style: tx(13, FontWeight.w600, T.textMuted, height: 1)),
        ]),
      );

  // ── 사전 펀딩 세팅 ──
  Widget _fundingCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: T.surfaceSunken, borderRadius: BorderRadius.circular(T.rXl)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(LucideIcons.clock, size: 18, color: T.primary),
            const SizedBox(width: 8),
            Text('사전 펀딩 세팅', style: tx(14, FontWeight.w700, T.textTitle, height: 1)),
          ]),
          const SizedBox(height: 14),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: _suffixField('최소 인원', _minCtrl, '명')),
            const SizedBox(width: 12),
            Expanded(child: _suffixField('목표(최대) 인원', _headCtrl, '명')),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: T.gray50, borderRadius: BorderRadius.circular(T.rMd)),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic, children: [
              Text('1인당 펀딩', style: tx(13, FontWeight.w600, T.textMuted, height: 1)),
              const SizedBox(width: 8),
              Text('${won(_perHead)}원', style: tx(22, FontWeight.w700, T.primary, ls: -0.02, height: 1, tab: true)),
            ]),
          ),
          const SizedBox(height: 12),
          Text('펀딩 데드라인', style: tx(13, FontWeight.w600, T.textTitle, height: 1)),
          const SizedBox(height: 6),
          _pickerTrigger(
            open: _dlOpen,
            label: _fmtDT(_dlDate, _dlTime),
            onTap: () => setState(() => _dlOpen = !_dlOpen),
          ),
          if (_dlOpen)
            _pickerPanel(
              date: _dlDate,
              time: _dlTime,
              onDate: (d) => setState(() => _dlDate = d),
              onTime: (t) => setState(() => _dlTime = t),
              onConfirm: () => setState(() => _dlOpen = false),
              quickChips: [
                _quickChip('오늘 18시', 0, '18:00'),
                _quickChip('내일 18시', 1, '18:00'),
                _quickChip('3일 후', 3, '18:00'),
                _quickChip('일주일 후', 7, '18:00'),
              ],
            ),
        ]),
      );

  Widget _quickChip(String label, int addDays, String time) => GestureDetector(
        onTap: () {
          final d = DateTime.now().add(Duration(days: addDays));
          setState(() {
            _dlDate = DateTime(d.year, d.month, d.day);
            _dlTime = time;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: T.white,
            borderRadius: BorderRadius.circular(T.rPill),
            border: Border.all(color: T.borderDefault, width: 1.5),
          ),
          child: Text(label, style: tx(12, FontWeight.w600, T.textMuted, height: 1)),
        ),
      );

  // ── 공용 필드 헬퍼 ──
  Widget _labeledField(String label, TextEditingController c, {String? hint, double? height}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: tx(13, FontWeight.w600, T.textTitle, height: 1)),
        const SizedBox(height: 8),
        _field(controller: c, hint: hint, height: height),
      ]);

  Widget _suffixField(String label, TextEditingController c, String suffix) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: tx(12, FontWeight.w600, T.textMuted, height: 1)),
        const SizedBox(height: 8),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: T.white,
            borderRadius: BorderRadius.circular(T.rMd),
            border: Border.all(color: T.borderDefault, width: 1.5),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: c,
                keyboardType: TextInputType.number,
                cursorColor: T.primary,
                style: tx(14, FontWeight.w500, T.textStrong, height: 1, tab: true),
                decoration: const InputDecoration(isCollapsed: true, border: InputBorder.none),
              ),
            ),
            const SizedBox(width: 6),
            Text(suffix, style: tx(13, FontWeight.w600, T.textMuted, height: 1)),
          ]),
        ),
      ]);

  Widget _field({
    required TextEditingController controller,
    double? height,
    int maxLines = 1,
    String? hint,
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
        cursorColor: T.primary,
        style: tx(14, FontWeight.w500, maxLines > 1 ? T.textBody : T.textStrong, height: maxLines > 1 ? 1.5 : 1),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: tx(14, FontWeight.w500, T.textDisabled, height: maxLines > 1 ? 1.5 : 1),
        ),
      ),
    );
  }
}
