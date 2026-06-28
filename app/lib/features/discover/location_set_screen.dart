// 지역 설정 · 카테고리 탐색(전국 카스케이딩) — prototype LocationSetScreen (c314d025:17).
// 현재 동네 칩 · 통합 검색 · [좌] 시/도 레일 + [우] 시/군/구 그리드 · 인기 약속 장소 · 하단 확정.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';

// ── 대한민국 행정구역(시/도 → 시/군/구) — prototype KR_REGIONS 리터럴 ──
class _Region {
  final String sido, abbr;
  final List<String> sigungu;
  const _Region(this.sido, this.abbr, this.sigungu);
}

class _Flat {
  final String sido, abbr, gu, full;
  const _Flat(this.sido, this.abbr, this.gu, this.full);
}

const List<_Region> _kRegions = [
  _Region('서울특별시', '서울', [
    '종로구', '중구', '용산구', '성동구', '광진구', '동대문구', '중랑구',
    '성북구', '강북구', '도봉구', '노원구', '은평구', '서대문구', '마포구',
    '양천구', '강서구', '구로구', '금천구', '영등포구', '동작구', '관악구',
    '서초구', '강남구', '송파구', '강동구',
  ]),
  _Region('부산광역시', '부산', [
    '중구', '서구', '동구', '영도구', '부산진구', '동래구', '남구', '북구',
    '해운대구', '사하구', '금정구', '강서구', '연제구', '수영구', '사상구',
    '기장군',
  ]),
  _Region('대구광역시', '대구', [
    '중구', '동구', '서구', '남구', '북구', '수성구', '달서구', '달성군',
    '군위군',
  ]),
  _Region('인천광역시', '인천', [
    '중구', '동구', '미추홀구', '연수구', '남동구', '부평구', '계양구',
    '서구', '강화군', '옹진군',
  ]),
  _Region('광주광역시', '광주', ['동구', '서구', '남구', '북구', '광산구']),
  _Region('대전광역시', '대전', ['동구', '중구', '서구', '유성구', '대덕구']),
  _Region('울산광역시', '울산', ['중구', '남구', '동구', '북구', '울주군']),
  _Region('세종특별자치시', '세종', ['세종특별자치시']),
  _Region('경기도', '경기', [
    '수원시 장안구', '수원시 권선구', '수원시 팔달구', '수원시 영통구',
    '성남시 수정구', '성남시 중원구', '성남시 분당구',
    '의정부시',
    '안양시 만안구', '안양시 동안구',
    '부천시',
    '광명시', '평택시', '동두천시',
    '안산시 상록구', '안산시 단원구',
    '고양시 덕양구', '고양시 일산동구', '고양시 일산서구',
    '과천시', '구리시', '남양주시', '오산시', '시흥시', '군포시', '의왕시',
    '하남시',
    '용인시 처인구', '용인시 기흥구', '용인시 수지구',
    '파주시', '이천시', '안성시', '김포시', '화성시', '광주시', '양주시',
    '포천시', '여주시',
    '연천군', '가평군', '양평군',
  ]),
  _Region('강원특별자치도', '강원', [
    '춘천시', '원주시', '강릉시', '동해시', '태백시', '속초시', '삼척시',
    '홍천군', '횡성군', '영월군', '평창군', '정선군', '철원군', '화천군',
    '양구군', '인제군', '고성군', '양양군',
  ]),
  _Region('충청북도', '충북', [
    '청주시 상당구', '청주시 서원구', '청주시 흥덕구', '청주시 청원구',
    '충주시', '제천시',
    '보은군', '옥천군', '영동군', '증평군', '진천군', '괴산군', '음성군',
    '단양군',
  ]),
  _Region('충청남도', '충남', [
    '천안시 동남구', '천안시 서북구',
    '공주시', '보령시', '아산시', '서산시', '논산시', '계룡시', '당진시',
    '금산군', '부여군', '서천군', '청양군', '홍성군', '예산군', '태안군',
  ]),
  _Region('전북특별자치도', '전북', [
    '전주시 완산구', '전주시 덕진구',
    '군산시', '익산시', '정읍시', '남원시', '김제시',
    '완주군', '진안군', '무주군', '장수군', '임실군', '순창군', '고창군',
    '부안군',
  ]),
  _Region('전라남도', '전남', [
    '목포시', '여수시', '순천시', '나주시', '광양시',
    '담양군', '곡성군', '구례군', '고흥군', '보성군', '화순군', '장흥군',
    '강진군', '해남군', '영암군', '무안군', '함평군', '영광군', '장성군',
    '완도군', '진도군', '신안군',
  ]),
  _Region('경상북도', '경북', [
    '포항시 남구', '포항시 북구',
    '경주시', '김천시', '안동시', '구미시', '영주시', '영천시', '상주시',
    '문경시', '경산시',
    '의성군', '청송군', '영양군', '영덕군', '청도군', '고령군', '성주군',
    '칠곡군', '예천군', '봉화군', '울진군', '울릉군',
  ]),
  _Region('경상남도', '경남', [
    '창원시 의창구', '창원시 성산구', '창원시 마산합포구', '창원시 마산회원구',
    '창원시 진해구',
    '진주시', '통영시', '사천시', '김해시', '밀양시', '거제시', '양산시',
    '의령군', '함안군', '창녕군', '고성군', '남해군', '하동군', '산청군',
    '함양군', '거창군', '합천군',
  ]),
  _Region('제주특별자치도', '제주', ['제주시', '서귀포시']),
];

