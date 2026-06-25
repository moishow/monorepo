// 공개 프로필 — prototype PublicProfileScreen (f17988ed:250).
// 등급별 히어로 배너·매너온도·관심사·팔로우·서브탭(활동매너/동아리/모임피드)·DM·신고 시트.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../home/post_detail_screen.dart';
import '../chat/dm_list_screen.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import '../club/club_room_screen.dart';
import 'follow_list_screen.dart';

// ── 신뢰 등급 ──
class _Grade {
  final String label, icon;
  final int min;
  final Color badge;
  final Gradient hero;
  const _Grade(this.label, this.icon, this.min, this.badge, this.hero);
}

// 등급별 히어로 그라데이션 — 프로토타입 linear-gradient(160deg, …) 색쌍을 가장 가까운 토큰으로 매핑.
const _grades = <_Grade>[
  // 씨앗: slate → gray
  _Grade('씨앗', '🌱', 0, T.gray500, // proto #6B7280
      LinearGradient(begin: Alignment(-0.5, -1), end: Alignment(0.5, 1), colors: [T.gray50, T.gray100])),
  // 새싹: emerald → mint
  _Grade('새싹', '🌿', 20, T.success, // proto #059669
      LinearGradient(begin: Alignment(-0.5, -1), end: Alignment(0.5, 1), colors: [T.mint50, T.mint100])),
  // 신뢰: blue
  _Grade('신뢰', '🌳', 50, T.primary, // proto #2563EB
      LinearGradient(begin: Alignment(-0.5, -1), end: Alignment(0.5, 1), colors: [T.blue50, T.blue100])),
  // 우수: violet → purple
  _Grade('우수', '⭐', 75, T.accent, // proto #7C3AED
      LinearGradient(begin: Alignment(-0.5, -1), end: Alignment(0.5, 1), colors: [T.purple50, T.purple100])),
  // 최우수: amber
  _Grade('최우수', '🏆', 92, T.amber600, // proto #D97706
      LinearGradient(begin: Alignment(-0.5, -1), end: Alignment(0.5, 1), colors: [T.amber50, T.amber100])),
];

_Grade _gradeOf(int score) {
  for (final g in _grades.reversed) {
    if (score >= g.min) return g;
  }
  return _grades.first;
}

class _Settlement {
  final String date, title, amount;
  final bool ok;
  const _Settlement(this.date, this.title, this.amount, this.ok);
}

class _Profile {
  final String photo;
  final bool verified;
  final double temp;
  final int score, hosted, joined, receiptRate, delays, followers, following;
  final List<String> clubs;
  final List<_Settlement> settlements;
  final List<String> feedImgs;
  const _Profile({
    required this.photo,
    required this.verified,
    required this.temp,
    required this.score,
    required this.hosted,
    required this.joined,
    required this.receiptRate,
    required this.delays,
    required this.followers,
    required this.following,
    required this.clubs,
    required this.settlements,
    required this.feedImgs,
  });
}

class _Manner {
  final int praises, punctual, noshow, response;
  const _Manner(this.praises, this.punctual, this.noshow, this.response);
}

// 모임피드 이미지 URL 빌더 (프로토타입 I()).
String _img(String id) => 'https://images.unsplash.com/photo-$id?w=200&h=200&fit=crop&auto=format&q=75';

