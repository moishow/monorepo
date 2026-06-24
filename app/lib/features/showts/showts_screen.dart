// 쇼츠 탭 — prototype ShowtsFeedScreen (5722de86). 풀블리드 세로 영상 피드.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/toast.dart';

class _Funding {
  final bool active;
  final String? title;
  final int? dday;
  const _Funding(this.active, [this.title, this.dday]);
}

class _Video {
  final int id;
  final String club, clubSub, handle, tone, caption, tag, bgImg, topComment;
  final int likes, comments;
  final _Funding funding;
  final bool ledger;
  const _Video(this.id, this.club, this.clubSub, this.handle, this.tone, this.caption, this.tag, this.likes, this.comments, this.funding, this.ledger, this.bgImg, this.topComment);
}

const _videos = [
  _Video(1, "홍대 연합 밴드 '사운드'", '홍대 연합 밴드', '@sound_band', 'blue',
      '이번 정기 대관 연습 찢었다.. 뒷풀이 고기까지 완벽했던 하루! #밴드 #홍대 #뒷풀이', '공연 실황', 3200, 142,
      _Funding(true, '06/15 정기 대관 연습', 2), true,
      'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=390&h=800&fit=crop&auto=format&q=80',
      '여기 이번 정산 영수증 오픈한 거 보니까 돈 관리도 진짜 투명하게 하더라고요ㅋㅋ'),
  _Video(2, "직장인 독서회 '북적북적'", '북적북적', '@bukjuk_book', 'purple',
      '이번 달 책 《불편한 편의점》 완독! 토론이 너무 치열해서 2시간이 훌쩍 ✨ #독서 #북클럽 #직장인', '모임 하이라이트', 891, 47,
      _Funding(false), true,
      'https://images.unsplash.com/photo-1456324504439-367cee3b3c32?w=390&h=800&fit=crop&auto=format&q=80',
      '저도 가입하고 싶어요! 신입 모집하나요?'),
  _Video(3, "토요 풋살회 '풋살러'", '풋살러', '@futsal_crew', 'coral',
      '비 와도 실내 풋살로 극복 💪 오늘 첫 승! 뒤풀이 치킨까지 완벽한 토요일 #풋살 #토요일 #스포츠', '경기 하이라이트', 2100, 88,
      _Funding(true, '06/22 번개 풋살 모임', 5), false,
      'https://images.unsplash.com/photo-1551958219-acbc595d2e8b?w=390&h=800&fit=crop&auto=format&q=80',
      '골 장면 다시 보고 싶어요ㅋㅋㅋ 진짜 멋있었어요!'),
];

const _gradients = [
  LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0E2E), Color(0xFF1A2A6C), Color(0xFF0F3460)]),
  LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1A0A3E), Color(0xFF3B1D8C), Color(0xFF6B21A8)]),
  LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1A0A0A), Color(0xFF7C2D12), Color(0xFFC2410C)]),
];

class ShowtsScreen extends StatefulWidget {
  const ShowtsScreen({super.key});
  @override
  State<ShowtsScreen> createState() => _ShowtsScreenState();
}

class _ShowtsScreenState extends State<ShowtsScreen> {
  int _idx = 0;
  String _filter = 'trending';
  final Map<int, bool> _liked = {};
  bool _commentOpen = false;
  final _commentCtrl = TextEditingController();

  static const _filters = [
    (id: 'search', label: '검색', icon: LucideIcons.search),
    (id: 'trending', label: '트렌딩', icon: LucideIcons.flame),
    (id: 'my', label: '내 동아리', icon: LucideIcons.users),
  ];

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';

  void _swipe(int dir) => setState(() {
        _idx = (_idx + dir + _videos.length) % _videos.length;
        _commentOpen = false;
      });

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = _videos[_idx];
    final top = MediaQuery.paddingOf(context).top;
    final fundingActive = v.funding.active;
    final bottomBase = fundingActive ? 152.0 : 110.0;

