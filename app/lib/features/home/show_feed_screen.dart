// 홈 탭 = 쇼 피드 — prototype ShowFeedScreen (f566565a:596).
// 미인증 유저에겐 비차단 KYC 배너 노출(닫기 가능) — 첫 머니 액션의 선택적 진입점(flow doc 01 §3).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/data/session.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../auth/auth_dialogs.dart';
import '../common/meeting_card.dart';
import '../meeting/meeting_detail_screen.dart';
import 'post_detail_screen.dart';
import 'show_write_screen.dart';
import '../meeting/flash_apply_screen.dart';

// 멤버 프로필 사진 (prototype MEMBER_PHOTOS)
const _photo = {
  '정디자': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face&auto=format&q=80',
  '이민준': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop&crop=face&auto=format&q=80',
  '박회장': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop&crop=face&auto=format&q=80',
  '김수현': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop&crop=face&auto=format&q=80',
};

class _Post {
  final String author, tone, club, clubTone, time, tag, text, img;
  final int likes, comments;
  const _Post(this.author, this.tone, this.club, this.clubTone, this.time, this.tag, this.text, this.likes, this.comments, this.img);
}

class ShowFeedScreen extends ConsumerStatefulWidget {
  const ShowFeedScreen({super.key});
  @override
  ConsumerState<ShowFeedScreen> createState() => _ShowFeedScreenState();
}

class _ShowFeedScreenState extends ConsumerState<ShowFeedScreen> {
  bool _kycDismissed = false;