// ── 핫플레이스 / 상권 카테고리 — prototype KR_HOTPLACES 리터럴 ──
const Map<String, List<String>> _kHotplaces = {
  '서울|마포구': ['홍대입구', '연남동', '합정', '망원동', '상수'],
  '서울|성동구': ['성수동', '서울숲', '왕십리', '뚝섬'],
  '서울|강남구': ['강남역', '압구정로데오', '신사 가로수길', '삼성역', '청담'],
  '서울|용산구': ['이태원', '한남동', '용리단길', '해방촌'],
  '서울|종로구': ['익선동', '광장시장', '삼청동', '대학로'],
  '서울|영등포구': ['여의도', '영등포 타임스퀘어', '문래동'],
  '서울|송파구': ['잠실 롯데월드', '석촌호수', '방이동 먹자골목'],
  '서울|광진구': ['건대입구', '성수 연계', '구의역'],
  '경기|수원시 팔달구': ['행궁동', '수원역', '인계동'],
  '경기|수원시 영통구': ['영통역', '광교호수공원', '아주대'],
  '경기|성남시 분당구': ['분당 정자동', '서현역', '판교역', '미금역'],
  '경기|안양시 동안구': ['범계역', '평촌 학원가', '인덕원'],
  '경기|안양시 만안구': ['안양일번가', '안양역'],
  '경기|과천시': ['과천정부청사', '과천 서울대공원', '인덕원 연계'],
  '경기|고양시 일산동구': ['라페스타', '웨스턴돔', '정발산역'],
  '경기|용인시 수지구': ['수지구청역', '죽전 카페거리', '동천역'],
  '경기|화성시': ['동탄역', '동탄호수공원', '병점'],
  '인천|연수구': ['송도 센트럴파크', '송도 트리플스트리트'],
  '인천|미추홀구': ['인천 구월동', '주안역'],
  '인천|중구': ['인천 차이나타운', '월미도', '개항장'],
  '부산|해운대구': ['해운대 해수욕장', '구남로', '센텀시티'],
  '부산|수영구': ['광안리', '민락수변공원', '망미단길'],
  '부산|부산진구': ['서면', '전포 카페거리'],
  '대구|중구': ['동성로', '김광석거리', '서문시장'],
  '대전|유성구': ['봉명동', '유성온천역', '충남대'],
  '대전|서구': ['둔산동', '대전시청', '갤러리아 타임월드'],
  '광주|동구': ['충장로', '동명동 카페거리', '예술의거리'],
  '울산|남구': ['삼산동', '달동 먹자골목'],
  '강원|강릉시': ['강릉 안목해변', '강문해변', '경포대'],
  '강원|춘천시': ['춘천 명동', '남이섬', '공지천'],
  '강원|속초시': ['속초관광수산시장', '영금정', '아바이마을'],
  '충북|청주시 흥덕구': ['청주 성안길', '복대동 지웰시티'],
  '충남|천안시 서북구': ['천안 불당동', '천안아산역'],
  '전북|전주시 완산구': ['전주한옥마을', '객리단길', '남부시장'],
  '전남|여수시': ['여수 낭만포차거리', '여수 돌산공원', '이순신광장'],
  '경북|경주시': ['황리단길', '보문관광단지', '동궁과 월지'],
  '경남|창원시 성산구': ['상남동', '창원 용호동 가로수길'],
  '제주|제주시': ['제주공항 근처', '제주 노형동', '탑동', '함덕'],
  '제주|서귀포시': ['제주 애월', '중문관광단지', '성산일출봉', '서귀포 매일올레시장'],
};

