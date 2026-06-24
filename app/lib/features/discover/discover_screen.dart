// 탐색 탭 — prototype DiscoverScreen (850b0de8). 위치·검색·카테고리·거리/상태·피드·FAB.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/toast.dart';
import '../common/meeting_card.dart';

class _Cat {
  final String id, label;
  final Color color, colorSoft;
  final List<String> cats;
  final IconData icon;
  const _Cat(this.id, this.label, this.color, this.colorSoft, this.cats, this.icon);
}

const _categories = [
  _Cat('문화·예술', '문화·예술', Color(0xFF7C3AED), Color(0xFFF5F3FF), ['문화/밴드'], LucideIcons.music),
  _Cat('운동·스포츠', '운동·스포츠', Color(0xFFD97706), Color(0xFFFFFBEB), ['스포츠'], LucideIcons.dumbbell),
  _Cat('학술·자기계발', '학술·자기계발', Color(0xFF2563EB), Color(0xFFEFF6FF), ['학술'], LucideIcons.graduationCap),
  _Cat('취미·라이프', '취미·라이프', Color(0xFF059669), Color(0xFFF0FDF4), ['사교/취미'], LucideIcons.palette),
  _Cat('봉사·기타', '봉사·기타', Color(0xFFDB2777), Color(0xFFFDF2F8), ['봉사'], LucideIcons.heartHandshake),
];

const _meetups = <MeetingItem>[
  MeetingItem(title: '주말 정기 대관 연습', author: '김회장', tone: 'blue', source: 'club', time: '1시간 전', club: "홍대 연합 밴드 '사운드'", clubTone: 'blue', date: '6월 20일 (토) 19:00', dday: 'D-8', tag: '밴드', dist: 1.2, cat: '문화/밴드', status: 'recruiting', rounds: [Round('1차', '영통 사운드스튜디오 3호점', 6, 12, 27000), Round('2차', '근처 이자카야', 3, 8, 15000)]),
  MeetingItem(title: '영통역 5:5 풋살 매치 용병 구함', author: '이영희', tone: 'mint', source: 'follow', time: '30분 전', date: '6월 14일 (토) 15:00', dday: 'D-2', tag: '스포츠', dist: 0.8, cat: '스포츠', status: 'recruiting', rounds: [Round('1차', '플랩풋볼 영통점 (야외 A구장)', 8, 10, 12000)]),
  MeetingItem(title: '파이썬 스터디 번개', author: '장열심', tone: 'blue', source: 'club', time: '2시간 전', club: 'SW 자기계발 스터디', clubTone: 'purple', date: '6월 18일 (수) 19:30', dday: 'D-6', tag: '학술', dist: 1.8, cat: '학술', status: 'recruiting', rounds: [Round('1차', '영통 코워킹스페이스', 3, 8, 10000)]),
  MeetingItem(title: '와인 & 치즈 홈파티', author: '박지훈', tone: 'purple', source: 'follow', time: '5시간 전', date: '6월 13일 (금) 20:00', dday: 'D-1', tag: '사교', dist: 0.4, cat: '사교/취미', status: 'recruiting', rounds: [Round('1차', '영통 공유 라운지', 9, 10, 25000)]),
  MeetingItem(title: '강남역 풋살 매치', author: '최부원', tone: 'mint', source: 'club', time: '어제', club: "토요 풋살회 '풋살러'", clubTone: 'mint', date: '6월 21일 (토) 14:00', dday: 'D-9', tag: '스포츠', dist: 3.1, cat: '스포츠', status: 'full', rounds: [Round('1차', '플랩풋볼 영통점', 14, 14, 12000)]),
  MeetingItem(title: '유기견 봉사 산책 모임', author: '김수진', tone: 'mint', source: 'follow', time: '3시간 전', date: '6월 22일 (일) 10:00', dday: 'D-10', tag: '봉사', dist: 4.2, cat: '봉사', status: 'recruiting', rounds: [Round('1차', '광교 동물보호센터', 5, 12, 0)]),
];