// ── 프로필 목 데이터 (프로토타입 PROFILES) ──
final Map<String, _Profile> _profiles = {
  '박지훈': _Profile(
    photo: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=160&h=160&fit=crop&crop=face&auto=format&q=80',
    verified: true, temp: 37.5, score: 88, hosted: 12, joined: 31, receiptRate: 98, delays: 0,
    clubs: const ['사교/취미', '요리', '와인'], followers: 142, following: 38,
    settlements: const [
      _Settlement('06/04', '와인 & 치즈 홈파티', '인당 25,000원', true),
      _Settlement('05/19', '홍대 맛집 투어', '인당 18,000원', true),
      _Settlement('04/30', '취미 공유 파티', '인당 15,000원', true),
    ],
    feedImgs: [
      _img('1529156069898-49953e39b3ac'), _img('1540317580384-e5d43616b9aa'), _img('1477959858617-67f85cf4f1df'),
      _img('1516450360452-9312f5e86fc7'), _img('1493225457124-a3eb161ffa5f'), _img('1481627834876-b7833e8f5570'),
    ],
  ),
  '이영희': _Profile(
    photo: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=160&h=160&fit=crop&crop=face&auto=format&q=80',
    verified: true, temp: 38.2, score: 95, hosted: 8, joined: 20, receiptRate: 100, delays: 0,
    clubs: const ['스포츠', '풋살'], followers: 89, following: 24,
    settlements: const [
      _Settlement('06/08', '5:5 풋살 매치', '인당 12,000원', true),
      _Settlement('05/25', '풋살 번개', '인당 10,000원', true),
    ],
    feedImgs: [
      _img('1551958219-acbc595d2e8b'), _img('1529156069898-49953e39b3ac'),
      _img('1540317580384-e5d43616b9aa'), _img('1487466365202-1afdb86c764e'),
    ],
  ),
  '김수진': _Profile(
    photo: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=160&h=160&fit=crop&crop=face&auto=format&q=80',
    verified: true, temp: 38.1, score: 62, hosted: 3, joined: 14, receiptRate: 82, delays: 1,
    clubs: const ['봉사', '유기견봉사'], followers: 45, following: 31,
    settlements: const [
      _Settlement('05/12', '봉사 교통비 정산', '인당 8,000원', true),
      _Settlement('04/20', '봉사 식비 정산', '인당 12,000원', false),
    ],
    feedImgs: [
      _img('1529156069898-49953e39b3ac'), _img('1524995997946-a1c2e315a42f'), _img('1481627834876-b7833e8f5570'),
    ],
  ),
  '김회장': _Profile(
    photo: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=160&h=160&fit=crop&crop=face&auto=format&q=80',
    verified: true, temp: 38.5, score: 97, hosted: 2, joined: 45, receiptRate: 100, delays: 0,
    clubs: const ["홍대 연합 밴드 '사운드'"], followers: 312, following: 67,
    settlements: const [
      _Settlement('06/15', '정기 대관 연습', '인당 40,000원', true),
      _Settlement('05/20', '5월 정기 엠티', '인당 82,000원', true),
      _Settlement('04/12', '신입 환영회', '인당 30,000원', true),
    ],
    feedImgs: [
      _img('1516450360452-9312f5e86fc7'), _img('1493225457124-a3eb161ffa5f'), _img('1501612780327-45045538702b'),
      _img('1540317580384-e5d43616b9aa'), _img('1529156069898-49953e39b3ac'), _img('1477959858617-67f85cf4f1df'),
    ],
  ),
  '이총무': _Profile(
    photo: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=160&h=160&fit=crop&crop=face&auto=format&q=80',
    verified: true, temp: 37.8, score: 96, hosted: 2, joined: 38, receiptRate: 100, delays: 0,
    clubs: const ["홍대 연합 밴드 '사운드'"], followers: 98, following: 45,
    settlements: const [
      _Settlement('06/15', '정기 대관 연습', '인당 40,000원', true),
      _Settlement('05/20', '5월 정기 엠티', '인당 82,000원', true),
    ],
    feedImgs: [
      _img('1501612780327-45045538702b'), _img('1516450360452-9312f5e86fc7'),
      _img('1529156069898-49953e39b3ac'), _img('1540317580384-e5d43616b9aa'),
    ],
  ),
  '박소심': _Profile(
    photo: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=160&h=160&fit=crop&crop=face&auto=format&q=80',
    verified: false, temp: 36.5, score: 52, hosted: 0, joined: 8, receiptRate: 75, delays: 2,
    clubs: const ["홍대 연합 밴드 '사운드'"], followers: 23, following: 15,
    settlements: const [],
    feedImgs: [
      _img('1516450360452-9312f5e86fc7'), _img('1501612780327-45045538702b'),
    ],
  ),
  '장열심': _Profile(
    photo: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=160&h=160&fit=crop&crop=face&auto=format&q=80',
    verified: true, temp: 37.3, score: 78, hosted: 1, joined: 22, receiptRate: 92, delays: 0,
    clubs: const ["홍대 연합 밴드 '사운드'"], followers: 67, following: 42,
    settlements: const [_Settlement('05/20', '5월 정기 엠티', '인당 82,000원', true)],
    feedImgs: [
      _img('1493225457124-a3eb161ffa5f'), _img('1501612780327-45045538702b'),
      _img('1516450360452-9312f5e86fc7'), _img('1529156069898-49953e39b3ac'),
    ],
  ),
  '정디자': _Profile(
    photo: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=160&h=160&fit=crop&crop=face&auto=format&q=80',
    verified: true, temp: 37.2, score: 70, hosted: 1, joined: 12, receiptRate: 85, delays: 1,
    clubs: const ["홍대 연합 밴드 '사운드'"], followers: 156, following: 89,
    settlements: const [_Settlement('05/20', '5월 엠티 정산', '인당 82,000원', true)],
    feedImgs: [
      _img('1516450360452-9312f5e86fc7'), _img('1493225457124-a3eb161ffa5f'), _img('1529156069898-49953e39b3ac'),
    ],
  ),
  '이민준': _Profile(
    photo: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=160&h=160&fit=crop&crop=face&auto=format&q=80',
    verified: true, temp: 37.0, score: 75, hosted: 3, joined: 18, receiptRate: 90, delays: 0,
    clubs: const ["서울 사진 동아리 '프레임'"], followers: 234, following: 102,
    settlements: const [_Settlement('06/01', '한강 출사 간식비', '인당 5,000원', true)],
    feedImgs: [
      _img('1542038784456-1ea8e935640e'), _img('1477959858617-67f85cf4f1df'), _img('1456324504439-367cee3b3c32'),
      _img('1516450360452-9312f5e86fc7'), _img('1529156069898-49953e39b3ac'), _img('1481627834876-b7833e8f5570'),
    ],
  ),
  '박회장': _Profile(
    photo: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=160&h=160&fit=crop&crop=face&auto=format&q=80',
    verified: true, temp: 38.0, score: 91, hosted: 4, joined: 29, receiptRate: 97, delays: 0,
    clubs: const ["홍대 연합 밴드 '사운드'"], followers: 287, following: 54,
    settlements: const [_Settlement('05/20', '5월 엠티 정산', '인당 82,000원', true)],
    feedImgs: [
      _img('1493225457124-a3eb161ffa5f'), _img('1501612780327-45045538702b'), _img('1516450360452-9312f5e86fc7'),
      _img('1529156069898-49953e39b3ac'), _img('1540317580384-e5d43616b9aa'),
    ],
  ),
};

