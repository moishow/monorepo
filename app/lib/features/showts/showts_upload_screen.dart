// 쇼츠 업로드 + 장부 태깅 — prototype ShowtsUploadScreen (5722de86:306).
// 영상 선택 · 캡션 입력 · 모임/장부 태그(라디오) · 인증 마크 효과 안내 · 하단 발행 CTA.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';

class _Ledger {
  final int id;
  final String date, title;
  final int amount;
  const _Ledger(this.id, this.date, this.title, this.amount);
}

class ShowtsUploadScreen extends StatefulWidget {
  const ShowtsUploadScreen({super.key});

  @override
  State<ShowtsUploadScreen> createState() => _ShowtsUploadScreenState();
}

class _ShowtsUploadScreenState extends State<ShowtsUploadScreen> {
  final TextEditingController _caption = TextEditingController();
  int? _selectedLedger;
  bool _hasVideo = false;

  // ── 장부 목록(프로토타입 LEDGERS 리터럴) ──
  static const _ledgers = [
    _Ledger(0, '06/15', '정기 대관 연습 및 뒷풀이', 360000),
    _Ledger(1, '05/20', '5월 정기 엠티', 820000),
    _Ledger(2, '04/12', '신입 환영 뒷풀이', 145000),
  ];

  bool get _canPost => _caption.text.trim().isNotEmpty && _hasVideo;

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  void _publish() {
    if (!_canPost) return;
    MoishoToast.show(
      context,
      '탐색 피드에 노출되기까지 약 1분 소요돼요.',
      tone: 'success',
      title: '쇼츠 업로드 완료! 🎬',
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.white,
      body: Column(children: [
        const MoishoStatusBar(),
        _header(),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              _videoPicker(),
              const SizedBox(height: 20),
              _captionSection(),
              const SizedBox(height: 22),
              _ledgerSection(),
            ],
          ),
        ),
        StickyBar(
          child: MButton(
            '쇼츠 발행하기',
            variant: 'accent',
            size: 'lg',
            block: true,
            disabled: !_canPost,
            leadingIcon: const Icon(LucideIcons.video, size: 18, color: T.white),
            onTap: _publish,
          ),
        ),
      ]),
    );
  }

  // ── 헤더(커스텀 52px · 타이틀 + 공유 텍스트 버튼) ──
  Widget _header() => Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: T.borderSubtle)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('새 쇼츠 올리기', style: tx(17, FontWeight.w700, T.textStrong, ls: -0.01, height: 1)),
          GestureDetector(
            onTap: _publish,
            behavior: HitTestBehavior.opaque,
            child: Text('공유', style: tx(15, FontWeight.w700, _canPost ? T.accent : T.textDisabled, height: 1)),
          ),
        ]),
      );

  // ── 영상 썸네일 선택 ──
  Widget _videoPicker() => GestureDetector(
        onTap: () => setState(() => _hasVideo = !_hasVideo),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            gradient: _hasVideo
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      T.gray900, // proto #0a0e2e
                      T.blue900, // proto #1a2a6c
                      T.blue800, // proto #0f3460
                    ],
                  )
                : null,
            color: _hasVideo ? null : T.gray50,
            borderRadius: BorderRadius.circular(T.rXl),
            border: _hasVideo
                ? null
                : Border.all(color: T.borderDefault, width: 2, style: BorderStyle.solid),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(T.rXl),
            child: _hasVideo ? _videoSelected() : _videoEmpty(),
          ),
        ),
      );

  Widget _videoSelected() => Stack(children: [
        const Center(child: Icon(LucideIcons.play, size: 40, color: Color(0xD9FFFFFF))),
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(T.rMini)),
            child: Text('00:25', style: tx(12, FontWeight.w700, T.white, height: 1, tab: true)),
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: T.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(T.rPill),
              border: Border.all(color: T.success.withValues(alpha: 0.45)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: T.success, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text('영상 선택됨 (탭하여 변경)', style: tx(10, FontWeight.w700, T.success, height: 1)), // proto #4ade80
            ]),
          ),
        ),
      ]);

  Widget _videoEmpty() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.video, size: 38, color: T.textDisabled),
          const SizedBox(height: 10),
          Text('🎥 탭해서 영상 선택', style: tx(14, FontWeight.w600, T.textDisabled, height: 1)),
          const SizedBox(height: 10),
          Text('최대 60초 · MP4, MOV', style: tx(12, FontWeight.w500, T.textDisabled, height: 1)),
        ],
      );

  // ── 캡션 ──
  Widget _captionSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '내용 입력',
            style: TextStyle(
              fontFamily: kFont, fontSize: 11, fontWeight: FontWeight.w600,
              letterSpacing: 0.55, color: T.textMuted, height: 1,
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 88),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(T.rLg),
            border: Border.all(color: T.borderDefault, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: TextField(
            controller: _caption,
            onChanged: (_) => setState(() {}),
            maxLines: null,
            minLines: 3,
            cursorColor: T.primary,
            style: tx(14, FontWeight.w500, T.textBody, height: 1.6),
            decoration: InputDecoration.collapsed(
              hintText: '이번 정기 대관 연습 찢었다.. 뒷풀이 고기까지 완벽했던 하루! #밴드 #홍대 #뒷풀이',
              hintStyle: tx(14, FontWeight.w500, T.textDisabled, height: 1.6),
            ),
          ),
        ),
      ]);

  // ── 장부 태깅 섹션 ──
  Widget _ledgerSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            const Icon(LucideIcons.coins, size: 16, color: T.primary),
            const SizedBox(width: 8),
            Text('이 영상과 관련된 모임/장부 태그', style: tx(14, FontWeight.w700, T.textStrong, height: 1)),
            const SizedBox(width: 8),
            Text('(선택)', style: tx(11, FontWeight.w500, T.textDisabled, height: 1)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RichText(
            text: TextSpan(
              style: tx(12, FontWeight.w500, T.textMuted, height: 1.5),
              children: [
                const TextSpan(text: '태그하면 영상 하단에 '),
                TextSpan(text: '투명 장부 인증 완료 🟢', style: tx(12, FontWeight.w700, T.success, height: 1.5)),
                const TextSpan(text: ' 마크가 표시돼요'),
              ],
            ),
          ),
        ),
        for (var i = 0; i < _ledgers.length; i++) ...[
          _ledgerCard(_ledgers[i]),
          if (i < _ledgers.length - 1) const SizedBox(height: 8),
        ],
        if (_selectedLedger != null) ...[
          const SizedBox(height: 12),
          _effectCallout(),
        ],
      ]);

  Widget _ledgerCard(_Ledger l) {
    final on = _selectedLedger == l.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedLedger = on ? null : l.id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: on ? T.primarySoft : T.white,
          borderRadius: BorderRadius.circular(T.rLg),
          border: Border.all(color: on ? T.primary : T.borderDefault, width: 1.5),
        ),
        child: Row(children: [
          // 라디오
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: on ? T.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: on ? T.primary : T.gray300, width: 2),
            ),
            child: on ? const Icon(LucideIcons.check, size: 11, color: T.white) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${l.date} ${l.title}', style: tx(13, FontWeight.w600, T.textTitle, height: 1.25)),
              const SizedBox(height: 3),
              Text('지출: ${won(l.amount)}원', style: tx(12, FontWeight.w500, T.textMuted, height: 1, tab: true)),
            ]),
          ),
          if (on) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: T.success.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(T.rPill),
                border: Border.all(color: T.success.withValues(alpha: 0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 5, height: 5, decoration: const BoxDecoration(color: T.success, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('인증 마크', style: tx(10, FontWeight.w700, T.successStrong, height: 1)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  // ── 효과 안내 ──
  Widget _effectCallout() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: T.success.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(T.rLg),
          border: Border.all(color: T.success.withValues(alpha: 0.2)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(LucideIcons.shieldCheck, size: 16, color: T.success),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: tx(12, FontWeight.w500, T.textBody, height: 1.55),
                children: [
                  TextSpan(text: '효과:', style: tx(12, FontWeight.w700, T.successStrong, height: 1.55)),
                  const TextSpan(text: ' 영상 하단에 '),
                  TextSpan(text: "'투명 장부 인증 완료 🟢'", style: tx(12, FontWeight.w700, T.success, height: 1.55)),
                  const TextSpan(text: ' 마크가 표시되어 외부 탐색 유저들에게 신뢰감을 줍니다.'),
                ],
              ),
            ),
          ),
        ]),
      );
}
