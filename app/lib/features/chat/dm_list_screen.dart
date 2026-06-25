// 채팅 탭 — prototype DmListScreen + DmChatScreen (5a5d1649).
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';

class DmMsg {
  final bool mine;
  final String text, time;
  const DmMsg(this.mine, this.text, this.time);
}

class DmConv {
  final String id, name, role, roleTone, tone, club, lastMsg, lastTime, photo;
  final bool online;
  final int unread;
  final List<DmMsg> messages;
  const DmConv(this.id, this.name, this.role, this.roleTone, this.tone, this.club, this.online, this.unread, this.lastMsg, this.lastTime, this.photo, this.messages);

  factory DmConv.quick(String name) =>
      DmConv('dm', name, '멤버', 'neutral', 'blue', '', true, 0, '', '방금', '', const [DmMsg(false, '안녕하세요!', '방금')]);
}

const _dmPhotos = {
  'kimhj': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop&crop=face&auto=format&q=80',
  'leesum': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop&crop=face&auto=format&q=80',
  'parkso': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop&crop=face&auto=format&q=80',
  'jangys': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face&auto=format&q=80',
};

const _convs = <DmConv>[
  DmConv('kimhj', '김회장', '회장', 'blue', 'blue', "홍대 연합 밴드 '사운드'", true, 2, '이번 주 합주실 예약했어요!', '방금', '', [
    DmMsg(false, '안녕하세요! 이번 주 합주 참석 가능하세요?', '오전 10:05'),
    DmMsg(true, '네! 토요일 오후 2시 맞죠?', '오전 10:07'),
    DmMsg(false, '맞아요 ㅎㅎ 장소는 홍대 사운드스튜디오 1호점이에요', '오전 10:08'),
    DmMsg(true, '알겠습니다! 악기 챙겨갈게요 🎸', '오전 10:10'),
    DmMsg(false, '이번 주 합주실 예약했어요!', '오전 10:44'),
  ]),
  DmConv('leesum', '이총무', '총무', 'purple', 'mint', "홍대 연합 밴드 '사운드'", true, 0, '펀딩 입금 확인됐어요 👍', '1시간 전', '', [
    DmMsg(false, '안녕하세요! 이번 정기 모임 펀딩 입금 확인됐어요 👍', '오전 9:30'),
    DmMsg(true, '아 감사합니다! 이미 입금했었는데 다행이에요', '오전 9:32'),
    DmMsg(false, '네! 40,000원 정확히 들어왔어요. 다음 모임에서 봬요~', '오전 9:33'),
    DmMsg(true, '넵! 감사합니다 😊', '오전 9:35'),
    DmMsg(false, '펀딩 입금 확인됐어요 👍', '오전 9:30'),
  ]),
  DmConv('parkso', '박소심', '부원', 'neutral', 'coral', "홍대 연합 밴드 '사운드'", false, 0, '다음에 같이 뒷풀이 가요!', '어제', '', [
    DmMsg(false, '저번 공연 너무 즐거웠어요ㅋㅋ 다음에 같이 뒷풀이 가요!', '어제 오후 7:12'),
    DmMsg(true, '저도 재밌었어요 ㅎㅎ 다음에 꼭 같이 가요!', '어제 오후 7:15'),
  ]),
  DmConv('jangys', '장열심', '부원', 'neutral', 'gray', "홍대 연합 밴드 '사운드'", false, 1, '드럼 연습 같이 할 분?', '2일 전', '', [
    DmMsg(false, '드럼 연습 같이 할 분 있어요?', '2일 전 오후 3:20'),
    DmMsg(false, '드럼 연습 같이 할 분?', '2일 전 오후 3:20'),
  ]),
];

String _roleBadgeTone(String roleTone) => roleTone == 'neutral' ? 'gray' : roleTone;

