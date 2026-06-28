// 동아리 홈(가입 멤버) — prototype ClubHomeScreen (f566565a:22).
// 내 동아리 목록(썸네일 카드: 카테고리·알림뱃지·동아리명 오버레이 + 역할/인원/다음모임) + 동아리 찾기 CTA.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../chat/dm_list_screen.dart';
import '../discover/discover_screen.dart';
import '../social/notifications_screen.dart';
import 'club_detail_screen.dart';
import 'create_club_screen.dart';

class _Club {
  final String name, category, role, roleTone, tone, nextMeeting;
  final int members, upcoming, unread;
  const _Club(this.name, this.category, this.role, this.roleTone, this.members, this.tone, this.nextMeeting, this.upcoming, this.unread);
}

class ClubHomeScreen extends StatelessWidget {
  const ClubHomeScreen({super.key});

  // ── 내 동아리 데이터(프로토타입 clubs 리터럴) ──
  static const _clubs = [
    _Club("홍대 연합 밴드 '사운드'", '밴드', '회장', 'blue', 28, 'blue', '06/15 18:00 · 홍대 사운드스튜디오', 2, 5),
    _Club("서울 사진 동아리 '프레임'", '사진', '회원', 'neutral', 18, 'mint', '06/22 14:00 · 한강공원 출사', 1, 0),
    _Club("서울 독서 모임 '페이지'", '독서', '총무', 'purple', 12, 'purple', '예정된 모임 없음', 0, 2),
  ];

  static const _clubImgs = {
    'blue': 'https://images.unsplash.com/photo-1501612780327-45045538702b?w=480&h=180&fit=crop&auto=format&q=80',
    'mint': 'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=480&h=180&fit=crop&auto=format&q=80',
    'purple': 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=480&h=180&fit=crop&auto=format&q=80',
  };

  void _push(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        // ── 헤더 (탭 홈: 타이틀 + 우측 액션) ──
        Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          decoration: const BoxDecoration(
            color: T.white,
            border: Border(bottom: BorderSide(color: T.borderSubtle)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('내 동아리', style: tx(18, FontWeight.w700, T.textStrong, ls: -0.01, height: 1)),
              Row(children: [
                MinTapTarget(
                  const Icon(LucideIcons.plusCircle, size: 22, color: T.primary),
                  onTap: () => _push(context, const CreateClubScreen()),
                  min: 38,
                ),
                const SizedBox(width: 6),
                MinTapTarget(
                  const Icon(LucideIcons.bell, size: 22, color: T.textMuted),
                  onTap: () => _push(context, const NotificationsScreen()),
                  min: 38,
                ),
                const SizedBox(width: 6),
                MinTapTarget(
                  const Icon(LucideIcons.messageCircle, size: 22, color: T.textMuted),
                  onTap: () => _push(context, const DmListScreen()),
                  min: 38,
                ),
              ]),
            ],
          ),
        ),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              for (final c in _clubs) ...[
                _clubCard(context, c),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 2),
              _discoverButton(context),
            ],
          ),
        ),
      ]),
    );
  }

  // ── 동아리 썸네일 카드 ──
  Widget _clubCard(BuildContext context, _Club c) {
    final hasUpcoming = c.upcoming > 0;
    return GestureDetector(
      onTap: () => _push(context, const ClubDetailScreen()),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: T.white,
          borderRadius: BorderRadius.circular(T.rXl),
          boxShadow: T.shadowMd,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(T.rXl),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // 썸네일
            SizedBox(
              height: 160,
              child: Stack(fit: StackFit.expand, children: [
                NetImage(url: _clubImgs[c.tone], fit: BoxFit.cover, fallback: Container(color: T.gray100)),
                // 대각 음영
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0x38000000), Color(0x0D000000)],
                    ),
                  ),
                ),
                // 동아리명 오버레이 그라데이션
                const Positioned(
                  left: 0, right: 0, bottom: 0,
                  child: SizedBox(
                    height: 80,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter, end: Alignment.topCenter,
                          colors: [Color(0xAD000000), Color(0x00000000)],
                        ),
                      ),
                    ),
                  ),
                ),
                // 카테고리 태그 (글래스)
                Positioned(
                  top: 12, left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(T.rPill),
                    ),
                    child: Text(c.category, style: tx(11, FontWeight.w700, T.white, height: 1)),
                  ),
                ),
                // 알림 뱃지
                if (c.unread > 0)
                  Positioned(
                    top: 12, right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: T.danger, borderRadius: BorderRadius.circular(T.rPill)),
                      child: Text('새 알림 ${c.unread}', style: tx(11, FontWeight.w700, T.white, height: 1)),
                    ),
                  ),
                // 동아리명
                Positioned(
                  left: 18, right: 18, bottom: 14,
                  child: Text(
                    c.name,
                    style: tx(17, FontWeight.w700, T.white, ls: -0.01, height: 1.2),
                  ),
                ),
              ]),
            ),
            // 하단 정보
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  MBadge(c.role, tone: c.roleTone, variant: 'soft'),
                  Text('${c.members}명', style: tx(12, FontWeight.w500, T.textDisabled, height: 1, tab: true)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Icon(LucideIcons.calendar, size: 13, color: hasUpcoming ? T.primary : T.textDisabled),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      hasUpcoming ? c.nextMeeting : '예정된 모임 없음',
                      style: tx(13, hasUpcoming ? FontWeight.w600 : FontWeight.w500, hasUpcoming ? T.textBody : T.textDisabled, height: 1.3),
                    ),
                  ),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ── 동아리 찾기 ──
  Widget _discoverButton(BuildContext context) => GestureDetector(
        onTap: () => _push(context, const DiscoverScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: T.white,
            borderRadius: BorderRadius.circular(T.rLg),
            border: Border.all(color: T.borderDefault, width: 1.5, style: BorderStyle.solid),
          ),
          alignment: Alignment.center,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(LucideIcons.search, size: 17, color: T.textMuted),
            const SizedBox(width: 8),
            Text('새로운 동아리 찾아보기', style: tx(14, FontWeight.w600, T.textMuted, height: 1)),
          ]),
        ),
      );
}
