// 내 정보 수정 — prototype ProfileEditScreen (a6569647:7).
// 아바타 + 사진 변경 · 기본 정보(이름/이메일/자기소개) · 관심사 해시태그 검색·선택 · 저장 CTA.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _name = TextEditingController(text: '홍길동');
  final _email = TextEditingController(text: 'hong@email.com');
  final _bio = TextEditingController(
      text: '밴드에서 베이스 치고, 주말엔 필름 카메라 들고 다녀요. 정산은 늘 칼같이 🙌');
  final _tagQuery = TextEditingController();

  List<String> _selInterests = ['밴드', '독서', '사진'];

  static const _avatar =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=160&h=160&fit=crop&crop=face&auto=format&q=80';

  static const _allTags = [
    '밴드', '독서', '사진', '영화', '등산', '요리', '게임', '여행', '운동', '드로잉',
    '보드게임', '클라이밍', '러닝', '베이킹', '와인', '커피', '캠핑', '테니스', '수영', '전시관람',
    '코딩', '재테크', '반려동물', '봉사', '댄스', '노래', '기타연주', '필름카메라', '풋살', '농구',
    '요가', '명상',
  ];

  @override
  void initState() {
    super.initState();
    _bio.addListener(_onChange);
    _tagQuery.addListener(_onChange);
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _bio.dispose();
    _tagQuery.dispose();
    super.dispose();
  }

  String get _cleanQuery => _tagQuery.text.replaceFirst(RegExp(r'^#'), '').trim();

  List<String> get _suggestions {
    final q = _cleanQuery;
    final filtered = q.isNotEmpty
        ? _allTags.where((t) => t.contains(q) && !_selInterests.contains(t))
        : _allTags.where((t) => !_selInterests.contains(t));
    return filtered.take(8).toList();
  }

  bool get _canAddNew =>
      _cleanQuery.isNotEmpty &&
      !_allTags.contains(_cleanQuery) &&
      !_selInterests.contains(_cleanQuery);

  void _addTag(String t) => setState(() {
        if (!_selInterests.contains(t)) {
          _selInterests = [..._selInterests, t];
        }
        _tagQuery.clear();
      });

  void _toggleInterest(String t) => setState(() {
        _selInterests = _selInterests.contains(t)
            ? _selInterests.where((x) => x != t).toList()
            : [..._selInterests, t];
      });

  void _onSubmitQuery() {
    final sugg = _suggestions;
    if (_canAddNew) {
      _addTag(_cleanQuery);
    } else if (sugg.isNotEmpty) {
      _addTag(sugg.first);
    }
  }

  void _save() {
    MoishoToast.show(context, '정보가 저장됐어요!', tone: 'success');
    Navigator.of(context).maybePop();
  }

  // ── 입력 박스 데코 — outline:none(포커스 링 없음) 재현: focused == enabled ──
  InputDecoration _inputDeco({String? hint, Widget? prefix}) => InputDecoration(
        hintText: hint,
        hintStyle: tx(14, FontWeight.w500, T.textDisabled, height: 1),
        prefixIcon: prefix,
        isDense: true,
        filled: true,
        fillColor: T.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(T.rMd),
          borderSide: const BorderSide(color: T.borderDefault, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(T.rMd),
          borderSide: const BorderSide(color: T.borderDefault, width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '내 정보 수정', onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 24, T.padScreen, 24),
            children: [
              _avatarBlock(),
              const SizedBox(height: 28),
              const SectionLabel('기본 정보'),
              _basicInfoCard(),
              const SizedBox(height: 20),
              const SectionLabel('관심사'),
              _interestsSection(),
            ],
          ),
        ),
        StickyBar(
          child: MButton('저장하기', variant: 'primary', size: 'lg', block: true, onTap: _save),
        ),
      ]),
    );
  }

  // ── 아바타 + 사진 변경 ──
  Widget _avatarBlock() => Center(
        child: SizedBox(
          width: 72,
          height: 72,
          child: Stack(clipBehavior: Clip.none, children: [
            ClipOval(
              child: NetImage(
                url: _avatar,
                width: 72,
                height: 72,
                fallback: const MAvatar(name: '홍길동', size: 72),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () => MoishoToast.show(context, '프로필 사진 변경', tone: 'info'),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: T.textBody,
                    shape: BoxShape.circle,
                    border: Border.all(color: T.white, width: 2),
                  ),
                  child: const Icon(LucideIcons.camera, size: 13, color: T.white),
                ),
              ),
            ),
          ]),
        ),
      );

  // ── 기본 정보 카드 ──
  Widget _basicInfoCard() => MCard(
        elevation: 'raised',
        radius: T.rXl,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _fieldLabel('이름'),
          const SizedBox(height: 7),
          SizedBox(
            height: 42,
            child: TextField(
              controller: _name,
              style: tx(14, FontWeight.w500, T.textStrong, height: 1),
              decoration: _inputDeco(),
            ),
          ),
          const SizedBox(height: 14),
          _fieldLabel('이메일'),
          const SizedBox(height: 7),
          SizedBox(
            height: 42,
            child: TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              style: tx(14, FontWeight.w500, T.textStrong, height: 1),
              decoration: _inputDeco(),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _fieldLabel('자기소개'),
              Text('${_bio.text.length}/60',
                  style: tx(11, FontWeight.w500, T.textDisabled, height: 1, tab: true)),
            ],
          ),
          const SizedBox(height: 7),
          TextField(
            controller: _bio,
            minLines: 3,
            maxLines: 3,
            maxLength: 60,
            inputFormatters: [LengthLimitingTextInputFormatter(60)],
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
            style: tx(14, FontWeight.w500, T.textStrong, height: 1.5),
            decoration: _inputDeco(hint: '나를 한 줄로 소개해보세요'),
          ),
        ]),
      );

  Widget _fieldLabel(String text) =>
      Text(text, style: tx(12, FontWeight.w600, T.textMuted, height: 1));

  // ── 관심사 ──
  Widget _interestsSection() {
    final suggestions = _suggestions;
    final hasSelected = _selInterests.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 검색 입력
        TextField(
          controller: _tagQuery,
          onSubmitted: (_) => _onSubmitQuery(),
          style: tx(14, FontWeight.w500, T.textStrong, height: 1),
          decoration: _inputDeco(
            hint: '관심사 해시태그 검색',
            prefix: const Padding(
              padding: EdgeInsets.only(left: 13, right: 8),
              child: Icon(LucideIcons.search, size: 17, color: T.textDisabled),
            ),
          ).copyWith(
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
        const SizedBox(height: 12),
        // 추천/검색 결과
        if (_canAddNew || suggestions.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_canAddNew) _addNewChip(),
              for (final t in suggestions) _suggestionChip(t),
            ],
          )
        else
          Text('모든 추천 태그를 추가했어요',
              style: tx(13, FontWeight.w500, T.textDisabled, height: 1.4)),
        // 선택된 관심사
        if (hasSelected) ...[
          const SizedBox(height: 16),
          Text('내 관심사 ${_selInterests.length}',
              style: tx(12, FontWeight.w600, T.textMuted, height: 1)),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final t in _selInterests) _selectedChip(t)],
          ),
        ],
      ]),
    );
  }

  Widget _addNewChip() => GestureDetector(
        onTap: () => _addTag(_cleanQuery),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: T.primarySoft,
            borderRadius: BorderRadius.circular(T.rPill),
            border: Border.all(color: T.primary, width: 1.5), // proto dashed
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.plus, size: 13, color: T.primary),
            const SizedBox(width: 5),
            Text('#$_cleanQuery 추가', style: tx(13, FontWeight.w600, T.primary, height: 1)),
          ]),
        ),
      );

  Widget _suggestionChip(String t) => GestureDetector(
        onTap: () => _addTag(t),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: T.white,
            borderRadius: BorderRadius.circular(T.rPill),
            border: Border.all(color: T.borderDefault, width: 1.5),
          ),
          child: Text('#$t', style: tx(13, FontWeight.w500, T.textMuted, height: 1)),
        ),
      );

  Widget _selectedChip(String t) => Container(
        padding: const EdgeInsets.fromLTRB(13, 7, 9, 7),
        decoration: BoxDecoration(
          color: T.primarySoft,
          borderRadius: BorderRadius.circular(T.rPill),
          border: Border.all(color: T.primary, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('#$t', style: tx(13, FontWeight.w600, T.primary, height: 1)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _toggleInterest(t),
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(color: T.primary, shape: BoxShape.circle),
              child: const Icon(LucideIcons.x, size: 9, color: T.white),
            ),
          ),
        ]),
      );
}