const List<String> _kHotDefault = ['행궁동', '홍대입구', '성수동', '분당 정자동', '범계역', '제주 애월'];

// 전국 시군구 평탄화 — 통합 검색용.
final List<_Flat> _kFlat = [
  for (final r in _kRegions)
    for (final gu in r.sigungu) _Flat(r.sido, r.abbr, gu, '${r.abbr} $gu'),
];

class LocationSetScreen extends StatefulWidget {
  const LocationSetScreen({super.key});

  @override
  State<LocationSetScreen> createState() => _LocationSetScreenState();
}

class _LocationSetScreenState extends State<LocationSetScreen> {
  int _sidoIdx = 8; // 기본: 경기도
  String _sigungu = '수원시 팔달구';
  String _home = '수원시 팔달구';
  String? _hotSel;
  bool _focused = false;

  final TextEditingController _queryCtrl = TextEditingController();
  final FocusNode _queryFocus = FocusNode();

  // 네이비 — 레일 강조. (토큰 없음 → 근접치 + 주석)
  static const Color _navy = T.gray800; // proto #1B2A4A

  @override
  void initState() {
    super.initState();
    _queryFocus.addListener(() => setState(() => _focused = _queryFocus.hasFocus));
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    _queryFocus.dispose();
    super.dispose();
  }

  String get _query => _queryCtrl.text;
  _Region get _sido => _sidoIdx < _kRegions.length ? _kRegions[_sidoIdx] : _kRegions[0];

  // 통합 검색 결과
  List<_Flat> get _results {
    final q = _query.trim();
    if (q.isEmpty) return const [];
    return _kFlat
        .where((r) => r.gu.contains(q) || r.abbr.contains(q) || r.sido.contains(q))
        .take(24)
        .toList();
  }

  // 선택 지역의 핫플레이스
  List<String> get _hotplaces {
    final key = '${_sido.abbr}|$_sigungu';
    return _kHotplaces[key] ?? _kHotDefault;
  }

  void _pickSigungu(String gu) => setState(() {
        _sigungu = gu;
        _home = gu;
        _hotSel = null;
      });