const _regionTree = {
  '서울': ['강남구', '서초구', '송파구', '마포구', '용산구', '성동구', '광진구', '영등포구'],
  '경기': ['수원시 영통구', '수원시 장안구', '수원시 권선구', '수원시 팔달구', '용인시 수지구', '용인시 기흥구', '성남시 분당구', '고양시 일산동구', '부천시'],
  '인천': ['연수구', '남동구', '부평구', '계양구', '서구'],
  '부산': ['해운대구', '수영구', '부산진구', '동래구', '금정구'],
  '대전': ['서구', '유성구', '중구', '동구', '대덕구'],
  '대구': ['수성구', '중구', '달서구', '북구', '동구'],
  '광주': ['동구', '서구', '남구', '북구', '광산구'],
};

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String? _selCat;
  String _selDistance = '5km';
  String _selStatus = '전체';
  bool _fabOpen = false;
  bool _loading = true;
  bool _searchFocused = false;
  String _query = '';
  String _locMode = 'gps'; // gps | manual
  String _region = '수원시 영통구';
  final _searchCtrl = TextEditingController();

  static const _distances = ['1km', '3km', '5km'];
  static const _statusTabs = ['전체', '모집 중', '모집 완료', '종료'];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool get _filtersActive => _selCat != null || _selStatus != '전체' || _selDistance != '5km';

  List<MeetingItem> get _filtered {
    final selCatObj = _categories.where((c) => c.id == _selCat).firstOrNull;
    final q = _query.trim().toLowerCase();
    final maxDist = double.parse(_selDistance.replaceAll('km', ''));
    return _meetups.where((m) {
      final matchCat = _selCat == null || (selCatObj?.cats ?? []).contains(m.cat);
      final matchStatus = _selStatus == '전체' ||
          (_selStatus == '모집 중' && m.status == 'recruiting') ||
          (_selStatus == '모집 완료' && m.status == 'full') ||
          (_selStatus == '종료' && m.status == 'ended');
      final matchSearch = q.isEmpty ||
          m.title.toLowerCase().contains(q) ||
          (m.club ?? '').toLowerCase().contains(q) ||
          m.author.toLowerCase().contains(q) ||
          m.rounds.any((r) => r.place.toLowerCase().contains(q));
      return matchCat && matchStatus && matchSearch && m.dist <= maxDist;
    }).toList();
  }

  void _resetFilters() => setState(() {
        _selCat = null;
        _selStatus = '전체';
        _selDistance = '5km';
      });

  void _stub() => MoishoToast.show(context, '준비 중인 화면이에요', tone: 'info');

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (_fabOpen) setState(() => _fabOpen = false);
      },
      child: Stack(
        children: [
          Column(
            children: [
              const MoishoStatusBar(),
              _locationBar(),
              _searchBar(),
              _categoryBar(),
              _distanceStatusBar(),
              Expanded(child: _feed(filtered)),
            ],
          ),
          if (_fabOpen)
            Positioned.fill(child: GestureDetector(onTap: () => setState(() => _fabOpen = false), child: Container(color: Colors.black.withValues(alpha: 0.15)))),
          if (_fabOpen) _fabMenu(),
          _fab(),
        ],
      ),
    );
  }

  Widget _locationBar() => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _openLocationSheet,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(color: T.white, border: Border(bottom: BorderSide(color: T.borderSubtle))),
          child: Row(children: [
            const Icon(LucideIcons.mapPin, size: 15, color: T.primary),
            const SizedBox(width: 8),
            Expanded(child: Text('${_locMode == "gps" ? "수원시 영통구" : _region} 주변 모임', style: tx(14, FontWeight.w700, T.textStrong, height: 1))),
            if (_locMode == 'gps')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: T.successSoft, borderRadius: BorderRadius.circular(999)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 5, height: 5, decoration: const BoxDecoration(color: T.success, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('GPS', style: tx(10, FontWeight.w700, T.success, height: 1)),
                ]),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(999)),
                child: Text('지역 선택', style: tx(10, FontWeight.w700, T.primary, height: 1)),
              ),
            const SizedBox(width: 6),
            const Icon(LucideIcons.chevronDown, size: 16, color: T.textMuted),
          ]),
        ),
      );

  Widget _searchBar() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(color: T.white, border: Border(bottom: BorderSide(color: T.borderSubtle))),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: _searchFocused ? T.white : T.gray50,
              borderRadius: BorderRadius.circular(T.rXl),
              border: Border.all(color: _searchFocused ? T.primary : T.borderSubtle, width: 1.5),
            ),
            child: Row(children: [
              Icon(LucideIcons.search, size: 15, color: _searchFocused ? T.primary : T.textDisabled),
              const SizedBox(width: 8),
              Expanded(
                child: Focus(
                  onFocusChange: (f) => setState(() => _searchFocused = f),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    style: tx(13, FontWeight.w500, T.textBody, height: 1.2),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: '동아리명, 주최자, 모임 이름으로 검색',
                      hintStyle: tx(13, FontWeight.w500, T.textMuted, height: 1.2),
                    ),
                  ),
                ),
              ),
              if (_query.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() {
                    _query = '';
                    _searchCtrl.clear();
                  }),
                  child: const Icon(LucideIcons.x, size: 14, color: T.textMuted),
                ),
            ]),
          ),
          if (_searchFocused && _query.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final kw in ['풋살', '밴드', '사진', '독서', '봉사'])
                    GestureDetector(
                      onTap: () => setState(() {
                        _query = kw;
                        _searchCtrl.text = kw;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(999)),
                        child: Text('# $kw', style: tx(11, FontWeight.w600, T.primary, height: 1)),
                      ),
                    ),
                ]),
              ),
            ),
        ]),
      );

  Widget _categoryBar() => Container(
        decoration: const BoxDecoration(color: T.white, border: Border(bottom: BorderSide(color: T.borderSubtle))),
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            for (final cat in _categories) ...[
              _categoryChip(cat),
              const SizedBox(width: 7),
            ],
          ]),
        ),
      );

  Widget _categoryChip(_Cat cat) {
    final on = _selCat == cat.id;
    return GestureDetector(
      onTap: () => setState(() => _selCat = on ? null : cat.id),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
        decoration: BoxDecoration(
          color: on ? cat.colorSoft : T.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: on ? cat.color : T.borderSubtle, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(color: on ? cat.color : cat.colorSoft, borderRadius: BorderRadius.circular(7)),
            child: Icon(cat.icon, size: 13, color: on ? T.white : cat.color),
          ),
          const SizedBox(width: 6),
          Text(cat.label, style: tx(12, on ? FontWeight.w700 : FontWeight.w600, on ? cat.color : T.textBody, height: 1)),
        ]),
      ),
    );
  }

  Widget _distanceStatusBar() => Container(
        decoration: const BoxDecoration(color: T.white, border: Border(bottom: BorderSide(color: T.borderSubtle))),
        height: 40,
        child: Row(children: [
          // 거리 드롭다운
          Container(
            padding: const EdgeInsets.only(left: 16, right: 12),
            decoration: const BoxDecoration(border: Border(right: BorderSide(color: T.borderSubtle))),
            child: MenuAnchor(
              style: MenuStyle(
                backgroundColor: const WidgetStatePropertyAll(T.white),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(T.rLg), side: const BorderSide(color: T.borderDefault))),
              ),
              menuChildren: [
                for (final d in _distances)
                  MenuItemButton(
                    onPressed: () => setState(() => _selDistance = d),
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(d == _selDistance ? T.primarySoft : Colors.transparent)),
                    child: SizedBox(width: 60, child: Text(d, style: tx(13, FontWeight.w500, d == _selDistance ? T.primary : T.textBody, height: 1))),
                  ),
              ],
              builder: (context, controller, _) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.isOpen ? controller.close() : controller.open(),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(LucideIcons.navigation, size: 12, color: T.primary),
                  const SizedBox(width: 4),
                  Text(_selDistance, style: tx(12, FontWeight.w600, T.textBody, height: 1)),
                  const SizedBox(width: 4),
                  const Icon(LucideIcons.chevronDown, size: 12, color: T.textMuted),
                ]),
              ),
            ),
          ),
          // 상태 탭
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (final s in _statusTabs) _statusTab(s),
              ]),
            ),
          ),
        ]),
      );

  Widget _statusTab(String s) {
    final on = _selStatus == s;
    return GestureDetector(
      onTap: () => setState(() => _selStatus = s),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: on ? T.primary : Colors.transparent, width: 2))),
        alignment: Alignment.center,
        child: Text(s, style: tx(12, on ? FontWeight.w700 : FontWeight.w500, on ? T.primary : T.textMuted, height: 1)),
      ),
    );
  }

  Widget _feed(List<MeetingItem> filtered) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(T.padScreen, 14, T.padScreen, 88),
      physics: const BouncingScrollPhysics(),
      children: [
        // 상태 라인
        Row(children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: _loading ? T.gray300 : const Color(0xFF22C55E), shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Expanded(child: Text(_loading ? '주변 모임을 불러오는 중…' : '내 주변 ${filtered.length}개 모임이 활동 중이에요', style: tx(12, FontWeight.w500, T.textMuted, height: 1))),
          if (!_loading && _filtersActive)
            GestureDetector(
              onTap: _resetFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: T.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: T.borderDefault)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(LucideIcons.x, size: 12, color: T.textMuted),
                  const SizedBox(width: 4),
                  Text('필터 초기화', style: tx(11, FontWeight.w600, T.textMuted, height: 1)),
                ]),
              ),
            ),
        ]),
        const SizedBox(height: 14),
        if (_loading)
          ...List.generate(3, (_) => const _SkeletonCard())
        else if (filtered.isEmpty)
          _emptyState()
        else
          ...filtered.map((m) {
            final distLabel = m.dist < 1 ? '${(m.dist * 1000).round()}m' : '${m.dist}km';
            return MeetingCard(item: m, distLabel: distLabel, onTap: _stub);
          }),
      ],
    );
  }

  Widget _emptyState() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 44),
        child: Column(children: [
          Container(
            width: 64, height: 64,
            decoration: const BoxDecoration(color: T.gray50, shape: BoxShape.circle),
            child: const Icon(LucideIcons.search, size: 28, color: T.textDisabled),
          ),
          const SizedBox(height: 14),
          Text('조건에 맞는 모임이 없어요', style: tx(15, FontWeight.w700, T.textMuted, height: 1.3)),
          const SizedBox(height: 6),
          Text('검색어나 거리·카테고리 필터를 바꿔보세요', textAlign: TextAlign.center, style: tx(12, FontWeight.w500, T.textDisabled, height: 1.5)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _stub,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(999), border: Border.all(color: T.primary, width: 1.5)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(LucideIcons.plus, size: 15, color: T.primary),
                const SizedBox(width: 6),
                Text('직접 모임 만들기', style: tx(13, FontWeight.w700, T.primary, height: 1)),
              ]),
            ),
          ),
        ]),
      );

  Widget _fab() => Positioned(
        right: 16,
        bottom: 16,
        child: GestureDetector(
          onTap: () => setState(() => _fabOpen = !_fabOpen),
          child: AnimatedRotation(
            turns: _fabOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: _fabOpen ? null : const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [T.blue600, T.purple500]),
                color: _fabOpen ? const Color(0xFF6B7280) : null,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: const Icon(LucideIcons.plus, size: 22, color: T.white),
            ),
          ),
        ),
      );

  Widget _fabMenu() => Positioned(
        right: 16,
        bottom: 76,
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (final opt in [('동아리 모임 생성', T.primary, LucideIcons.users), ('개인 번개 생성', const Color(0xFF6B7280), LucideIcons.zap)])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () {
                  setState(() => _fabOpen = false);
                  _stub();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: opt.$2, borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 2))]),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(opt.$3, size: 16, color: T.white),
                    const SizedBox(width: 8),
                    Text(opt.$1, style: tx(12, FontWeight.w700, T.white, height: 1)),
                  ]),
                ),
              ),
            ),
        ]),
      );

  // ── 위치 선택 시트 (시/도 → 시/군/구) ──
  void _openLocationSheet() {
    String step = 'sido';
    String pickSido = '경기';
    showModalBottomSheet(
      context: context,
      backgroundColor: T.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheet) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheetCtx).height * 0.66),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 8),
              Container(width: 36, height: 4, decoration: BoxDecoration(color: T.borderDefault, borderRadius: BorderRadius.circular(999))),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(children: [
                  if (step == 'sigungu')
                    GestureDetector(
                      onTap: () => setSheet(() => step = 'sido'),
                      child: const Padding(padding: EdgeInsets.only(right: 8), child: Icon(LucideIcons.chevronLeft, size: 20, color: T.textStrong)),
                    ),
                  Text(step == 'sigungu' ? pickSido : '지역 설정', style: tx(16, FontWeight.w700, T.textStrong, height: 1)),
                  const Spacer(),
                  GestureDetector(onTap: () => Navigator.pop(sheetCtx), child: const Icon(LucideIcons.x, size: 20, color: T.textMuted)),
                ]),
              ),
              if (step == 'sido') ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _locMode = 'gps');
                      Navigator.pop(sheetCtx);
                      MoishoToast.show(context, '내 주변 모임을 업데이트했어요!', tone: 'success');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: _locMode == 'gps' ? T.primarySoft : T.white,
                        borderRadius: BorderRadius.circular(T.rMd),
                        border: Border.all(color: _locMode == 'gps' ? T.primary : T.borderSubtle, width: 1.5),
                      ),
                      child: Row(children: [
                        Container(width: 34, height: 34, decoration: const BoxDecoration(color: T.successSoft, shape: BoxShape.circle), child: const Icon(LucideIcons.navigation, size: 16, color: T.success)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('현재 위치로 설정', style: tx(14, FontWeight.w700, T.textTitle, height: 1.2)),
                            const SizedBox(height: 3),
                            Text('GPS로 내 주변 모임을 찾아요', style: tx(12, FontWeight.w500, T.textMuted, height: 1)),
                          ]),
                        ),
                        if (_locMode == 'gps') const Icon(LucideIcons.check, size: 18, color: T.primary),
                      ]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                  child: Row(children: [
                    const Expanded(child: Divider(color: T.borderSubtle, height: 1)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('또는 지역 직접 선택', style: tx(11, FontWeight.w600, T.textDisabled, height: 1))),
                    const Expanded(child: Divider(color: T.borderSubtle, height: 1)),
                  ]),
                ),
              ],
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  children: step == 'sido'
                      ? [
                          for (final s in _regionTree.keys)
                            GestureDetector(
                              onTap: () => setSheet(() {
                                pickSido = s;
                                step = 'sigungu';
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: T.borderSubtle))),
                                child: Row(children: [
                                  Expanded(child: Text(s, style: tx(14, FontWeight.w500, T.textBody, height: 1))),
                                  Text('${_regionTree[s]!.length}', style: tx(12, FontWeight.w500, T.textDisabled, height: 1)),
                                  const SizedBox(width: 8),
                                  const Icon(LucideIcons.chevronRight, size: 16, color: T.textDisabled),
                                ]),
                              ),
                            ),
                        ]
                      : [
                          for (final gu in _regionTree[pickSido]!)
                            Builder(builder: (_) {
                              final full = pickSido == '서울' ? '서울 $gu' : gu;
                              final on = _locMode == 'manual' && _region == full;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _locMode = 'manual';
                                    _region = full;
                                  });
                                  Navigator.pop(sheetCtx);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
                                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: T.borderSubtle))),
                                  child: Row(children: [
                                    Icon(LucideIcons.mapPin, size: 15, color: on ? T.primary : T.textDisabled),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(gu, style: tx(14, on ? FontWeight.w700 : FontWeight.w500, on ? T.primary : T.textBody, height: 1))),
                                    if (on) const Icon(LucideIcons.check, size: 17, color: T.primary),
                                  ]),
                                ),
                              );
                            }),
                        ],
                ),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── 로딩 스켈레톤 ──
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();
  @override
  Widget build(BuildContext context) {
    Widget block(double w, double h, [double r = 7]) => Container(width: w, height: h, decoration: BoxDecoration(color: const Color(0xFFE9ECF1), borderRadius: BorderRadius.circular(r)));
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: T.white, borderRadius: BorderRadius.circular(T.rXl), border: Border.all(color: T.borderSubtle, width: 1.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          block(34, 34, 17),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [block(160, 13), const SizedBox(height: 7), block(90, 10)])),
          block(38, 22, T.rMd),
        ]),
        const SizedBox(height: 14),
        block(140, 11),
        const SizedBox(height: 12),
        block(double.infinity, 40, T.rMd),
      ]),
    );
  }
}
