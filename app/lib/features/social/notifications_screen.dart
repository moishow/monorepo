// 알림 — prototype NotificationsScreen (87338638:8).
// 참석 예정 모임(D-day 타일) + 알림 목록(읽음/안읽음, 탭 시 이동·읽음 처리).
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import '../club/member_approval_screen.dart';
import '../home/post_detail_screen.dart';
import '../meeting/funding_detail_screen.dart';
import '../settlement/settle_auto_screen.dart';
import '../treasurer/payout_consent_screen.dart';

class _Notif {
  final int id;
  final IconData icon;
  final Color tone;
  bool unread;
  final String time, title, body;
  final String? action;
  _Notif(this.id, this.icon, this.tone, this.unread, this.time, this.title, this.body, this.action);
}

class _Upcoming {
  final String title, club, date;
  final int dday;
  final Color color;
  const _Upcoming(this.title, this.club, this.date, this.dday, this.color);
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_Notif> _items = [
    _Notif(0, LucideIcons.shieldQuestion, T.primary, true, '방금 전', '총무 출금 동의 요청',
        '정기 합주 & 뒷풀이 — 총무가 480,000원 출금에 동의를 요청했어요. 전원 동의 시 출금돼요.', 'payoutConsent'),
    _Notif(1, LucideIcons.handCoins, T.primary, true, '방금 전', '펀딩 마감 임박!',
        '정기 대관 연습 펀딩이 23시간 후 마감돼요.', 'fundingDetail'),
    _Notif(2, LucideIcons.checkCircle, T.success, true, '1시간 전', '입금 확인 완료!',
        '박소심님이 40,000원을 입금했어요. 자동 매칭 완료.', null),
    _Notif(3, LucideIcons.sparkles, T.accent, false, '2시간 전', '새 쇼 게시글',
        "정디자님이 '봄MT 현장'을 올렸어요. 좋아요 24개 🔥", 'postDetail'),
    _Notif(4, LucideIcons.userPlus, T.primary, false, '어제', '신입 가입 신청',
        '이땡땡(22)님이 가입 신청서를 제출했어요.', 'memberApproval'),
    _Notif(5, LucideIcons.piggyBank, T.success, false, '3일 전', '정산 완료 — 잔액 적립',
        '정기 대관 연습 정산 완료! +4,000원이 적립됐어요.', 'settleAuto'),
  ];

  static const _upcoming = [
    _Upcoming('정기 대관 연습', "홍대 연합 밴드 '사운드'", '6.15', 4, T.primary),
    _Upcoming('정기 공연 준비', "홍대 연합 밴드 '사운드'", '6.22', 11, T.primary),
    _Upcoming('출사 품평회', '필름 사진 동호회', '6.28', 17, T.accent),
  ];

  int get _unreadCount => _items.where((i) => i.unread).length;

  void _readAll() => setState(() {
        for (final i in _items) {
          i.unread = false;
        }
      });

  void _tapNotif(_Notif n) {
    setState(() => n.unread = false);
    if (n.action == null) return;
    switch (n.action) {
      case 'payoutConsent':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PayoutConsentScreen()));
      case 'fundingDetail':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FundingDetailScreen()));
      case 'postDetail':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PostDetailScreen()));
      case 'memberApproval':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MemberApprovalScreen()));
      case 'settleAuto':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettleAutoScreen()));
      default:
        MoishoToast.show(context, '준비 중', tone: 'info');
    }
  }

  void _openMeeting() =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FundingDetailScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(
          title: '알림',
          onBack: () => Navigator.of(context).maybePop(),
          actions: [
            if (_unreadCount > 0)
              GestureDetector(
                onTap: _readAll,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text('모두 읽음', style: tx(13, FontWeight.w600, T.primary, height: 1)),
                ),
              ),
          ],
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            children: [
              _upcomingSection(),
              ..._items.map(_notifRow),
            ],
          ),
        ),
      ]),
    );
  }

  // ── 참석 예정 모임 ──
  Widget _upcomingSection() => Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: const BoxDecoration(
          color: T.white,
          border: Border(bottom: BorderSide(color: T.borderSubtle)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text('참석 예정 모임',
                style: TextStyle(
                    fontFamily: kFont, fontSize: 12, fontWeight: FontWeight.w700, color: T.textMuted, letterSpacing: 0.48, height: 1)),
          ),
          for (var i = 0; i < _upcoming.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _upcomingRow(_upcoming[i]),
          ],
        ]),
      );

  Widget _upcomingRow(_Upcoming m) {
    final d = ddayInfo(m.dday);
    final far = m.dday > 7;
    return GestureDetector(
      onTap: _openMeeting,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: T.gray50,
          borderRadius: BorderRadius.circular(T.rLg),
          border: Border.all(color: T.borderSubtle),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: d.bg,
              borderRadius: BorderRadius.circular(T.rMd),
              border: Border.all(color: far ? T.borderDefault : d.color, width: 1.5),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('D', style: tx(11, FontWeight.w700, d.color, height: 1)),
              Text('-${m.dday}', style: tx(11, FontWeight.w700, d.color, height: 1, tab: true)),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(13, FontWeight.w600, T.textTitle, height: 1.2)),
              const SizedBox(height: 3),
              Row(children: [
                Container(width: 5, height: 5, decoration: BoxDecoration(color: m.color, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Expanded(child: Text(m.club, maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(11, FontWeight.w500, T.textMuted, height: 1))),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          Text(m.date, style: tx(12, FontWeight.w600, T.textMuted, height: 1, tab: true)),
        ]),
      ),
    );
  }

  // ── 알림 행 ──
  Widget _notifRow(_Notif n) {
    return GestureDetector(
      onTap: () => _tapNotif(n),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: n.unread ? T.primarySoft : T.white,
          border: const Border(bottom: BorderSide(color: T.borderSubtle)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: n.unread ? T.white : T.gray50,
              shape: BoxShape.circle,
              border: Border.all(color: n.unread ? n.tone.withValues(alpha: 0.267) : T.borderSubtle, width: 1.5),
            ),
            child: Icon(n.icon, size: 20, color: n.tone),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text(n.title, style: tx(14, FontWeight.w700, T.textTitle, height: 1.2))),
                const SizedBox(width: 8),
                Text(n.time, style: tx(11, FontWeight.w500, T.textDisabled, height: 1)),
              ]),
              const SizedBox(height: 3),
              Text(n.body, style: tx(13, FontWeight.w500, T.textBody, height: 1.4)),
            ]),
          ),
          if (n.unread) ...[
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(top: 7),
              width: 8, height: 8,
              decoration: const BoxDecoration(color: T.primary, shape: BoxShape.circle),
            ),
          ],
        ]),
      ),
    );
  }
}