const _defaultProfile = _Profile(
  photo: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=160&h=160&fit=crop&crop=face&auto=format&q=80',
  verified: false, temp: 36.5, score: 40, hosted: 0, joined: 3, receiptRate: 70, delays: 0,
  clubs: [], followers: 0, following: 0, settlements: [], feedImgs: [],
);

// ── 자기소개 ──
const _bios = {
  '박지훈': '와인과 요리를 좋아하는 모임러. 좋은 사람들과 맛있는 거 먹는 게 인생 낙이에요 🍷',
  '이영희': '주 3회 풋살하는 운동 중독자. 같이 뛸 사람 언제든 환영! ⚽',
  '김수진': '유기견 봉사 4년차. 따뜻한 마음 가진 분들과 함께하고 싶어요 🐶',
  '김회장': '사운드 밴드 회장 맡고 있습니다. 음악으로 하나 되는 순간을 사랑해요 🎸',
  '이총무': '사운드 살림꾼. 정산은 깔끔하게, 모임은 즐겁게가 모토예요 📒',
  '박소심': '아직 부원 초보지만 열심히 배우는 중입니다. 잘 부탁드려요!',
  '장열심': '이름값 하는 만년 개근러. 모임이 있으면 일단 갑니다 🔥',
  '정디자': '디자이너 겸 밴드 키보드. 공연 포스터는 제가 다 만들어요 🎨',
  '이민준': '필름 사진에 진심입니다. 출사 같이 다닐 분 구해요 📷',
  '박회장': '여러 동아리 거쳐온 모임 베테랑. 분위기 메이커 자처합니다 😎',
};
const _defaultBio = '아직 자기소개가 없어요.';

// ── 매너지표 (없으면 프로필 수치에서 파생) ──
const _mannerMap = {
  '박지훈': _Manner(31, 97, 0, 95),
  '이영희': _Manner(42, 99, 0, 98),
  '김수진': _Manner(12, 84, 1, 80),
  '김회장': _Manner(58, 98, 0, 96),
  '이총무': _Manner(39, 99, 0, 94),
  '박소심': _Manner(4, 72, 2, 65),
  '장열심': _Manner(21, 95, 0, 88),
  '정디자': _Manner(27, 90, 1, 85),
  '이민준': _Manner(33, 93, 0, 90),
  '박회장': _Manner(46, 96, 0, 92),
};

_Manner _mannerOf(String name, _Profile p) =>
    _mannerMap[name] ??
    _Manner(
      (p.joined * 0.6).round(),
      math.min(99, (p.receiptRate * 0.95).round()),
      p.delays,
      math.min(99, (p.receiptRate * 0.9).round()),
    );

// ── 관심사 ──
const _interestsMap = {
  '박지훈': ['와인', '요리', '맛집투어', '홈파티'],
  '이영희': ['풋살', '러닝', '운동', '등산'],
  '김수진': ['봉사', '유기견', '독서'],
  '김회장': ['밴드', '기타연주', '공연', '작곡'],
  '이총무': ['밴드', '재테크', '엑셀', '커피'],
  '박소심': ['밴드', '보드게임'],
  '장열심': ['밴드', '노래', '운동'],
  '정디자': ['밴드', '드로잉', '디자인', '전시관람'],
  '이민준': ['사진', '필름카메라', '여행', '출사'],
  '박회장': ['밴드', '캠핑', '다트'],
};

class _ClubDetail {
  final String? img;
  final int members;
  final String role;
  const _ClubDetail(this.img, this.members, this.role);
}