    return GestureDetector(
      onVerticalDragEnd: (d) {
        final vy = d.primaryVelocity ?? 0;
        if (vy < -200) _swipe(1);
        if (vy > 200) _swipe(-1);
      },
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          children: [
            // 배경 (그라데이션 폴백 + 영상 플레이스홀더 이미지)
            Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: _gradients[_idx]))),
            Positioned.fill(
              child: Image.network(v.bgImg, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xE0000000), Color(0x33000000), Color(0x73000000)], stops: [0.0, 0.55, 1.0]),
                ),
              ),
            ),
            // 좌/우 탭 영역 (이전/다음)
            Positioned(top: 100 + top, left: 0, bottom: fundingActive ? 58 : 0, width: MediaQuery.sizeOf(context).width * 0.35, child: GestureDetector(onTap: () => _swipe(-1), behavior: HitTestBehavior.opaque)),
            Positioned(top: 100 + top, right: 0, bottom: fundingActive ? 58 : 0, width: MediaQuery.sizeOf(context).width * 0.35, child: GestureDetector(onTap: () => _swipe(1), behavior: HitTestBehavior.opaque)),

            // 상태바 (흰색)
            Positioned(
              top: top, left: 0, right: 0, height: 44,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('9:41', style: tx(14, FontWeight.w700, T.white, ls: 0, height: 1).copyWith(fontFeatures: kTnum)),
                  Row(children: [
                    const Icon(LucideIcons.signal, size: 14, color: T.white),
                    const SizedBox(width: 5),
                    const Icon(LucideIcons.wifi, size: 14, color: T.white),
                    const SizedBox(width: 5),
                    const Icon(LucideIcons.batteryFull, size: 16, color: T.white),
                  ]),
                ]),
              ),
            ),

            // 필터 탭
            Positioned(
              top: 44 + top, left: 0, right: 0,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (final f in _filters)
                  GestureDetector(
                    onTap: () => setState(() => _filter = f.id),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _filter == f.id ? T.white : Colors.transparent, width: 2))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(f.icon, size: 13, color: _filter == f.id ? T.white : Colors.white.withValues(alpha: 0.5)),
                        const SizedBox(width: 5),
                        Text(f.label, style: tx(13, _filter == f.id ? FontWeight.w700 : FontWeight.w500, _filter == f.id ? T.white : Colors.white.withValues(alpha: 0.5), height: 1)),
                      ]),
                    ),
                  ),
              ]),
            ),

            // 진행 바
            Positioned(
              top: 90 + top, left: 20, right: 20, height: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(1),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.2),
                  child: Align(alignment: Alignment.centerLeft, child: FractionallySizedBox(widthFactor: 0.38, child: Container(color: T.white))),
                ),
              ),
            ),

            // 업로드 버튼
            Positioned(
              top: 48 + top, right: 16,
              child: _glassBtn(LucideIcons.plus, 36, 19, () => MoishoToast.show(context, '쇼츠 업로드는 준비 중이에요', tone: 'info')),
            ),

            // 중앙 재생 + 타이머
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: const Alignment(0, -0.3),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 68, height: 68,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5)),
                      child: const Icon(LucideIcons.play, size: 30, color: T.white),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(999)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFFF4444), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('00:25', style: tx(12, FontWeight.w700, T.white, height: 1)),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),

            // 페이지 인디케이터 (우측 세로)
            Positioned(
              right: 10, top: 0, bottom: 0,
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  for (int i = 0; i < _videos.length; i++)
                    GestureDetector(
                      onTap: () => setState(() {
                        _idx = i;
                        _commentOpen = false;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(vertical: 2.5),
                        width: i == _idx ? 4 : 3,
                        height: i == _idx ? 22 : 8,
                        decoration: BoxDecoration(color: i == _idx ? T.white : Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                ]),
              ),
            ),

            // 우측 액션 레일
            Positioned(
              right: 14, bottom: bottomBase,
              child: Column(children: [
                // 동아리 아바타 + 팔로우
                GestureDetector(
                  onTap: () => MoishoToast.show(context, '동아리 상세는 준비 중이에요', tone: 'info'),
                  child: SizedBox(
                    width: 46, height: 56,
                    child: Stack(clipBehavior: Clip.none, alignment: Alignment.topCenter, children: [
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(color: T.primary, shape: BoxShape.circle, border: Border.all(color: T.white, width: 2.5)),
                        alignment: Alignment.center,
                        child: Text(v.club.characters.first, style: tx(17, FontWeight.w700, T.white, height: 1)),
                      ),
                      Positioned(
                        top: 36,
                        child: Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(color: T.accent, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)),
                          child: const Icon(LucideIcons.plus, size: 11, color: T.white),
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 18),
                _actionBtn(LucideIcons.heart, _fmt(v.likes + (_liked[v.id] == true ? 1 : 0)), active: _liked[v.id] == true, activeColor: const Color(0xFFFF4444), onTap: () => setState(() => _liked[v.id] = !(_liked[v.id] ?? false))),
                const SizedBox(height: 18),
                _actionBtn(LucideIcons.messageCircle, '${v.comments}', onTap: () => setState(() => _commentOpen = !_commentOpen)),
                const SizedBox(height: 18),
                // 펀딩 연동 / 가입
                Column(children: [
                  GestureDetector(
                    onTap: () => MoishoToast.show(context, fundingActive ? '펀딩 화면은 준비 중이에요' : '동아리 상세는 준비 중이에요', tone: 'info'),
                    child: Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3D7DFA), T.accent]),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: const Color(0xFF3D7DFA).withValues(alpha: 0.55), blurRadius: 16)],
                      ),
                      child: const Icon(LucideIcons.coins, size: 22, color: T.white),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(fundingActive ? '펀딩\n연동' : '가입', textAlign: TextAlign.center, style: tx(10, FontWeight.w700, T.white, height: 1.3)),
                ]),
                const SizedBox(height: 18),
                _actionBtn(LucideIcons.share2, '공유', onTap: () => MoishoToast.show(context, '쇼츠 링크가 복사됐어요!', tone: 'info')),
              ]),
            ),

            // 좌하단 정보
            Positioned(
              left: 16, right: 74, bottom: bottomBase,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  Flexible(child: Text('🎵 ${v.clubSub}', maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(16, FontWeight.w700, T.white, height: 1.2))),
                  if (v.ledger) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFF22C55E).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.5))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text('투명 장부 인증', style: tx(10, FontWeight.w700, const Color(0xFF4ADE80), height: 1)),
                      ]),
                    ),
                  ],
                ]),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(LucideIcons.sparkles, size: 12, color: T.accent),
                    const SizedBox(width: 5),
                    Text(v.tag, style: tx(11, FontWeight.w700, T.white, height: 1)),
                  ]),
                ),
                const SizedBox(height: 8),
                Text(v.caption, style: tx(13, FontWeight.w500, Colors.white.withValues(alpha: 0.92), height: 1.5)),
                const SizedBox(height: 10),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(LucideIcons.messageCircle, size: 13, color: Colors.white.withValues(alpha: 0.6)),
                  const SizedBox(width: 6),
                  Expanded(child: Text('"${v.topComment}"', maxLines: 2, overflow: TextOverflow.ellipsis, style: tx(12, FontWeight.w500, Colors.white.withValues(alpha: 0.7), height: 1.4))),
                ]),
              ]),
            ),

            // 스와이프 유도
            Positioned(
              bottom: fundingActive ? 65 : 18, left: 0, right: 0,
              child: IgnorePointer(child: Opacity(opacity: 0.45, child: Icon(LucideIcons.chevronUp, size: 18, color: T.white))),
            ),

            // 사전 펀딩 CTA 바
            if (fundingActive)
              Positioned(
                bottom: 0, left: 0, right: 0, height: 58,
                child: GestureDetector(
                  onTap: () => MoishoToast.show(context, '펀딩 화면은 준비 중이에요', tone: 'info'),
                  child: Container(
                    decoration: const BoxDecoration(gradient: T.gradBrand),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(LucideIcons.zap, size: 17, color: T.white),
                      const SizedBox(width: 8),
                      Text('지금 이 동아리 사전 펀딩 참여하기', style: tx(14, FontWeight.w700, T.white, height: 1)),
                      const SizedBox(width: 6),
                      Text('(D-${v.funding.dday})', style: tx(13, FontWeight.w700, Colors.white.withValues(alpha: 0.75), height: 1)),
                    ]),
                  ),
                ),
              ),

            // 댓글 패널
            if (_commentOpen) _commentPanel(v),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String count, {bool active = false, Color? activeColor, VoidCallback? onTap}) => Column(children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, size: 22, color: active ? (activeColor ?? T.white) : T.white),
          ),
        ),
        const SizedBox(height: 5),
        Text(count, style: tx(11, FontWeight.w700, T.white, height: 1)),
      ]);

  Widget _glassBtn(IconData icon, double size, double iconSize, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
          child: Icon(icon, size: iconSize, color: T.white),
        ),
      );

  Widget _commentPanel(_Video v) {
    final comments = [
      ('박소심', '3분 전', '와 베이스 라인 미쳤다.. 가입하고 싶어요'),
      ('이땡땡', '8분 전', v.topComment),
      ('최열심', '15분 전', '다음 공연 일정이 언제예요?? 꼭 가고 싶어요'),
      ('장건망', '22분 전', '투명 장부 인증 진짜 좋다ㅋㅋ 이런 동아리 찾았다'),
      ('오빠름', '31분 전', '신입 모집 조건이 어떻게 돼요?'),
    ];
    return Positioned(
      bottom: 0, left: 0, right: 0,
      height: MediaQuery.sizeOf(context).height * 0.58,
      child: Container(
        decoration: const BoxDecoration(color: Color(0xF70C0C16), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Row(children: [
              Text('댓글 ${v.comments}개', style: tx(15, FontWeight.w700, T.white, height: 1)),
              const Spacer(),
              GestureDetector(onTap: () => setState(() => _commentOpen = false), child: Icon(LucideIcons.x, size: 20, color: Colors.white.withValues(alpha: 0.5))),
            ]),
          ),
          const Divider(height: 1, color: Color(0x14FFFFFF)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              physics: const BouncingScrollPhysics(),
              children: [
                for (final c in comments)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text(c.$1.characters.first, style: tx(12, FontWeight.w700, T.white, height: 1)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text(c.$1, style: tx(12, FontWeight.w700, Colors.white.withValues(alpha: 0.9), height: 1)),
                            const SizedBox(width: 8),
                            Text(c.$2, style: tx(11, FontWeight.w500, Colors.white.withValues(alpha: 0.35), height: 1)),
                          ]),
                          const SizedBox(height: 4),
                          Text(c.$3, style: tx(13, FontWeight.w500, Colors.white.withValues(alpha: 0.78), height: 1.45)),
                        ]),
                      ),
                    ]),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0x14FFFFFF)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: SafeArea(
              top: false,
              child: Row(children: [
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _commentCtrl,
                      style: tx(13, FontWeight.w500, T.white, height: 1.2),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          MoishoToast.show(context, '댓글이 달렸어요!', tone: 'success');
                          _commentCtrl.clear();
                        }
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: '댓글 달기...',
                        hintStyle: tx(13, FontWeight.w500, Colors.white.withValues(alpha: 0.4), height: 1.2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ValueListenableBuilder(
                  valueListenable: _commentCtrl,
                  builder: (_, value, _) {
                    final has = value.text.trim().isNotEmpty;
                    return GestureDetector(
                      onTap: has
                          ? () {
                              MoishoToast.show(context, '댓글이 달렸어요!', tone: 'success');
                              _commentCtrl.clear();
                            }
                          : null,
                      child: Icon(LucideIcons.send, size: 20, color: has ? T.accent : Colors.white.withValues(alpha: 0.25)),
                    );
                  },
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
