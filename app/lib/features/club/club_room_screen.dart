// 동아리방(개별 동아리 홈) — prototype ClubRoomScreen (f566565a:108).
// 헤더(아바타·역할)·DEMO 직책 전환·필독 공지·확정 모임·신청 대기·운영진/부원 분기.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import 'club_detail_screen.dart';
import 'member_approval_screen.dart';
import 'club_finance_screen.dart';
import '../meeting/create_meeting_screen.dart';
import '../meeting/meeting_apply_screen.dart';
import '../meeting/funding_detail_screen.dart';

class _Event {
  final String title, date, place;
  final bool applied;
  final int costPerPerson, currentPeople, maxPeople;
  final String dday, deadline;
  const _Event(this.title, this.date, this.place, this.applied, this.costPerPerson,
      this.currentPeople, this.maxPeople, this.dday, this.deadline);
}

class ClubRoomScreen extends StatefulWidget {
  const ClubRoomScreen({super.key});

  @override
  State<ClubRoomScreen> createState() => _ClubRoomScreenState();
}

class _ClubRoomScreenState extends State<ClubRoomScreen> {
  // 시스템은 다중 직책을 유지하되, UI 권한은 [운영진 모드 / 부원 모드] 2그룹으로만 노출.
  // 회장·총무·운영진 → 동일한 '운영진 모드'. 총무만 💰 마크로 시각적 책임 부여.
  static const _roles = ['부원', '운영진', '총무', '회장'];
  static const _staff = ['운영진', '총무', '회장'];

  String _role = '부원';
  bool get _isStaff => _staff.contains(_role);
  bool get _isTreasurer => _role == '총무';

  static const _events = [
    _Event('정기 대관 연습 및 뒷풀이', '06/15 18:00', '홍대 스튜디오', false, 40000, 7, 10, 'D-6', 'D-5'),
    _Event('6월 신입 환영회', '06/28 19:00', '홍대 이자카야', true, 25000, 4, 15, 'D-19', 'D-14'),
  ];

  List<_Event> get _applied => _events.where((e) => e.applied).toList();
  List<_Event> get _pending => _events.where((e) => !e.applied).toList();