const _clubDetails = {
  "홍대 연합 밴드 '사운드'": _ClubDetail('https://images.unsplash.com/photo-1501612780327-45045538702b?w=88&h=88&fit=crop&auto=format&q=80', 18, '부원'),
  '책과 사람들 독서모임': _ClubDetail('https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=88&h=88&fit=crop&auto=format&q=80', 9, '운영진'),
  '필름 사진 동호회': _ClubDetail('https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=88&h=88&fit=crop&auto=format&q=80', 24, '부원'),
  '사교/취미': _ClubDetail('https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=88&h=88&fit=crop&auto=format&q=80', 31, '부원'),
  '요리': _ClubDetail('https://images.unsplash.com/photo-1540317580384-e5d43616b9aa?w=88&h=88&fit=crop&auto=format&q=80', 12, '운영진'),
  '와인': _ClubDetail('https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=88&h=88&fit=crop&auto=format&q=80', 8, '부원'),
  '스포츠': _ClubDetail('https://images.unsplash.com/photo-1551958219-acbc595d2e8b?w=88&h=88&fit=crop&auto=format&q=80', 20, '부원'),
  '풋살': _ClubDetail('https://images.unsplash.com/photo-1487466365202-1afdb86c764e?w=88&h=88&fit=crop&auto=format&q=80', 14, '부원'),
  '봉사': _ClubDetail('https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=88&h=88&fit=crop&auto=format&q=80', 22, '부원'),
  '유기견봉사': _ClubDetail('https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=88&h=88&fit=crop&auto=format&q=80', 9, '부원'),
  "서울 사진 동아리 '프레임'": _ClubDetail('https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=88&h=88&fit=crop&auto=format&q=80', 35, '운영진'),
};

const _reportReasons = ['정산금 미납 · 먹튀', '노쇼 · 약속 불이행', '부적절한 언행 · 비매너', '사칭 · 허위 프로필', '기타'];

class PublicProfileScreen extends StatefulWidget {
  final String name;
  const PublicProfileScreen({super.key, this.name = "박회장"});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  bool _expanded = false;
  String _activeTab = 'credit';
  bool _following = false;
  bool _reportOpen = false;
  String? _reportReason;

  _Profile get _p => _profiles[widget.name] ?? _defaultProfile;
  String get _name => widget.name;

  void _toggleFollow() => setState(() => _following = !_following);


  void _submitReport() {
    setState(() => _reportOpen = false);
    MoishoToast.show(context, '신고가 접수됐어요. 운영팀이 24시간 내 검토합니다.', tone: 'success');
  }

  @override
  Widget build(BuildContext context) {
    final p = _p;
    final g = _gradeOf(p.score);
    return Scaffold(
      backgroundColor: T.white,
      body: Stack(children: [
        Column(children: [
          const MoishoStatusBar(),
          _hero(p, g),
          _subTabs(p),
          Expanded(child: _tabBody(p)),
          _bottomBar(),
        ]),
        if (_reportOpen) _reportSheet(),
      ]),
    );
  }

