// 팔로워/팔로잉 목록 — prototype FollowListScreen (f17988ed:655).
// 세그먼트 탭(팔로워·팔로잉) + 프로필 행(아바타·인증·등급·소개·팔로우 토글).
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import 'public_profile_screen.dart';

// ── 신뢰 등급(프로토타입 GRADES) ──
class _Grade {
  final String label, icon;
  final int min;
  final Color b;
  const _Grade(this.label, this.icon, this.min, this.b);
}

const _grades = [
  _Grade('씨앗', '🌱', 0, T.textMuted), // proto #6B7280
  _Grade('새싹', '🌿', 20, T.success), // proto #059669
  _Grade('신뢰', '🌳', 50, T.primary), // proto #2563EB
  _Grade('우수', '⭐', 75, T.accent), // proto #7C3AED
  _Grade('최우수', '🏆', 92, T.amber600), // proto #D97706
];

_Grade _getGrade(int s) {
  for (var i = _grades.length - 1; i >= 0; i--) {
    if (s >= _grades[i].min) return _grades[i];
  }
  return _grades[0];
}

// ── 프로필 목 데이터(프로토타입 PROFILES — FollowListScreen에서 쓰는 필드만) ──
class _Profile {
  final String photo;
  final bool verified;
  final double temp;
  final int score;
  const _Profile(this.photo, this.verified, this.temp, this.score);
}

const _profiles = <String, _Profile>{
  '박지훈': _Profile('https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=160&h=160&fit=crop&crop=face&auto=format&q=80', true, 37.5, 88),
  '이영희': _Profile('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=160&h=160&fit=crop&crop=face&auto=format&q=80', true, 38.2, 95),
  '김수진': _Profile('https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=160&h=160&fit=crop&crop=face&auto=format&q=80', true, 38.1, 62),
  '김회장': _Profile('https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=160&h=160&fit=crop&crop=face&auto=format&q=80', true, 38.5, 97),
  '이총무': _Profile('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=160&h=160&fit=crop&crop=face&auto=format&q=80', true, 37.8, 96),
  '박소심': _Profile('https://images.unsplash.com/photo-1517841905240-472988babdf9?w=160&h=160&fit=crop&crop=face&auto=format&q=80', false, 36.5, 52),
  '장열심': _Profile('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=160&h=160&fit=crop&crop=face&auto=format&q=80', true, 37.3, 78),
  '정디자': _Profile('https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=160&h=160&fit=crop&crop=face&auto=format&q=80', true, 37.2, 70),
  '이민준': _Profile('https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=160&h=160&fit=crop&crop=face&auto=format&q=80', true, 37.0, 75),
  '박회장': _Profile('https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=160&h=160&fit=crop&crop=face&auto=format&q=80', true, 38.0, 91),
};

const _defaultProfile = _Profile('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=160&h=160&fit=crop&crop=face&auto=format&q=80', false, 36.5, 40);

// ── 자기소개(프로토타입 BIOS) ──
const _bios = <String, String>{
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

class FollowListScreen extends StatefulWidget {
  /// 프로토타입 navData: 목록 소유자 + 진입 탭.
  final String owner;
  final String tab; // followers | following
  const FollowListScreen({super.key, this.owner = '홍길동', this.tab = 'followers'});

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  late String _tab = widget.tab;
  final Set<String> _followSet = {};

  // NAMES = Object.keys(PROFILES) → followers slice(0,7) · following slice(2,9)
  static const _names = ['박지훈', '이영희', '김수진', '김회장', '이총무', '박소심', '장열심', '정디자', '이민준', '박회장'];
  List<String> get _followers => _names.sublist(0, 7);
  List<String> get _following => _names.sublist(2, 9);
  List<String> get _list => _tab == 'followers' ? _followers : _following;

  void _toggleFollow(String nm) => setState(() {
        if (_followSet.contains(nm)) {
          _followSet.remove(nm);
        } else {
          _followSet.add(nm);
        }
      });

  void _openProfile(String name) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PublicProfileScreen(name: name)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: widget.owner, onBack: () => Navigator.of(context).maybePop()),
        _segments(),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            children: [
              for (var i = 0; i < _list.length; i++) _row(_list[i], i < _list.length - 1),
            ],
          ),
        ),
      ]),
    );
  }

  // ── 세그먼트 탭 ──
  Widget _segments() => DecoratedBox(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: T.borderSubtle))),
        child: Row(children: [
          _segTab('followers', '팔로워 ${_followers.length}'),
          _segTab('following', '팔로잉 ${_following.length}'),
        ]),
      );

  Widget _segTab(String id, String label) {
    final on = _tab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = id),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: on ? T.primary : Colors.transparent, width: 2.5)),
          ),
          child: Text(label, style: tx(14, on ? FontWeight.w700 : FontWeight.w500, on ? T.primary : T.textMuted, height: 1)),
        ),
      ),
    );
  }

  // ── 프로필 행 ──
  Widget _row(String nm, bool divider) {
    final pr = _profiles[nm] ?? _defaultProfile;
    final gr = _getGrade(pr.score);
    final isFollowing = _followSet.contains(nm);
    final isMe = nm == widget.owner;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        border: divider ? const Border(bottom: BorderSide(color: T.borderSubtle)) : null,
      ),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _openProfile(nm),
            behavior: HitTestBehavior.opaque,
            child: Row(children: [
              SizedBox(
                width: 46,
                height: 46,
                child: Stack(clipBehavior: Clip.none, children: [
                  ClipOval(child: NetImage(url: pr.photo, width: 46, height: 46, fallback: MAvatar(name: nm, size: 46))),
                  if (pr.verified)
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(color: T.primary, shape: BoxShape.circle, border: Border.all(color: T.white, width: 2)),
                        child: const Icon(LucideIcons.check, size: 8, color: T.white),
                      ),
                    ),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(child: Text(nm, maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(14, FontWeight.w700, T.textTitle, height: 1.2))),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: T.gray100, borderRadius: BorderRadius.circular(T.rPill)),
                      child: Text('${gr.icon} ${gr.label}', style: tx(10, FontWeight.w700, gr.b, height: 1)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    _bios[nm] ?? '매너온도 ${pr.temp}℃',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tx(12, FontWeight.w500, T.textMuted, height: 1),
                  ),
                ]),
              ),
            ]),
          ),
        ),
        if (!isMe) ...[
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _toggleFollow(nm),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isFollowing ? T.white : T.primary,
                borderRadius: BorderRadius.circular(T.rPill),
                border: Border.all(color: isFollowing ? T.borderDefault : T.primary, width: 1.5),
              ),
              child: Text(isFollowing ? '팔로잉' : '팔로우', style: tx(12, FontWeight.w700, isFollowing ? T.textMuted : T.white, height: 1)),
            ),
          ),
        ],
      ]),
    );
  }
}
