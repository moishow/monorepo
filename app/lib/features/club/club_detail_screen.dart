// 동아리 상세 — prototype ClubDetailScreen (850b0de8:396).
// 배너·탭(소개/멤버/채팅/재정)·회원/비회원 뷰 토글·잠금 미리보기·동아리 채팅.
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import '../social/public_profile_screen.dart';
import 'club_room_screen.dart';
import 'club_join_apply_screen.dart';

// ── 멤버 사진 (프로토타입 MEMBER_PHOTOS) ──
const Map<String, String> _memberPhotos = {
  '김회장': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop&crop=face&auto=format&q=80',
  '이총무': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop&crop=face&auto=format&q=80',
  '박소심': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop&crop=face&auto=format&q=80',
  '장열심': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face&auto=format&q=80',
  '정디자': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face&auto=format&q=80',
  '최부원': 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=100&h=100&fit=crop&crop=face&auto=format&q=80',
  '오빠름': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop&crop=face&auto=format&q=80',
  '정건망': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop&crop=face&auto=format&q=80',
  '한노쇼': 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=100&h=100&fit=crop&crop=face&auto=format&q=80',
  '이땡땡': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=100&h=100&fit=crop&crop=face&auto=format&q=80',
  '나': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face&auto=format&q=80',
};

class _Member {
  final String name, role, roleTone, joined, tone;
  final List<String> tags;
  final bool active;
  const _Member(this.name, this.role, this.roleTone, this.joined, this.tone, this.tags, this.active);
}

class _Msg {
  final int id;
  final String author, tone, role, time, text;
  final bool mine;
  const _Msg(this.id, this.author, this.tone, this.role, this.time, this.text, this.mine);
}

const List<_Member> _members = [
  _Member('김회장', '회장', 'blue', '2023.03', 'blue', ['밴드', '기타'], true),
  _Member('이총무', '총무', 'purple', '2023.03', 'mint', ['밴드', '베이스'], true),
  _Member('박소심', '부원', 'neutral', '2024.09', 'coral', ['밴드', '보컬'], true),
  _Member('최부원', '부원', 'neutral', '2024.09', 'gray', ['드럼'], true),
  _Member('정디자', '부원', 'neutral', '2024.03', 'purple', ['기타', '작곡'], false),
  _Member('장열심', '부원', 'neutral', '2023.09', 'gray', ['드럼', '퍼커션'], true),
  _Member('오빠름', '부원', 'neutral', '2025.03', 'blue', ['베이스'], true),
  _Member('정건망', '부원', 'neutral', '2025.03', 'coral', ['키보드'], false),
  _Member('한노쇼', '부원', 'neutral', '2024.09', 'mint', ['보컬', '기타'], true),
  _Member('이땡땡', '신입', 'neutral', '2026.03', 'purple', ['드럼'], true),
];

class ClubDetailScreen extends StatefulWidget {
  const ClubDetailScreen({super.key});

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  String _activeTab = '소개';
  bool _isMember = false;
  final TextEditingController _chatCtrl = TextEditingController();

  final List<_Msg> _messages = [
    const _Msg(1, '김회장', 'blue', '회장', '오전 10:12', '이번 주 토요일 합주 장소가 변경됐어요! 홍대 사운드스튜디오 2호점으로 오세요 🎸', false),
    const _Msg(2, '이총무', 'mint', '총무', '오전 10:14', '확인했어요! 이번 합주 참석 신청은 오늘 밤까지 받을게요 😊', false),
    const _Msg(3, '박소심', 'coral', '부원', '오전 10:18', '저 이번에 베이스 새로 샀어요!! 같이 맞춰봐요ㅋㅋ', false),
    const _Msg(4, '나', 'blue', '부원', '오전 10:21', '저도 갈게요! 장비 챙겨갑니다', true),
    const _Msg(5, '장열심', 'gray', '부원', '오전 10:25', '드럼 세팅은 제가 미리 가서 해놓을게요 👍', false),
    const _Msg(6, '김회장', 'blue', '회장', '오전 10:30', '다들 고마워요! 이번에 제대로 맞춰봐요 💪', false),
  ];

  static const _tabs = ['소개', '멤버', '채팅', '재정'];

  @override
  void initState() {
    super.initState();
    _chatCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _chatCtrl.dispose();
    super.dispose();
  }