  // ── 히어로 배너 ──
  Widget _hero(_Profile p, _Grade g) {
    final interests = _interestsMap[_name];
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: g.hero),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      child: Column(children: [
        // 되돌리기 / 신고
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _circleBtn(LucideIcons.arrowLeft, 19, T.textStrong, () => Navigator.of(context).maybePop()),
            _circleBtn(LucideIcons.flag, 16, T.textMuted, () {
              setState(() {
                _reportReason = null;
                _reportOpen = true;
              });
            }),
          ]),
        ),
        const SizedBox(height: 10),
        // 아바타
        SizedBox(
          width: 64, height: 64,
          child: Stack(clipBehavior: Clip.none, children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 3),
                boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 16, offset: Offset(0, 4))],
              ),
              child: ClipOval(child: NetImage(url: p.photo, width: 64, height: 64, fallback: MAvatar(name: _name, size: 64))),
            ),
            if (p.verified)
              Positioned(
                right: 2, bottom: 2,
                child: Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(color: T.primary, shape: BoxShape.circle, border: Border.all(color: T.white, width: 2)),
                  child: const Icon(LucideIcons.check, size: 9, color: T.white),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 10),
        // 이름 + 인증
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(_name, style: tx(17, FontWeight.w700, T.textStrong, height: 1)),
          if (p.verified) ...[const SizedBox(width: 6), const MBadge('본인인증', tone: 'blue', variant: 'soft')],
        ]),
        const SizedBox(height: 10),
        // 매너온도 칩
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.74), borderRadius: BorderRadius.circular(T.rPill)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('🌡️', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 5),
            Text('${p.temp}℃', style: tx(11, FontWeight.w700, T.textStrong, height: 1)),
          ]),
        ),
        const SizedBox(height: 10),
        // 자기소개
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(_bios[_name] ?? _defaultBio,
              textAlign: TextAlign.center, style: tx(13, FontWeight.w500, T.textBody, height: 1.55)),
        ),
        // 관심사 해시태그
        if (interests != null && interests.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6, runSpacing: 6, alignment: WrapAlignment.center,
            children: [for (final t in interests) _interestChip(t)],
          ),
        ],
        const SizedBox(height: 10),
        // 팔로워/팔로잉 + 팔로우 버튼
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            child: Row(children: [
              _followStat(fmtCount(_following ? p.followers + 1 : p.followers), '팔로워',
                  () => _pushFollow('followers')),
              const SizedBox(width: 16),
              Container(width: 1, height: 22, color: Colors.black.withValues(alpha: 0.12)),
              const SizedBox(width: 16),
              _followStat(fmtCount(p.following), '팔로잉', () => _pushFollow('following')),
            ]),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            GestureDetector(
              onTap: _toggleFollow,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: _following ? T.primary : Colors.white.withValues(alpha: 0.74),
                  borderRadius: BorderRadius.circular(T.rPill),
                  border: Border.all(color: T.primary, width: 1.5),
                ),
                child: Text(_following ? '팔로잉 ✓' : '+ 팔로우',
                    style: tx(12, FontWeight.w700, _following ? T.white : T.primary, height: 1)),
              ),
            ),
            if (!_following) ...[
              const SizedBox(height: 3),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 90),
                child: Text('번개 개설 시 알림 받기',
                    textAlign: TextAlign.right,
                    style: tx(10, FontWeight.w500, Colors.black.withValues(alpha: 0.38), height: 1.3)),
              ),
            ],
          ]),
        ]),
        // 소속 동아리 태그
        if (p.clubs.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 5, runSpacing: 5, alignment: WrapAlignment.center,
            children: [for (final cl in p.clubs) _clubChip(cl)],
          ),
        ],
      ]),
    );
  }

  Widget _circleBtn(IconData icon, double size, Color color, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 40, height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), shape: BoxShape.circle),
          child: Icon(icon, size: size, color: color),
        ),
      );

  Widget _interestChip(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(T.rPill),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        ),
        child: Text('#$t', style: tx(11, FontWeight.w600, T.primary, height: 1)),
      );

  Widget _clubChip(String cl) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(T.rPill),
          border: Border.all(color: Colors.black.withValues(alpha: 0.07)),
        ),
        child: Text('#$cl', style: tx(11, FontWeight.w600, T.textMuted, height: 1)),
      );

  Widget _followStat(String value, String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(value, style: tx(15, FontWeight.w700, T.textStrong, height: 1, tab: true)),
          const SizedBox(height: 1),
          Text(label, style: tx(10, FontWeight.w500, T.textMuted, height: 1)),
        ]),
      );

  void _pushFollow(String tab) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => FollowListScreen(owner: _name, tab: tab)),
      );

  // ── Sticky 서브탭 ──
  Widget _subTabs(_Profile p) {
    final tabs = [
      (id: 'credit', icon: LucideIcons.barChart3, label: '활동·매너'),
      (id: 'clubs', icon: LucideIcons.building2, label: '동아리 ${p.clubs.length}'),
      (id: 'feed', icon: LucideIcons.layoutGrid, label: '모임피드${p.feedImgs.isNotEmpty ? ' ${p.feedImgs.length}' : ''}'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: T.white,
        border: Border(bottom: BorderSide(color: T.borderSubtle)),
      ),
      child: Row(children: [
        for (final tab in tabs)
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = tab.id),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _activeTab == tab.id ? T.primary : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(tab.icon, size: 15, color: _activeTab == tab.id ? T.primary : T.textMuted),
                  const SizedBox(width: 5),
                  Text(tab.label,
                      style: tx(13, _activeTab == tab.id ? FontWeight.w700 : FontWeight.w500,
                          _activeTab == tab.id ? T.primary : T.textMuted, height: 1)),
                ]),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _tabBody(_Profile p) {
    switch (_activeTab) {
      case 'clubs':
        return _clubsTab(p);
      case 'feed':
        return _feedTab(p);
      default:
        return _creditTab(p);
    }
  }

  // ── 📊 활동·매너 탭 ──
  Widget _creditTab(_Profile p) {
    final mn = _mannerOf(_name, p);
    final stats = [
      (icon: LucideIcons.zap, label: '번개 참여', val: '${p.joined}회', col: T.primary),
      (icon: LucideIcons.star, label: '번개 주최', val: '${p.hosted}회', col: T.accent), // proto #7C3AED
      (
        icon: LucideIcons.clock,
        label: '정산 지연',
        val: p.delays == 0 ? '없음' : '${p.delays}회',
        col: p.delays == 0 ? T.success : T.danger // proto #059669 / #DC2626
      ),
    ];
    final mannerCells = [
      (icon: LucideIcons.thumbsUp, label: '받은 칭찬', val: '${mn.praises}개', col: T.primary),
      (icon: LucideIcons.clock, label: '정시 참석률', val: '${mn.punctual}%', col: T.success), // proto #16A34A
      (
        icon: LucideIcons.shieldCheck,
        label: '약속 이행률',
        val: '${math.max(60, 100 - mn.noshow * 8)}%',
        col: mn.noshow == 0 ? T.success : T.amber600 // proto #16A34A / #D97706
      ),
      (icon: LucideIcons.messageCircle, label: '응답률', val: '${mn.response}%', col: T.accent), // proto #7C3AED
    ];
    return Container(
      color: T.gray50,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
        physics: const BouncingScrollPhysics(),
        children: [
          // 매너지표 헤더
          Row(children: [
            const Icon(LucideIcons.thermometer, size: 15, color: T.warning), // proto #F59E0B
            const SizedBox(width: 6),
            Text('매너지표', style: tx(13, FontWeight.w700, T.textTitle, height: 1)),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(color: T.white, borderRadius: BorderRadius.circular(T.rXl)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('매너온도', style: tx(11, FontWeight.w500, T.textMuted, height: 1)),
              const SizedBox(height: 5),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Text('${p.temp}℃', style: tx(28, FontWeight.w700, T.warning, ls: -0.02, height: 1, tab: true)), // proto #F59E0B
                const SizedBox(width: 6),
                Icon(LucideIcons.smile, size: 13, color: p.temp >= 37 ? T.success : T.textMuted), // proto #16A34A
                const SizedBox(width: 3),
                Text(p.temp >= 38 ? '아주 좋아요' : (p.temp >= 37 ? '좋아요' : '보통이에요'),
                    style: tx(11, FontWeight.w700, p.temp >= 37 ? T.success : T.textMuted, height: 1)),
              ]),
              const SizedBox(height: 8),
              // 온도 게이지 바
              SizedBox(
                height: 16,
                child: Stack(clipBehavior: Clip.none, children: [
                  Positioned(
                    top: 4, left: 0, right: 0,
                    child: Opacity(
                      opacity: 0.85,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(T.rPill),
                          gradient: const LinearGradient(
                            // proto #93C5FD → #FDE68A → #FB923C (가까운 토큰 없음)
                            colors: [T.blue300, T.amber100, T.amber500],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment(((math.min(p.temp / 99, 1) * 2) - 1).toDouble(), 0),
                    child: Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        color: T.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: T.warning, width: 3), // proto #F59E0B
                        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 1))],
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 18),
              // 매너 셀 2x2
              Row(children: [
                Expanded(child: _mannerCell(mannerCells[0])),
                const SizedBox(width: 10),
                Expanded(child: _mannerCell(mannerCells[1])),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _mannerCell(mannerCells[2])),
                const SizedBox(width: 10),
                Expanded(child: _mannerCell(mannerCells[3])),
              ]),
            ]),
          ),
          const SizedBox(height: 22),
          // 정산 신뢰 지표 헤더
          Row(children: [
            const Icon(LucideIcons.shieldCheck, size: 14, color: T.primary),
            const SizedBox(width: 6),
            Text('정산 신뢰 지표', style: tx(13, FontWeight.w700, T.textTitle, height: 1)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(T.rPill)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 5, height: 5, decoration: const BoxDecoration(color: T.primary, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('모이쇼 인증', style: tx(10, FontWeight.w700, T.primary, height: 1)),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          // Arc + 3-stat 그리드
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(color: T.white, borderRadius: BorderRadius.circular(T.rXl)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _ArcProgress(pct: p.receiptRate),
                  const SizedBox(height: 5),
                  Text('영수증 업로드', style: tx(10, FontWeight.w600, T.textMuted, height: 1)),
                ]),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  for (var i = 0; i < stats.length; i++) ...[
                    Expanded(child: _statCell(stats[i])),
                    if (i < stats.length - 1) const SizedBox(width: 7),
                  ],
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          // 지연 배너
          if (p.delays == 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: T.successSoft, // proto #F0FDF4
                borderRadius: BorderRadius.circular(T.rLg),
                border: Border.all(color: T.mint100), // proto #BBF7D0
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                const Text('🏆', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(text: '정산 지연 0회 달성!', style: tx(12, FontWeight.w700, T.successStrong, height: 1)), // proto #15803D
                      TextSpan(text: '  모든 정산을 기한 내 완료했어요', style: tx(11, FontWeight.w500, T.success, height: 1)), // proto #16A34A
                    ]),
                  ),
                ),
              ]),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: T.dangerSoft, // proto #FEF2F2
                borderRadius: BorderRadius.circular(T.rLg),
                border: Border.all(color: T.coral100), // proto #FECACA
              ),
              child: Row(children: [
                const Icon(LucideIcons.alertTriangle, size: 14, color: T.danger), // proto #DC2626
                const SizedBox(width: 8),
                Text('정산 지연 ${p.delays}회 이력이 있어요', style: tx(12, FontWeight.w600, T.danger, height: 1)),
              ]),
            ),
          const SizedBox(height: 14),
          // 최근 정산 아코디언
          if (p.settlements.isNotEmpty) _settlementsAccordion(p),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _mannerCell(({IconData icon, String label, String val, Color col}) m) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: T.gray50, borderRadius: BorderRadius.circular(T.rLg)),
        child: Row(children: [
          Container(
            width: 30, height: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: T.white, shape: BoxShape.circle),
            child: Icon(m.icon, size: 15, color: m.col),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(m.val, style: tx(15, FontWeight.w700, m.col, height: 1, tab: true)),
              const SizedBox(height: 4),
              Text(m.label, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: tx(10, FontWeight.w500, T.textMuted, height: 1.2)),
            ]),
          ),
        ]),
      );

  Widget _statCell(({IconData icon, String label, String val, Color col}) st) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(color: T.white, borderRadius: BorderRadius.circular(T.rLg)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Icon(st.icon, size: 13, color: st.col),
          const SizedBox(height: 5),
          Text(st.val, style: tx(14, FontWeight.w700, st.col, height: 1, tab: true)),
          const SizedBox(height: 5),
          Text(st.label, style: tx(9, FontWeight.w500, T.textDisabled, height: 1.3)),
        ]),
      );

  Widget _settlementsAccordion(_Profile p) => Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: T.borderSubtle))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('최근 정산 내역', style: tx(13, FontWeight.w600, T.textTitle, height: 1)),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('${p.settlements.length}건', style: tx(11, FontWeight.w500, T.textMuted, height: 1)),
                  const SizedBox(width: 4),
                  Icon(_expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 14, color: T.textMuted),
                ]),
              ]),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(children: [
                for (final s in p.settlements) ...[
                  _settlementRow(s),
                  if (s != p.settlements.last) const SizedBox(height: 7),
                ],
              ]),
            ),
        ]),
      );

  Widget _settlementRow(_Settlement s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: T.white,
          borderRadius: BorderRadius.circular(T.rLg),
          border: Border.all(color: T.borderSubtle),
        ),
        child: Row(children: [
          Container(
            width: 28, height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: s.ok ? T.successSoft : T.dangerSoft, // proto #DCFCE7 / #FEE2E2
              borderRadius: BorderRadius.circular(T.rMd),
            ),
            child: Icon(s.ok ? LucideIcons.check : LucideIcons.x, size: 13,
                color: s.ok ? T.success : T.danger), // proto #16A34A / #DC2626
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: tx(12, FontWeight.w600, T.textTitle, height: 1.2)),
              const SizedBox(height: 3),
              Text('${s.date} · ${s.amount}', style: tx(10, FontWeight.w500, T.textMuted, height: 1)),
            ]),
          ),
          const SizedBox(width: 8),
          MBadge(s.ok ? '정상' : '지연', tone: s.ok ? 'success' : 'danger', variant: 'soft'),
        ]),
      );

  // ── 🏛 동아리 탭 ──
  Widget _clubsTab(_Profile p) {
    if (p.clubs.isEmpty) {
      return Container(
        color: T.white,
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text('소속 동아리가 없어요', style: tx(13, FontWeight.w500, T.textDisabled, height: 1.5)),
      );
    }
    return Container(
      color: T.white,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        physics: const BouncingScrollPhysics(),
        children: [
          for (var i = 0; i < p.clubs.length; i++) ...[
            _clubRow(p.clubs[i]),
            if (i < p.clubs.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _clubRow(String cl) {
    final cd = _clubDetails[cl] ?? const _ClubDetail(null, 0, '부원');
    final isOp = cd.role == '운영진';
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ClubRoomScreen())),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: T.gray50,
          borderRadius: BorderRadius.circular(T.rXl),
          border: Border.all(color: T.borderSubtle),
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(T.rMd),
            child: NetImage(url: cd.img, width: 44, height: 44, fallback: Container(width: 44, height: 44, color: T.gray100)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(cl, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: tx(13, FontWeight.w600, T.textTitle, height: 1.2)),
              const SizedBox(height: 5),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isOp ? T.primarySoft : T.gray100,
                    borderRadius: BorderRadius.circular(T.rPill),
                  ),
                  child: Text(cd.role, style: tx(10, FontWeight.w700, isOp ? T.primary : T.textMuted, height: 1)),
                ),
                if (cd.members > 0) ...[
                  const SizedBox(width: 6),
                  Text('멤버 ${cd.members}명', style: tx(11, FontWeight.w500, T.textMuted, height: 1)),
                ],
              ]),
            ]),
          ),
          const Icon(LucideIcons.chevronRight, size: 16, color: T.textDisabled),
        ]),
      ),
    );
  }

  // ── 📸 모임피드 탭 ──
  Widget _feedTab(_Profile p) {
    if (p.feedImgs.isEmpty) {
      return Container(
        color: T.white,
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.symmetric(vertical: 52, horizontal: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56, height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: T.gray50, shape: BoxShape.circle),
            child: const Icon(LucideIcons.camera, size: 26, color: T.textDisabled),
          ),
          const SizedBox(height: 12),
          Text('아직 업로드한 모임 사진이 없어요',
              textAlign: TextAlign.center, style: tx(14, FontWeight.w600, T.textMuted, height: 1.3)),
          const SizedBox(height: 6),
          Text('번개 참여 후 쇼츠를 올려보세요',
              textAlign: TextAlign.center, style: tx(12, FontWeight.w500, T.textDisabled, height: 1.4)),
        ]),
      );
    }
    return Container(
      color: T.white,
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        children: [
          for (final img in p.feedImgs)
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PostDetailScreen())),
              child: NetImage(url: img, fit: BoxFit.cover, fallback: Container(color: T.gray100)),
            ),
          // 마지막 행 빈 셀로 채우기 (프로토타입 동작)
          if (p.feedImgs.length % 3 != 0)
            for (var i = 0; i < 3 - p.feedImgs.length % 3; i++) Container(color: T.gray50),
        ],
      ),
    );
  }

  // ── 하단 액션 버튼 ──
  Widget _bottomBar() => Container(
        decoration: const BoxDecoration(
          color: T.white,
          border: Border(top: BorderSide(color: T.borderSubtle)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        child: SafeArea(
          top: false,
          child: MButton('DM 보내기', variant: 'primary', size: 'md', block: true,
              leadingIcon: const Icon(LucideIcons.messageCircle, size: 16, color: T.white),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DmChatScreen(conv: DmConv.quick(_name))))),
        ),
      );

  // ── 신고 사유 시트 ──
  Widget _reportSheet() => Positioned.fill(
        child: GestureDetector(
          onTap: () => setState(() => _reportOpen = false),
          child: Container(
            color: Colors.black.withValues(alpha: 0.4),
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: T.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(T.rXl)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: SafeArea(
                  top: false,
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Center(
                      child: Container(
                        width: 36, height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(color: T.borderDefault, borderRadius: BorderRadius.circular(T.rPill)),
                      ),
                    ),
                    Text('$_name님 신고', style: tx(16, FontWeight.w700, T.textStrong, height: 1.3)),
                    const SizedBox(height: 4),
                    Text('신고 사유를 선택하면 운영팀이 검토해요. 신고자 정보는 비공개로 보호됩니다.',
                        style: tx(12, FontWeight.w500, T.textMuted, height: 1.5)),
                    const SizedBox(height: 16),
                    for (final r in _reportReasons) ...[
                      _reasonRow(r),
                      if (r != _reportReasons.last) const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 18),
                    MButton('신고 접수', variant: 'danger', size: 'lg', block: true,
                        disabled: _reportReason == null, onTap: _submitReport),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _reasonRow(String r) {
    final on = _reportReason == r;
    return GestureDetector(
      onTap: () => setState(() => _reportReason = r),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: on ? T.primarySoft : T.white,
          borderRadius: BorderRadius.circular(T.rMd),
          border: Border.all(color: on ? T.primary : T.borderSubtle, width: 1.5),
        ),
        child: Row(children: [
          Container(
            width: 18, height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: on ? T.primary : T.borderDefault, width: 1.5),
            ),
            child: on
                ? Container(width: 9, height: 9, decoration: const BoxDecoration(color: T.primary, shape: BoxShape.circle))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(r,
                style: tx(14, on ? FontWeight.w700 : FontWeight.w500, on ? T.primary : T.textBody, height: 1.3)),
          ),
        ]),
      ),
    );
  }
}

