// 게시글 상세 — prototype PostDetailScreen (87338638:150).
// 원 게시물(동아리 출처·작성자·태그·본문·사진·좋아요/댓글) + 댓글 목록 + 하단 댓글 입력 바.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import '../club/club_detail_screen.dart';
import '../social/public_profile_screen.dart';

class _Comment {
  final String author, tone, time, text;
  const _Comment(this.author, this.tone, this.time, this.text);
}

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  // ── 게시물 데이터(프로토타입 navData.post 기본값) ──
  static const _postClub = "홍대 연합 밴드 '사운드'";
  static const _postAuthor = '정디자';
  static const _postTone = 'purple';
  static const _postTime = '2시간 전';
  static const _postTag = '봄MT';
  static const _postText = '펜션 도착! 날씨 미쳤고 바베큐 준비 완료 🔥 다들 빨리 와요~';
  static const String? _postImg = null;
  static const _postLikes = 24;

  bool _liked = false;
  final TextEditingController _commentCtrl = TextEditingController();
  bool _canSend = false;

  final List<_Comment> _comments = [
    const _Comment('박회장', 'blue', '1시간 전', '진짜 날씨 너무 좋았죠 ㅋㅋㅋ'),
    const _Comment('이총무', 'mint', '45분 전', '바베큐 고기 맛있었어요 🥩'),
    const _Comment('최부원', 'coral', '30분 전', '다음에 또 가요!!'),
    const _Comment('장열심', 'gray', '15분 전', '이런 사진은 반칙이에요 🔥'),
    const _Comment('오빠름', 'purple', '5분 전', '다음 MT도 기대됩니다 👍'),
  ];

  @override
  void initState() {
    super.initState();
    _commentCtrl.addListener(() {
      final has = _commentCtrl.text.trim().isNotEmpty;
      if (has != _canSend) setState(() => _canSend = has);
    });
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.add(_Comment('홍길동', 'blue', '방금', text));
      _commentCtrl.clear();
    });
  }

  void _openProfile(String name) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PublicProfileScreen(name: name)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(
          title: '게시글 상세',
          onBack: () => Navigator.of(context).maybePop(),
          actions: [
            MinTapTarget(
              const Icon(LucideIcons.ellipsis, size: 22, color: T.textMuted),
              onTap: () => MoishoToast.show(context, '준비 중', tone: 'info'),
              min: 38,
            ),
          ],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            physics: const BouncingScrollPhysics(),
            children: [
              _postCard(),
              const SizedBox(height: 16),
              SectionLabel('댓글 ${_comments.length}개'),
              for (final c in _comments) _commentRow(c),
              const SizedBox(height: 8),
            ],
          ),
        ),
        _commentBar(),
      ]),
    );
  }

  // ── 원 게시물 ──
  Widget _postCard() => MCard(
        elevation: 'raised',
        radius: T.rXl,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 동아리 출처 — 누르면 동아리 상세로
          GestureDetector(
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ClubDetailScreen())),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.only(bottom: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: T.borderSubtle)),
              ),
              child: Row(children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(color: T.primary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(_postClub, style: tx(12, FontWeight.w600, T.textMuted, height: 1)),
                ),
                Text('동아리', style: tx(11, FontWeight.w600, T.primary, height: 1)),
                const SizedBox(width: 2),
                const Icon(LucideIcons.chevronRight, size: 13, color: T.primary),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          // 작성자 + 태그
          Row(children: [
            GestureDetector(
              onTap: () => _openProfile(_postAuthor),
              behavior: HitTestBehavior.opaque,
              child: Row(children: [
                MAvatar(name: _postAuthor, tone: _postTone, size: 40),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_postAuthor, style: tx(14, FontWeight.w700, T.textTitle, height: 1.2)),
                  const SizedBox(height: 2),
                  Text(_postTime, style: tx(12, FontWeight.w500, T.textMuted, height: 1)),
                ]),
              ]),
            ),
            const Spacer(),
            const MTag(_postTag, tone: 'purple', leadingHash: true),
          ]),
          const SizedBox(height: 12),
          // 본문
          Text(_postText, style: tx(15, FontWeight.w500, T.textBody, height: 1.5)),
          const SizedBox(height: 12),
          // 사진 (없으면 플레이스홀더)
          if (_postImg != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(T.rLg),
              child: NetImage(
                url: _postImg, width: double.infinity, height: 200,
                fallback: Container(height: 200, color: T.gray100),
              ),
            )
          else
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [T.purple50, T.blue50],
                ),
                borderRadius: BorderRadius.circular(T.rLg),
                border: Border.all(color: T.purple200, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.image, size: 28, color: T.purple400),
                  const SizedBox(height: 6),
                  Text('사진 플레이스홀더', style: tx(13, FontWeight.w600, T.purple400, height: 1)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          // 좋아요 / 댓글
          Row(children: [
            GestureDetector(
              onTap: () => setState(() => _liked = !_liked),
              behavior: HitTestBehavior.opaque,
              child: Row(children: [
                Icon(LucideIcons.heart, size: 17, color: _liked ? T.danger : T.accent),
                const SizedBox(width: 5),
                Text('${_liked ? _postLikes + 1 : _postLikes}',
                    style: tx(13, FontWeight.w600, _liked ? T.danger : T.accent, height: 1, tab: true)),
              ]),
            ),
            const SizedBox(width: 18),
            Row(children: [
              const Icon(LucideIcons.messageCircle, size: 17, color: T.textMuted),
              const SizedBox(width: 5),
              Text('${_comments.length}', style: tx(13, FontWeight.w600, T.textMuted, height: 1, tab: true)),
            ]),
          ]),
        ]),
      );

  // ── 댓글 행 ──
  Widget _commentRow(_Comment c) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: T.borderSubtle)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          MAvatar(name: c.author, tone: c.tone, size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(c.author, style: tx(13, FontWeight.w700, T.textTitle, height: 1)),
                const SizedBox(width: 8),
                Text(c.time, style: tx(11, FontWeight.w500, T.textDisabled, height: 1)),
              ]),
              const SizedBox(height: 3),
              Text(c.text, style: tx(13, FontWeight.w500, T.textBody, height: 1.4)),
            ]),
          ),
        ]),
      );

  // ── 댓글 입력 바 ──
  Widget _commentBar() => Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        decoration: const BoxDecoration(
          color: T.white,
          border: Border(top: BorderSide(color: T.borderSubtle)),
        ),
        child: SafeArea(
          top: false,
          child: Row(children: [
            MAvatar(name: '홍길동', tone: 'blue', size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: T.gray50,
                  borderRadius: BorderRadius.circular(T.rPill),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: _commentCtrl,
                  onSubmitted: (_) => _submitComment(),
                  textInputAction: TextInputAction.send,
                  style: tx(14, FontWeight.w500, T.textBody, height: 1),
                  cursorColor: T.primary,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: '댓글 달기...',
                    hintStyle: tx(14, FontWeight.w500, T.textDisabled, height: 1),
                  ),
                ),
              ),
            ),
            MinTapTarget(
              Icon(LucideIcons.send, size: 20, color: _canSend ? T.accent : T.textDisabled),
              onTap: _submitComment,
              min: 38,
            ),
          ]),
        ),
      );
}