class DmListScreen extends StatelessWidget {
  const DmListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalUnread = _convs.fold<int>(0, (s, c) => s + c.unread);
    return Column(
      children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '메시지', actions: [
          GestureDetector(
            onTap: () => MoishoToast.show(context, '새 대화 시작하기', tone: 'info'),
            behavior: HitTestBehavior.opaque,
            child: const Padding(padding: EdgeInsets.all(2), child: Icon(LucideIcons.plus, size: 22, color: T.primary)),
          ),
        ]),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 12, T.padScreen, 24),
            physics: const BouncingScrollPhysics(),
            children: [
              if (totalUnread > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
                  child: Align(alignment: Alignment.centerLeft, child: MBadge('읽지 않은 메시지 $totalUnread개', tone: 'danger')),
                ),
              for (int i = 0; i < _convs.length; i++) _row(context, _convs[i], i < _convs.length - 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, DmConv c, bool divider) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DmChatScreen(conv: c))),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(border: divider ? const Border(bottom: BorderSide(color: T.borderSubtle)) : null),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          MAvatar(name: c.name, src: _dmPhotos[c.id], tone: c.tone, size: 48, status: c.online ? 'online' : null),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(c.name, style: tx(15, c.unread > 0 ? FontWeight.w700 : FontWeight.w600, T.textStrong, height: 1)),
                const SizedBox(width: 6),
                MBadge(c.role, tone: _roleBadgeTone(c.roleTone)),
                const Spacer(),
                Text(c.lastTime, style: tx(11, FontWeight.w500, T.textDisabled, height: 1)),
              ]),
              const SizedBox(height: 5),
              Row(children: [
                Expanded(child: Text(c.lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(13, c.unread > 0 ? FontWeight.w600 : FontWeight.w500, c.unread > 0 ? T.textBody : T.textMuted, height: 1))),
                if (c.unread > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    constraints: const BoxConstraints(minWidth: 20),
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: T.danger, borderRadius: BorderRadius.circular(10)),
                    child: Text('${c.unread}', style: tx(11, FontWeight.w700, T.white, height: 1)),
                  ),
                ],
              ]),
              const SizedBox(height: 5),
              Text(c.club, style: tx(11, FontWeight.w500, T.textDisabled, height: 1)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── 개인 DM 채팅 (full-screen push) ──
class DmChatScreen extends StatefulWidget {
  final DmConv conv;
  const DmChatScreen({super.key, required this.conv});
  @override
  State<DmChatScreen> createState() => _DmChatScreenState();
}

class _DmChatScreenState extends State<DmChatScreen> {
  late final List<DmMsg> _messages = [...widget.conv.messages];
  final _input = TextEditingController();
  final _scroll = ScrollController();
  int _replyIdx = 0;
  static const _replies = ['ㅎㅎ 알겠어요!', '좋아요! 그때 봬요 😊', '감사합니다~', '네 확인했어요!', 'ㅋㅋ 맞아요!'];

  void _send() {
    final t = _input.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _messages.add(DmMsg(true, t, '방금'));
      _input.clear();
    });
    _scrollToEnd();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _messages.add(DmMsg(false, _replies[_replyIdx % _replies.length], '방금'));
        _replyIdx++;
      });
      _scrollToEnd();
    });
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.conv;
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(
        children: [
          const MoishoStatusBar(),
          // 헤더
          Container(
            height: 56,
            padding: const EdgeInsets.only(left: 8, right: 12),
            decoration: const BoxDecoration(color: T.white, border: Border(bottom: BorderSide(color: T.borderSubtle))),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(width: 36, height: 36, child: Icon(LucideIcons.arrowLeft, size: 23, color: T.textStrong)),
              ),
              const SizedBox(width: 4),
              MAvatar(name: c.name, src: _dmPhotos[c.id], tone: c.tone, size: 36, status: c.online ? 'online' : null),
              const SizedBox(width: 8),
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(c.name, style: tx(15, FontWeight.w700, T.textStrong, height: 1)),
                    const SizedBox(width: 6),
                    MBadge(c.role, tone: _roleBadgeTone(c.roleTone)),
                  ]),
                  const SizedBox(height: 2),
                  Text('${c.online ? "온라인" : "오프라인"} · ${c.club}', maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(11, FontWeight.w500, c.online ? T.success : T.textDisabled, height: 1)),
                ]),
              ),
              _circleBtn(LucideIcons.phone, () => MoishoToast.show(context, '${c.name}님에게 전화 중...', tone: 'info')),
              const SizedBox(width: 8),
              _circleBtn(LucideIcons.ellipsis, () => MoishoToast.show(context, '더보기 메뉴', tone: 'info')),
            ]),
          ),
          // 메시지
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              physics: const BouncingScrollPhysics(),
              children: [
                // 날짜 구분선
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    const Expanded(child: Divider(color: T.borderSubtle, height: 1)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('오늘', style: tx(11, FontWeight.w500, T.textDisabled, height: 1))),
                    const Expanded(child: Divider(color: T.borderSubtle, height: 1)),
                  ]),
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < _messages.length; i++) _bubble(c, i),
              ],
            ),
          ),
          // 입력 바
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            decoration: const BoxDecoration(color: T.white, border: Border(top: BorderSide(color: T.borderSubtle))),
            child: SafeArea(
              top: false,
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                _roundBtn(LucideIcons.plus, T.gray50, T.textMuted, 38, () => MoishoToast.show(context, '파일 첨부', tone: 'info')),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: T.gray50, borderRadius: BorderRadius.circular(20), border: Border.all(color: T.borderSubtle, width: 1.5)),
                    child: TextField(
                      controller: _input,
                      onSubmitted: (_) => _send(),
                      style: tx(14, FontWeight.w500, T.textBody, height: 1.2),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: '${c.name}님에게 메시지 보내기',
                        hintStyle: tx(14, FontWeight.w500, T.textMuted, height: 1.2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ValueListenableBuilder(
                  valueListenable: _input,
                  builder: (_, value, _) {
                    final has = value.text.trim().isNotEmpty;
                    return _roundBtn(LucideIcons.send, has ? T.primary : T.gray100, has ? T.white : T.textDisabled, 40, has ? _send : null);
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(DmConv c, int i) {
    final m = _messages[i];
    final showAvatar = !m.mine && (i == 0 || _messages[i - 1].mine);
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: m.mine ? T.primary : T.white,
        border: m.mine ? null : Border.all(color: T.borderSubtle),
        borderRadius: m.mine
            ? const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomLeft: Radius.circular(18), bottomRight: Radius.circular(4))
            : const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomLeft: Radius.circular(4), bottomRight: Radius.circular(18)),
        boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 3, offset: Offset(0, 1))],
      ),
      child: Text(m.text, style: tx(14, FontWeight.w500, m.mine ? T.white : T.textBody, height: 1.5)),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: m.mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!m.mine)
            SizedBox(width: 32, child: showAvatar ? MAvatar(name: c.name, src: _dmPhotos[c.id], tone: c.tone, size: 32) : null),
          if (!m.mine) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: m.mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                bubble,
                const SizedBox(height: 3),
                Text(m.time, style: tx(10, FontWeight.w500, T.textDisabled, height: 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(color: T.gray50, shape: BoxShape.circle),
          child: Icon(icon, size: icon == LucideIcons.phone ? 17 : 18, color: T.textMuted),
        ),
      );

  Widget _roundBtn(IconData icon, Color bg, Color fg, double size, VoidCallback? onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: fg),
        ),
      );
}