  void _toClubDetail() => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ClubDetailScreen()),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        _header(),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 16, T.padScreen, 24),
            children: [
              _roleSwitcher(),
              const SizedBox(height: 16),
              _notice(),
              const SizedBox(height: 20),
              if (_applied.isNotEmpty) ...[
                const SectionLabel('✅ 확정된 모임'),
                for (final ev in _applied) ...[_appliedCard(ev), const SizedBox(height: 12)],
                const SizedBox(height: 12),
              ],
              if (_pending.isNotEmpty) ...[
                const SectionLabel('📅 사전 펀딩 신청'),
                for (final ev in _pending) ...[_pendingCard(ev), const SizedBox(height: 12)],
                const SizedBox(height: 12),
              ],
              if (_isStaff) _staffMode() else _memberMode(),
            ],
          ),
        ),
      ]),
    );
  }

  // ── 헤더(커스텀: 아바타·동아리명·역할 배지·💰·정보) ──
  Widget _header() => Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: T.white,
          border: Border(bottom: BorderSide(color: T.borderSubtle)),
        ),
        child: Row(children: [
          Expanded(
            child: Row(children: [
              GestureDetector(
                onTap: _toClubDetail,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.only(right: 8, top: 2, bottom: 2),
                  child: Icon(LucideIcons.chevronLeft, size: 24, color: T.textStrong),
                ),
              ),
              const MAvatar(name: '사운드', square: true, tone: 'blue', size: 28),
              const SizedBox(width: 10),
              Flexible(
                child: Text("홍대 연합 밴드 '사운드'",
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: tx(16, FontWeight.w700, T.textStrong, height: 1)),
              ),
              const SizedBox(width: 8),
              MBadge(_isStaff ? '운영진' : '부원', tone: _isStaff ? 'blue' : 'neutral', variant: 'soft'),
              if (_isTreasurer) ...[
                const SizedBox(width: 6),
                const Text('💰', style: TextStyle(fontSize: 14, height: 1)),
              ],
            ]),
          ),
          const SizedBox(width: 8),
          MinTapTarget(
            const Icon(LucideIcons.info, size: 20, color: T.textMuted),
            onTap: _toClubDetail,
            min: 38,
          ),
        ]),
      );

  // ── DEMO 직책 전환 ──
  Widget _roleSwitcher() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: T.gray50,
          borderRadius: BorderRadius.circular(T.rLg),
          border: Border.all(color: T.borderDefault, style: BorderStyle.solid),
        ),
        child: Row(children: [
          Text('DEMO 직책', style: tx(10, FontWeight.w700, T.textDisabled, ls: 0.04, height: 1)),
          const SizedBox(width: 8),
          Expanded(
            child: Row(children: [
              for (var i = 0; i < _roles.length; i++) ...[
                Expanded(child: _roleTab(_roles[i])),
                if (i != _roles.length - 1) const SizedBox(width: 4),
              ],
            ]),
          ),
        ]),
      );

  Widget _roleTab(String r) {
    final on = _role == r;
    return GestureDetector(
      onTap: () => setState(() => _role = r),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? T.primary : T.white,
          borderRadius: BorderRadius.circular(T.rPill),
          border: on ? null : Border.all(color: T.borderDefault),
        ),
        child: Text('${r == '총무' ? '💰' : ''}$r',
            style: tx(11, on ? FontWeight.w700 : FontWeight.w500, on ? T.white : T.textMuted, height: 1)),
      ),
    );
  }

  // ── 필독 공지 ──
  Widget _notice() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(T.rLg)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(LucideIcons.megaphone, size: 18, color: T.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('필독 공지', style: tx(11, FontWeight.w700, T.primary, height: 1)),
              const SizedBox(height: 4),
              Text('이번 주 토요일 홍대 6시 정기 공연 대관 안내',
                  style: tx(13, FontWeight.w500, T.textBody, height: 1.4)),
            ]),
          ),
        ]),
      );

  // ── 확정된 모임(신청 완료) ──
  Widget _appliedCard(_Event ev) => MCard(
        elevation: 'raised',
        radius: T.rXl,
        padding: EdgeInsets.zero,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FundingDetailScreen()),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            decoration: const BoxDecoration(gradient: T.gradBrand),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('참석 확정',
                      style: tx(9, FontWeight.w700, Colors.white.withValues(alpha: 0.75), ls: 0.08, height: 1)),
                  const SizedBox(height: 5),
                  Text(ev.title, style: tx(15, FontWeight.w700, T.white, height: 1.2)),
                ]),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(T.rMd),
                ),
                child: Text(ev.dday, style: tx(14, FontWeight.w700, T.white, height: 1, tab: true)),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _iconLine(LucideIcons.calendar, ev.date, T.primary, T.textBody, FontWeight.w600, 13),
                const SizedBox(width: 16),
                _iconLine(LucideIcons.mapPin, ev.place, T.primary, T.textBody, FontWeight.w600, 13),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(LucideIcons.users, size: 13, color: T.textMuted),
                const SizedBox(width: 6),
                Text('현재 ${ev.currentPeople}명 참석 예정 · 최대 ${ev.maxPeople}명',
                    style: tx(12, FontWeight.w500, T.textMuted, height: 1, tab: true)),
              ]),
            ]),
          ),
        ]),
      );

  Widget _iconLine(IconData icon, String text, Color iconColor, Color textColor, FontWeight w, double size) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 6),
        Text(text, style: tx(size, w, textColor, height: 1)),
      ]);

  // ── 신청 대기 모임 ──
  Widget _pendingCard(_Event ev) {
    final d = ddayInfo(ev.dday);
    return MCard(
      elevation: 'raised',
      radius: T.rXl,
      padding: const EdgeInsets.all(18),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MeetingApplyScreen()),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ev.title, style: tx(15, FontWeight.w700, T.textTitle, height: 1.2)),
              const SizedBox(height: 4),
              Text('${ev.date} · ${ev.place}', style: tx(12, FontWeight.w500, T.textMuted, height: 1.3)),
            ]),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(color: d.bg, borderRadius: BorderRadius.circular(T.rPill)),
            child: Text(d.label, style: tx(12, FontWeight.w700, d.color, height: 1, tab: true)),
          ),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: T.borderSubtle))),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                const Icon(LucideIcons.wallet, size: 13, color: T.primary),
                const SizedBox(width: 6),
                Text('${won(ev.costPerPerson)}원/인', style: tx(13, FontWeight.w700, T.primary, height: 1, tab: true)),
              ]),
              Row(children: [
                const Icon(LucideIcons.users, size: 13, color: T.textMuted),
                const SizedBox(width: 5),
                Text('${ev.currentPeople}/${ev.maxPeople}명',
                    style: tx(12, FontWeight.w600, T.textMuted, height: 1, tab: true)),
              ]),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const MBadge('미신청', tone: 'neutral', variant: 'dot'),
              Text('신청 마감 ${ev.deadline}', style: tx(12, FontWeight.w500, T.danger, height: 1)),
            ]),
          ]),
        ),
      ]),
    );
  }

  // ── 운영진 모드 ──
  Widget _staffMode() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            const Icon(LucideIcons.wrench, size: 14, color: T.primary),
            const SizedBox(width: 6),
            Text('운영진 모드', style: tx(13, FontWeight.w700, T.textTitle, height: 1)),
            const SizedBox(width: 6),
            Text('모임 개설 · 장부 관리', style: tx(11, FontWeight.w500, T.textDisabled, height: 1)),
          ]),
        ),
        Row(children: [
          Expanded(child: _dashedAction(LucideIcons.plus, '모임 생성', () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateMeetingScreen()),
              ))),
          const SizedBox(width: 10),
          Expanded(child: _dashedAction(LucideIcons.users, '가입 관리', () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MemberApprovalScreen()),
              ))),
        ]),
        const SizedBox(height: 10),
        _dashedAction(LucideIcons.wallet, '장부 · 재정 관리', () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ClubFinanceScreen()),
            )),
        if (_isTreasurer) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: T.warningSoft, // proto #FEF9C3
              borderRadius: BorderRadius.circular(T.rLg),
              border: Border.all(color: T.amber100), // proto #FDE68A
            ),
            child: Row(children: [
              const Text('💰', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: tx(12, FontWeight.w600, T.amber600, height: 1.4), // proto #92400E
                    children: const [
                      TextSpan(text: '이 동아리의 '),
                      TextSpan(text: '총무', style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: '입니다. 장부 투명성을 책임져요.'),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ],
      ]);

  Widget _dashedAction(IconData icon, String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: T.white,
            borderRadius: BorderRadius.circular(T.rMd),
            border: Border.all(color: T.borderDefault, width: 1.5),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 16, color: T.textMuted),
            const SizedBox(width: 6),
            Text(label, style: tx(13, FontWeight.w600, T.textMuted, height: 1)),
          ]),
        ),
      );

  // ── 부원 모드 ──
  Widget _memberMode() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionLabel('내 활동'),
        GestureDetector(
          onTap: () => MoishoToast.show(context, '준비 중', tone: 'info'),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: T.white,
              borderRadius: BorderRadius.circular(T.rMd),
              border: Border.all(color: T.borderSubtle, width: 1.5),
            ),
            child: Row(children: [
              const Icon(LucideIcons.wallet, size: 16, color: T.primary),
              const SizedBox(width: 8),
              Expanded(child: Text('장부 열람 · 내 정산 내역', style: tx(13, FontWeight.w600, T.textBody, height: 1))),
              const Icon(LucideIcons.chevronRight, size: 16, color: T.textDisabled),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => MoishoToast.show(context, '동아리 나가기는 운영진 승인이 필요해요.', tone: 'info'),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 44,
            alignment: Alignment.center,
            child: Text('동아리 나가기', style: tx(13, FontWeight.w500, T.textDisabled, height: 1)),
          ),
        ),
      ]);
}