  void _openProfile(String name) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => PublicProfileScreen(name: name)));

  void _toClubRoom() =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ClubRoomScreen()));

  void _toJoinApply() =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ClubJoinApplyScreen()));

  void _sendChat() {
    final text = _chatCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(DateTime.now().millisecondsSinceEpoch, '나', 'blue', '부원', '방금', text, true));
      _chatCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(
          title: '동아리 상세',
          onBack: () => Navigator.of(context).maybePop(),
          actions: [
            MinTapTarget(
              const Icon(LucideIcons.share2, size: 20, color: T.textMuted),
              onTap: () => MoishoToast.show(context, '링크가 복사됐어요!', tone: 'info'),
              min: 38,
            ),
          ],
        ),
        _banner(),
        _tabBar(),
        Expanded(child: _tabBody()),
      ]),
    );
  }

  // ── 헤더 배너 ──
  Widget _banner() => SizedBox(
        height: 130,
        child: Stack(children: [
          // 그라데이션 배경 — proto #1D4ED8 → #7C3AED (그라데이션 스톱: raw 허용)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1D4ED8), Color(0xFF7C3AED)],
              ),
            ),
            child: SizedBox.expand(),
          ),
          // 데모 회원 토글
          Positioned(
            top: 10,
            right: 14,
            child: GestureDetector(
              onTap: () => setState(() => _isMember = !_isMember),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(T.rPill),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_isMember ? LucideIcons.userCheck : LucideIcons.user, size: 13, color: T.white),
                  const SizedBox(width: 5),
                  Text(_isMember ? '회원 뷰' : '비회원 뷰', style: tx(10, FontWeight.w700, T.white, height: 1)),
                ]),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(T.rLg),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(T.rLg - 2),
                  child: const NetImage(
                    url: 'https://images.unsplash.com/photo-1501612780327-45045538702b?w=80&h=80&fit=crop&auto=format&q=80',
                    width: 56,
                    height: 56,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text("홍대 연합 밴드 '사운드'", style: tx(17, FontWeight.w700, T.white, ls: -0.01, height: 1.2)),
                  const SizedBox(height: 5),
                  Row(children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(LucideIcons.users, size: 13, color: Colors.white.withValues(alpha: 0.8)),
                      const SizedBox(width: 4),
                      Text('28명', style: tx(12, FontWeight.w600, Colors.white.withValues(alpha: 0.9), height: 1)),
                    ]),
                    const SizedBox(width: 10),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(LucideIcons.calendar, size: 13, color: Colors.white.withValues(alpha: 0.8)),
                      const SizedBox(width: 4),
                      Text('2024년 개설', style: tx(12, FontWeight.w600, Colors.white.withValues(alpha: 0.9), height: 1)),
                    ]),
                    const SizedBox(width: 10),
                    const MBadge('모집 중', tone: 'success', variant: 'soft'),
                  ]),
                ]),
              ),
            ]),
          ),
        ]),
      );

  // ── 탭바 ──
  Widget _tabBar() => DecoratedBox(
        decoration: const BoxDecoration(
          color: T.white,
          border: Border(bottom: BorderSide(color: T.borderSubtle)),
        ),
        child: Row(
          children: [
            for (final t in _tabs)
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeTab = t),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _activeTab == t ? T.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: (t == '채팅' && _isMember)
                        ? Row(mainAxisSize: MainAxisSize.min, children: [
                            Text('채팅', style: tx(13, _activeTab == t ? FontWeight.w700 : FontWeight.w500, _activeTab == t ? T.primary : T.textMuted, height: 1)),
                            const SizedBox(width: 4),
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: T.danger, shape: BoxShape.circle)),
                          ])
                        : Text(t, style: tx(13, _activeTab == t ? FontWeight.w700 : FontWeight.w500, _activeTab == t ? T.primary : T.textMuted, height: 1)),
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _tabBody() {
    switch (_activeTab) {
      case '멤버':
        return _membersTab();
      case '채팅':
        return _chatTab();
      case '재정':
        return _financeTab();
      default:
        return _aboutTab();
    }
  }

  // ── 소개 탭 ──
  Widget _aboutTab() {
    const stats = [
      ('정기 모임', '매주 토요일', LucideIcons.calendar),
      ('합주실', '홍대 사운드스튜디오', LucideIcons.mapPin),
      ('회비', '월 20,000원', LucideIcons.coins),
    ];
    const activities = [
      ('5월 정기 공연 현장', 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=400&h=100&fit=crop&auto=format&q=80'),
      ('4월 엠티 후기', 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=400&h=100&fit=crop&auto=format&q=80'),
      ('신입 환영회', 'https://images.unsplash.com/photo-1540317580384-e5d43616b9aa?w=400&h=100&fit=crop&auto=format&q=80'),
    ];
    return Column(children: [
      Expanded(
        child: ScrollBody(
          padding: const EdgeInsets.fromLTRB(T.padScreen, 20, T.padScreen, 24),
          children: [
            Text(
              '홍대 인근에서 활동하는 서울 연합 밴드. 매주 토요일 합주 후 뒷풀이까지! 보컬·기타·베이스·드럼 모집 중.',
              style: tx(14, FontWeight.w500, T.textBody, height: 1.6),
            ),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final t in ['밴드', '친목', '공연', '홍대']) MTag(t, tone: 'blue', leadingHash: true),
            ]),
            const SizedBox(height: 20),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (var i = 0; i < stats.length; i++) ...[
                Expanded(child: _statTile(stats[i].$1, stats[i].$2, stats[i].$3)),
                if (i < stats.length - 1) const SizedBox(width: 10),
              ],
            ]),
            const SizedBox(height: 20),
            if (_isMember) ...[_memberShortcut(), const SizedBox(height: 20)],
            const SectionLabel('최근 활동'),
            for (var i = 0; i < activities.length; i++) ...[
              _activityCard(activities[i].$1, activities[i].$2),
              if (i < activities.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
      if (!_isMember)
        StickyBar(
          child: MButton('가입 신청서 제출하기', variant: 'primary', size: 'lg', block: true, onTap: _toJoinApply),
        ),
    ]);
  }

  Widget _statTile(String label, String value, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(color: T.gray50, borderRadius: BorderRadius.circular(T.rLg)),
        child: Column(children: [
          Icon(icon, size: 18, color: T.primary),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: tx(10, FontWeight.w500, T.textMuted, height: 1)),
          const SizedBox(height: 6),
          Text(value, textAlign: TextAlign.center, style: tx(12, FontWeight.w700, T.textStrong, height: 1.2)),
        ]),
      );

  Widget _memberShortcut() => GestureDetector(
        onTap: _toClubRoom,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(T.rXl),
            gradient: const LinearGradient(
              begin: Alignment(-0.9, -0.4),
              end: Alignment(0.9, 0.4),
              colors: [T.primary, T.accent],
            ),
            boxShadow: T.shadowMd,
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text('모임 & 펀딩 신청', style: tx(15, FontWeight.w700, T.white, height: 1.2)),
                const SizedBox(height: 4),
                Text('다가오는 모임 2개 · 신청 대기 1개', style: tx(12, FontWeight.w500, Colors.white.withValues(alpha: 0.8), height: 1)),
              ]),
            ),
            const SizedBox(width: 8),
            const MBadge('D-5', tone: 'danger', variant: 'soft'),
            const SizedBox(width: 6),
            const Icon(LucideIcons.chevronRight, size: 20, color: T.white),
          ]),
        ),
      );

  Widget _activityCard(String title, String img) => MCard(
        elevation: 'outline',
        radius: T.rXl,
        padding: const EdgeInsets.all(14),
        onTap: () => MoishoToast.show(context, '준비 중', tone: 'info'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(T.rLg),
            child: NetImage(url: img, width: double.infinity, height: 80, fallback: Container(height: 80, color: T.gray100)),
          ),
          const SizedBox(height: 8),
          Text(title, style: tx(13, FontWeight.w600, T.textBody, height: 1.3)),
        ]),
      );

  // ── 멤버 탭 ──
  Widget _membersTab() {
    if (!_isMember) {
      return _lockView(
        title: '회원 전용 정보예요',
        desc: '부원 목록은 같은 동아리 회원에게만 공개돼요.',
        preview: true,
        ctaLabel: '가입하고 부원 목록 보기',
      );
    }
    final activeCount = _members.where((m) => m.active).length;
    return ScrollBody(
      padding: const EdgeInsets.fromLTRB(T.padScreen, 16, T.padScreen, 24),
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const SectionLabel('전체 부원 (28명)'),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 7, height: 7, decoration: const BoxDecoration(color: T.success, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text('활동 중 $activeCount', style: tx(11, FontWeight.w500, T.textMuted, height: 1)),
          ]),
        ]),
        const SizedBox(height: 4),
        for (var i = 0; i < _members.length; i++) ...[
          _memberCard(_members[i]),
          if (i < _members.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _memberCard(_Member m) => MCard(
        elevation: 'raised',
        radius: T.rXl,
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          GestureDetector(
            onTap: () => _openProfile(m.name),
            behavior: HitTestBehavior.opaque,
            child: MAvatar(
              name: m.name,
              src: _memberPhotos[m.name],
              size: 42,
              tone: m.tone,
              status: m.active ? 'success' : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Text(m.name, style: tx(14, FontWeight.w700, T.textStrong, height: 1)),
                const SizedBox(width: 6),
                MBadge(m.role, tone: m.roleTone == 'neutral' ? 'neutral' : m.roleTone, variant: 'soft'),
              ]),
              const SizedBox(height: 4),
              Wrap(spacing: 5, runSpacing: 5, crossAxisAlignment: WrapCrossAlignment.center, children: [
                for (final t in m.tags) MTag(t, tone: 'blue', leadingHash: true),
                Text('가입 ${m.joined}', style: tx(11, FontWeight.w500, T.textDisabled, height: 1)),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => MoishoToast.show(context, '준비 중', tone: 'info'),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: T.primarySoft, shape: BoxShape.circle),
              child: const Icon(LucideIcons.messageCircle, size: 16, color: T.primary),
            ),
          ),
        ]),
      );

  // ── 채팅 탭 ──
  Widget _chatTab() {
    if (!_isMember) {
      return _lockView(
        title: '회원 전용 채팅방이에요',
        desc: '가입 후 동아리 채팅방에 참여할 수 있어요.',
        preview: false,
        ctaLabel: '가입하고 채팅 참여하기',
      );
    }
    return Column(children: [
      // 채팅 헤더
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          color: T.white,
          border: Border(bottom: BorderSide(color: T.borderSubtle)),
        ),
        child: Row(children: [
          SizedBox(
            width: 24.0 + 16 * 3,
            height: 24,
            child: Stack(children: [
              for (var i = 0; i < 4; i++)
                Positioned(
                  left: i * 16.0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: T.white, width: 2)),
                    child: ClipOval(child: MAvatar(name: _members[i].name, src: _memberPhotos[_members[i].name], size: 20, tone: _members[i].tone)),
                  ),
                ),
            ]),
          ),
          const SizedBox(width: 8),
          Text('부원 28명', style: tx(12, FontWeight.w600, T.textMuted, height: 1)),
          const Spacer(),
          GestureDetector(
            onTap: () => MoishoToast.show(context, '알림이 설정됐어요.', tone: 'info'),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(LucideIcons.bell, size: 18, color: T.textMuted),
            ),
          ),
        ]),
      ),
      // 메시지 목록
      Expanded(
        child: Container(
          color: T.surfacePage,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            physics: const BouncingScrollPhysics(),
            itemCount: _messages.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (_, i) => _messageRow(_messages[i]),
          ),
        ),
      ),
      // 채팅 입력
      Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: const BoxDecoration(
          color: T.white,
          border: Border(top: BorderSide(color: T.borderSubtle)),
        ),
        child: SafeArea(
          top: false,
          child: Row(children: [
            GestureDetector(
              onTap: () => MoishoToast.show(context, '파일 첨부 기능', tone: 'info'),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(LucideIcons.paperclip, size: 20, color: T.textMuted),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 40),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: T.gray50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: T.borderSubtle, width: 1.5),
                ),
                child: TextField(
                  controller: _chatCtrl,
                  onSubmitted: (_) => _sendChat(),
                  textInputAction: TextInputAction.send,
                  style: tx(14, FontWeight.w500, T.textBody, height: 1.2),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: '메시지 입력...',
                    hintStyle: tx(14, FontWeight.w500, T.textDisabled, height: 1.2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _sendChat,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _chatCtrl.text.trim().isNotEmpty ? T.primary : T.gray100,
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.send, size: 17, color: _chatCtrl.text.trim().isNotEmpty ? T.white : T.textDisabled),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }

  Widget _messageRow(_Msg msg) {
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: msg.mine ? T.primary : T.white,
        borderRadius: msg.mine
            ? const BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomLeft: Radius.circular(18), bottomRight: Radius.circular(4))
            : const BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomLeft: Radius.circular(4), bottomRight: Radius.circular(18)),
        border: msg.mine ? null : Border.all(color: T.borderSubtle),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Text(msg.text, style: tx(13, FontWeight.w500, msg.mine ? T.white : T.textBody, height: 1.5)),
    );
    final column = Column(
      crossAxisAlignment: msg.mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!msg.mine) ...[
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 3),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(msg.author, style: tx(11, FontWeight.w700, T.textMuted, height: 1)),
              const SizedBox(width: 5),
              MBadge(msg.role, tone: msg.role == '회장' ? 'blue' : msg.role == '총무' ? 'purple' : 'neutral', variant: 'soft'),
            ]),
          ),
        ],
        bubble,
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Text(msg.time, style: tx(10, FontWeight.w500, T.textDisabled, height: 1)),
        ),
      ],
    );
    final children = <Widget>[
      if (!msg.mine) ...[
        MAvatar(name: msg.author, src: _memberPhotos[msg.author], size: 32, tone: msg.tone),
        const SizedBox(width: 8),
      ],
      Flexible(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.72),
          child: column,
        ),
      ),
    ];
    return Row(
      mainAxisAlignment: msg.mine ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: children,
    );
  }

  // ── 재정 탭 ──
  Widget _financeTab() {
    const trustRows = [
      ('평균 예산 오차율', '4.2%', '매우 투명', 'success'),
      ('펀딩 환불 완료율', '100%', '완벽', 'success'),
      ('평균 정산 소요일', '0.8일', '당일 완료', 'blue'),
    ];
    const settlements = [
      ('06/15 정기 대관 연습', '360,000원', '완료'),
      ('05/20 봄 MT', '820,000원', '완료'),
      ('04/12 신입 환영회', '145,000원', '완료'),
    ];
    return ScrollBody(
      padding: const EdgeInsets.fromLTRB(T.padScreen, 16, T.padScreen, 24),
      children: [
        MCard(
          elevation: 'raised',
          radius: T.rXl,
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(LucideIcons.shieldCheck, size: 18, color: T.primary),
              const SizedBox(width: 8),
              Text('모이쇼 재정 신뢰 등급', style: tx(14, FontWeight.w700, T.textTitle, height: 1)),
              const SizedBox(width: 8),
              const MBadge('우수', tone: 'success', variant: 'soft'),
            ]),
            const SizedBox(height: 14),
            for (final r in trustRows)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: T.borderSubtle))),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(r.$1, style: tx(13, FontWeight.w500, T.textBody, height: 1)),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(r.$2, style: tx(15, FontWeight.w700, T.textStrong, height: 1, tab: true)),
                    const SizedBox(width: 8),
                    MBadge(r.$3, tone: r.$4, variant: 'soft'),
                  ]),
                ]),
              ),
          ]),
        ),
        const SizedBox(height: 14),
        const SectionLabel('최근 정산 내역'),
        for (var i = 0; i < settlements.length; i++) ...[
          _settlementCard(settlements[i].$1, settlements[i].$2, settlements[i].$3),
          if (i < settlements.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _settlementCard(String title, String value, String status) => MCard(
        elevation: 'outline',
        radius: T.rXl,
        padding: const EdgeInsets.all(14),
        onTap: () => MoishoToast.show(context, '준비 중', tone: 'info'),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(title, style: tx(13, FontWeight.w600, T.textTitle, height: 1.2)),
            const SizedBox(height: 4),
            MBadge(status, tone: 'success', variant: 'soft'),
          ]),
          Text(value, style: tx(16, FontWeight.w700, T.textStrong, height: 1, tab: true)),
        ]),
      );

  // ── 비회원 잠금 뷰 (멤버/채팅 공용) ──
  Widget _lockView({
    required String title,
    required String desc,
    required bool preview,
    required String ctaLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: T.gray50, shape: BoxShape.circle),
              child: const Icon(LucideIcons.lock, size: 30, color: T.textDisabled),
            ),
          ),
          const SizedBox(height: 14),
          Text(title, textAlign: TextAlign.center, style: tx(16, FontWeight.w700, T.textTitle, height: 1.3)),
          const SizedBox(height: 8),
          Text(desc, textAlign: TextAlign.center, style: tx(14, FontWeight.w500, T.textMuted, height: 1.5)),
          if (preview) ...[
            const SizedBox(height: 14),
            _blurPreview(),
          ],
          const SizedBox(height: 14),
          MButton(ctaLabel, variant: 'primary', size: 'md', block: true, onTap: _toClubRoom),
        ],
      ),
    );
  }

  Widget _blurPreview() => ClipRRect(
        borderRadius: BorderRadius.circular(T.rXl),
        child: Stack(children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Column(children: [
              for (var i = 0; i < 3; i++) ...[
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: T.white,
                    borderRadius: BorderRadius.circular(T.rXl),
                    border: Border.all(color: T.borderSubtle),
                  ),
                  child: Row(children: [
                    Container(width: 40, height: 40, decoration: const BoxDecoration(color: T.gray100, shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                        Container(height: 12, width: 80, decoration: BoxDecoration(color: T.gray200, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 6),
                        Container(height: 10, width: 120, decoration: BoxDecoration(color: T.gray100, borderRadius: BorderRadius.circular(4))),
                      ]),
                    ),
                  ]),
                ),
                if (i < 2) const SizedBox(height: 8),
              ],
            ]),
          ),
          Positioned.fill(child: ColoredBox(color: Colors.white.withValues(alpha: 0.3))),
        ]),
      );
}