// ── Arc Progress 게이지 (270° 호, 하단 90° 갭) ──
class _ArcProgress extends StatelessWidget {
  final int pct;
  final double size = 88;
  const _ArcProgress({required this.pct});

  @override
  Widget build(BuildContext context) {
    final col = pct >= 90
        ? T.success // proto #16A34A
        : (pct >= 75 ? T.amber600 : T.danger); // proto #D97706 / #DC2626
    return SizedBox(
      width: size, height: size,
      child: Stack(alignment: Alignment.center, children: [
        CustomPaint(size: Size(size, size), painter: _ArcPainter(pct: pct, color: col)),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('$pct%', style: tx(17, FontWeight.w700, col, height: 1, tab: true)),
          const SizedBox(height: 2),
          Text('준수율', style: tx(9, FontWeight.w500, T.textMuted, height: 1)),
        ]),
      ]),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final int pct;
  final Color color;
  const _ArcPainter({required this.pct, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const sw = 8.0;
    final r = (size.width - sw) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: r);
    const start = 3 * math.pi / 4; // 135° — 하단 좌측에서 시작
    const sweep = 3 * math.pi / 2; // 270° 호, 하단 6시 방향에 90° 갭

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round
      ..color = T.gray100;
    canvas.drawArc(rect, start, sweep, false, track);

    final fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round
      ..color = color;
    final frac = math.min(pct, 100) / 100;
    canvas.drawArc(rect, start, sweep * frac, false, fillPaint);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.pct != pct || old.color != color;
}