  void _pickSearch(_Flat r) {
    final idx = _kRegions.indexWhere((x) => x.abbr == r.abbr);
    setState(() {
      if (idx >= 0) _sidoIdx = idx;
      _sigungu = r.gu;
      _home = r.gu;
      _hotSel = null;
      _queryCtrl.clear();
    });
    MoishoToast.show(context, '${r.sido} ${r.gu}(으)로 설정했어요.', tone: 'success');
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      backgroundColor: T.surfaceSunken,
      body: Column(children: [
        const MoishoStatusBar(),
        _headerBlock(),
        _searchBlock(results.isNotEmpty),
        if (results.isNotEmpty)
          Expanded(child: _resultsList(results))
        else ...[
          Expanded(child: _masterDetail()),
          _hotplacesBlock(),
        ],
        _stickyBar(),
      ]),
    );
  }

  // ── 헤더 + 현재 동네 칩 ──
  Widget _headerBlock() => DecoratedBox(
        decoration: const BoxDecoration(
          color: T.white,
          border: Border(bottom: BorderSide(color: T.borderSubtle)),
        ),
        child: Column(children: [
          MoishoAppHeader(
            title: '지역 설정',
            onBack: () => Navigator.of(context).maybePop(),
            transparent: true,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
            child: Row(children: [
              Text('현재 동네', style: tx(12.5, FontWeight.w500, T.textMuted, height: 1)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: T.primarySoft,
                  borderRadius: BorderRadius.circular(T.rPill),
                  border: Border.all(color: T.blue100), // proto #DCE6FF
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(LucideIcons.mapPin, size: 13, color: T.primary),
                  const SizedBox(width: 5),
                  Text(_home, style: tx(13, FontWeight.w700, T.primary, ls: -0.01, height: 1)),
                ]),
              ),
            ]),
          ),
        ]),
      );

  // ── 통합 검색 바 (카카오 주소 스타일) ──
  Widget _searchBlock(bool hasResults) {
    final active = _focused || _query.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: T.white,
        border: Border(bottom: BorderSide(color: hasResults ? Colors.transparent : T.borderSubtle)),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: T.surfaceSunken,
          borderRadius: BorderRadius.circular(T.rPill),
          border: Border.all(color: _focused ? T.primary : Colors.transparent, width: 1.5),
          boxShadow: _focused
              ? const [BoxShadow(color: T.primarySoft, blurRadius: 0, spreadRadius: 4)]
              : const [],
        ),
        child: Row(children: [
          Icon(LucideIcons.search, size: 18, color: active ? T.primary : T.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _queryCtrl,
              focusNode: _queryFocus,
              onChanged: (_) => setState(() {}),
              cursorColor: T.primary,
              style: tx(14, FontWeight.w500, T.textStrong, height: 1.2),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: '시·군·구, 동명 또는 도로명으로 검색',
                hintStyle: tx(14, FontWeight.w500, T.textMuted, height: 1.2),
              ),
            ),
          ),
          if (_query.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _queryCtrl.clear()),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(LucideIcons.x, size: 16, color: T.textMuted),
              ),
            ),
        ]),
      ),
    );
  }

  // ── 검색 결과 (있으면 그리드/리스트 대체) ──
  Widget _resultsList(List<_Flat> results) => ListView(
        padding: const EdgeInsets.fromLTRB(T.padScreen, 8, T.padScreen, 24),
        physics: const BouncingScrollPhysics(),
        children: [
          SectionLabel('검색 결과 ${results.length}'),
          Container(
            decoration: BoxDecoration(
              color: T.white,
              borderRadius: BorderRadius.circular(T.rLg),
              border: Border.all(color: T.borderSubtle),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(T.rLg),
              child: Column(children: [
                for (var i = 0; i < results.length; i++) _resultRow(results[i], i),
              ]),
            ),
          ),
        ],
      );

  Widget _resultRow(_Flat r, int i) => GestureDetector(
        onTap: () => _pickSearch(r),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            border: i == 0 ? null : const Border(top: BorderSide(color: T.borderSubtle)),
          ),
          child: Row(children: [
            const Icon(LucideIcons.mapPin, size: 15, color: T.textDisabled),
            const SizedBox(width: 11),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.gu, style: tx(14, FontWeight.w600, T.textTitle, height: 1.3)),
                const SizedBox(height: 2),
                Text(r.sido, style: tx(11.5, FontWeight.w500, T.textDisabled, height: 1)),
              ]),
            ),
            const Icon(LucideIcons.cornerDownLeft, size: 14, color: T.textDisabled),
          ]),
        ),
      );

  // ── 마스터-디테일: [좌] 시/도 레일 · [우] 시/군/구 그리드 ──
  Widget _masterDetail() => DecoratedBox(
        decoration: const BoxDecoration(color: T.white),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 좌측 — 17개 시/도 세로 내비
          Container(
            width: 96,
            decoration: const BoxDecoration(
              color: T.surfaceSunken,
              border: Border(right: BorderSide(color: T.borderSubtle)),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                for (var i = 0; i < _kRegions.length; i++) _railItem(i),
              ],
            ),
          ),
          // 우측 — 선택 시/도의 전체 시/군/구 그리드
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_sido.sido, style: tx(15, FontWeight.w700, T.textStrong, height: 1)),
                      Text('${_sido.sigungu.length}개 구역', style: tx(11, FontWeight.w600, T.textDisabled, height: 1)),
                    ],
                  ),
                ),
                _grid(),
              ]),
            ),
          ),
        ]),
      );

  Widget _railItem(int i) {
    final r = _kRegions[i];
    final on = i == _sidoIdx;
    return GestureDetector(
      onTap: () => setState(() => _sidoIdx = i),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: on ? T.white : Colors.transparent,
          border: Border(left: BorderSide(color: on ? _navy : Colors.transparent, width: 3)),
        ),
        child: Row(children: [
          Expanded(
            child: Text(
              r.abbr,
              maxLines: 1,
              overflow: TextOverflow.visible,
              softWrap: false,
              style: tx(14, on ? FontWeight.w700 : FontWeight.w500, on ? _navy : T.textMuted, height: 1.2),
            ),
          ),
          if (on)
            Container(width: 5, height: 5, decoration: const BoxDecoration(color: _navy, shape: BoxShape.circle)),
        ]),
      ),
    );
  }

  // 시/군/구 2-col 그리드 — 긴 이름 줄바꿈 대비 페어 Row(minHeight 44).
  Widget _grid() {
    final items = _sido.sigungu;
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      final left = items[i];
      final right = i + 1 < items.length ? items[i + 1] : null;
      rows.add(Padding(
        padding: EdgeInsets.only(bottom: i + 2 < items.length ? 8 : 0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: _guCell(left)),
          const SizedBox(width: 8),
          Expanded(child: right == null ? const SizedBox() : _guCell(right)),
        ]),
      ));
    }
    return Column(children: rows);
  }

  Widget _guCell(String gu) {
    final on = _sigungu == gu;
    return GestureDetector(
      onTap: () => _pickSigungu(gu),
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? T.primarySoft : T.white,
            borderRadius: BorderRadius.circular(T.rMd),
            border: Border.all(color: on ? T.primary : T.borderDefault, width: 1.5),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
              child: Text(
                gu,
                textAlign: TextAlign.center,
                style: tx(12.5, on ? FontWeight.w700 : FontWeight.w500, on ? T.primary : T.textBody, ls: -0.01, height: 1.25),
              ),
            ),
            if (on) ...[
              const SizedBox(width: 4),
              const Icon(LucideIcons.check, size: 13, color: T.primary),
            ],
          ]),
        ),
      ),
    );
  }

  // ── 핫플레이스 / 상권 카테고리 (선택 지역 연동) ──
  Widget _hotplacesBlock() => Container(
        decoration: const BoxDecoration(
          color: T.white,
          border: Border(top: BorderSide(color: T.borderSubtle)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              const Icon(LucideIcons.flame, size: 14, color: T.accent),
              const SizedBox(width: 6),
              Text('$_sigungu 인기 약속 장소', style: tx(12, FontWeight.w700, T.textStrong, height: 1)),
            ]),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(children: [
              for (var i = 0; i < _hotplaces.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _hotChip(_hotplaces[i]),
              ],
            ]),
          ),
        ]),
      );

  Widget _hotChip(String h) {
    final on = _hotSel == h;
    return GestureDetector(
      onTap: () => setState(() {
        _hotSel = h;
        _home = h;
      }),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: on ? T.accentSoft : T.white,
          borderRadius: BorderRadius.circular(T.rPill),
          border: Border.all(color: on ? T.accent : T.borderDefault, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Opacity(opacity: 0.5, child: Text('#', style: tx(13, FontWeight.w700, on ? T.accent : T.textBody, height: 1))),
          const SizedBox(width: 1),
          Text(h, style: tx(13, FontWeight.w700, on ? T.accent : T.textBody, height: 1)),
        ]),
      ),
    );
  }

  // ── 하단 확정 ──
  Widget _stickyBar() => StickyBar(
        child: MButton(
          '$_home(으)로 설정하고 모임 보기',
          variant: 'primary',
          size: 'lg',
          block: true,
          leadingIcon: const Icon(LucideIcons.check, size: 18, color: T.white),
          onTap: () {
            MoishoToast.show(context, '$_home 주변 모임을 보여드릴게요.', tone: 'success', title: '동네 설정 완료');
            Navigator.of(context).maybePop();
          },
        ),
      );
}