  static const _posts = [
    _Post('정디자', 'purple', "홍대 연합 밴드 '사운드'", 'blue', '2시간 전', '봄MT', '펜션 도착! 날씨 미쳤고 바베큐 준비 완료 🔥 다들 빨리 와요~', 24, 6, 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=400&h=220&fit=crop&auto=format&q=80'),
    _Post('이민준', 'mint', "서울 사진 동아리 '프레임'", 'mint', '3시간 전', '출사', '한강 야경 출사 다녀왔어요. 오늘 빛이 진짜 예뻤습니다 🌇', 15, 4, 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=400&h=220&fit=crop&auto=format&q=80'),
    _Post('박회장', 'blue', "홍대 연합 밴드 '사운드'", 'blue', '어제', '공연', '정기공연 합주 끝! 이번 곡 진짜 잘 나왔어요 🎸', 41, 12, 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=400&h=220&fit=crop&auto=format&q=80'),
    _Post('김수현', 'orange', "서울 독서 모임 '페이지'", 'purple', '어제', '독서', '이번 달 선정 도서 《파친코》 1부 읽었어요 📚', 9, 2, 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=400&h=220&fit=crop&auto=format&q=80'),
  ];

  static final _meetings = <int, MeetingItem>{
    1: const MeetingItem(title: '6월 정기 합주 & 뒷풀이', author: '박회장', tone: 'blue', source: 'club', time: '3시간 전', club: "홍대 연합 밴드 '사운드'", clubTone: 'blue', date: '6월 15일 (토) 18:00', dday: 'D-3', tag: '공연', rounds: [Round('1차', '홍대 사운드스튜디오', 7, 12, 27000), Round('2차', '근처 이자카야', 4, 10, 18000)]),
    2: const MeetingItem(title: '퇴근길 홍대 와인바 번개', author: '박지훈', tone: 'purple', source: 'follow', time: '5시간 전', date: '6월 13일 (목) 20:00', dday: 'D-1', tag: '번개', rounds: [Round('1차', '홍대 와인앤비어', 3, 6, 25000)]),
    3: const MeetingItem(title: '한강 출사 & 피크닉', author: '이민준', tone: 'mint', source: 'club', time: '어제', club: "서울 사진 동아리 '프레임'", clubTone: 'mint', date: '6월 22일 (일) 14:00', dday: 'D-9', tag: '출사', rounds: [Round('1차', '반포 한강공원', 9, 15, 5000)]),
  };

  void _openMeeting(MeetingItem m) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => m.tag == '번개'
              ? const FlashApplyScreen()
              : MeetingDetailScreen(title: m.title, club: m.club),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final verified = ref.watch(sessionProvider).verified;
    // 피드 순서: post, meeting1, post, meeting2, post, meeting3, post
    final feed = <Widget>[
      _postCard(_posts[0]),
      MeetingCard(item: _meetings[1]!, onTap: () => _openMeeting(_meetings[1]!)),
      _postCard(_posts[1]),
      MeetingCard(item: _meetings[2]!, onTap: () => _openMeeting(_meetings[2]!)),
      _postCard(_posts[2]),
      MeetingCard(item: _meetings[3]!, onTap: () => _openMeeting(_meetings[3]!)),
      _postCard(_posts[3]),
    ];

    return Column(
      children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '쇼', actions: [
          MinTapTarget(
            const Icon(LucideIcons.squarePen, size: 22, color: T.accent),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShowWriteScreen())),
          ),
        ]),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 12, T.padScreen, 24),
            children: [
              if (!verified && !_kycDismissed) _kycBanner(),
              _eventBanner(),
              ...feed,
            ],
          ),
        ),
      ],
    );
  }

  // 미인증 유저용 비차단 본인인증 배너
  Widget _kycBanner() => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: GestureDetector(
          onTap: () => ensureVerified(context, ref, action: '회비 모으기'),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            decoration: BoxDecoration(
              color: T.primarySoft,
              borderRadius: BorderRadius.circular(T.rXl),
              border: Border.all(color: T.primary.withValues(alpha: 0.35), width: 1.5),
            ),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: T.primary, borderRadius: BorderRadius.circular(T.rMd)),
                child: const Icon(LucideIcons.shieldCheck, size: 21, color: T.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('본인인증하고 회비 모으기 시작하기', style: tx(13.5, FontWeight.w700, T.textStrong, height: 1.2)),
                  const SizedBox(height: 4),
                  Text('동아리 회비·번개 정산을 안전하게', style: tx(11.5, FontWeight.w500, T.primary, height: 1.2)),
                ]),
              ),
              MinTapTarget(
                const Icon(LucideIcons.x, size: 16, color: T.textFaint),
                onTap: () => setState(() => _kycDismissed = true),
              ),
            ]),
          ),
        ),
      );

  Widget _eventBanner() => Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(gradient: T.gradEventBanner, borderRadius: BorderRadius.circular(T.rXl), boxShadow: T.glowPurple),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('🎉 이번 주 쇼 이벤트', style: tx(11, FontWeight.w700, Colors.white.withValues(alpha: 0.9), height: 1)),
              const SizedBox(height: 6),
              Text('봄 MT 후기 올리고\n커피 기프티콘 받기 ☕', style: tx(16, FontWeight.w700, T.white, height: 1.3)),
            ]),
          ),
          const Icon(LucideIcons.chevronRight, size: 24, color: T.white),
        ]),
      );

  Widget _postCard(_Post p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: MCard(
        radius: T.rXl,
        padding: const EdgeInsets.all(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PostDetailScreen())),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 동아리 출처
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: T.borderSubtle))),
            child: Row(children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: clubColors[p.clubTone] ?? T.primary, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Expanded(child: Text(p.club, style: tx(11, FontWeight.w600, T.textMuted, height: 1))),
              Text(p.time, style: tx(11, FontWeight.w500, T.textDisabled, height: 1)),
            ]),
          ),
          // 작성자 + 태그
          Row(children: [
            MAvatar(name: p.author, src: _photo[p.author], tone: p.tone, size: 36),
            const SizedBox(width: 10),
            Expanded(child: Text(p.author, overflow: TextOverflow.ellipsis, style: tx(14, FontWeight.w700, T.textTitle, height: 1))),
            MTag(p.tag, tone: 'purple', leadingHash: true),
          ]),
          const SizedBox(height: 12),
          // 본문
          Text(p.text, style: tx(14, FontWeight.w400, T.textBody, height: 1.5)),
          const SizedBox(height: 12),
          // 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(T.rLg),
            child: NetImage(url: p.img, width: double.infinity, height: 160, fallback: Container(height: 160, color: T.gray100)),
          ),
          const SizedBox(height: 12),
          // 반응
          Row(children: [
            Icon(LucideIcons.heart, size: 17, color: T.accent),
            const SizedBox(width: 5),
            Text('${p.likes}', style: tx(13, FontWeight.w600, T.accent, height: 1)),
            const SizedBox(width: 18),
            Icon(LucideIcons.messageCircle, size: 17, color: T.textMuted),
            const SizedBox(width: 5),
            Text('${p.comments}', style: tx(13, FontWeight.w600, T.textMuted, height: 1)),
          ]),
        ]),
      ),
    );
  }
}
