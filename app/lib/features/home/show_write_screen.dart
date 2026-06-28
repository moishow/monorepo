// 쇼 글쓰기 — prototype ShowWriteScreen (87338638:91).
// 작성자·태그 선택·본문 입력·사진 첨부·하단 게시 CTA.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';

class ShowWriteScreen extends StatefulWidget {
  const ShowWriteScreen({super.key});

  @override
  State<ShowWriteScreen> createState() => _ShowWriteScreenState();
}

class _ShowWriteScreenState extends State<ShowWriteScreen> {
  final TextEditingController _textCtrl = TextEditingController();
  String _tag = '봄MT';
  bool _hasPhoto = false;

  static const _tags = ['봄MT', '공연', '정산', '회식', '연습', '모집'];

  bool get _canPost => _textCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canPost) return;
    MoishoToast.show(context, '쇼에 새 글이 올라갔어요 ✨',
        tone: 'success', title: '게시글 업로드 완료!');
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.white,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(
          title: '쇼 글쓰기',
          onBack: () => Navigator.of(context).maybePop(),
          actions: [
            MinTapTarget(
              Text('게시',
                  style: tx(15, FontWeight.w700,
                      _canPost ? T.accent : T.textDisabled, height: 1)),
              onTap: _submit,
              min: 38,
            ),
          ],
        ),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              // 작성자
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(children: [
                  const MAvatar(name: '홍길동', tone: 'blue', size: 42),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('홍길동',
                          style: tx(14, FontWeight.w700, T.textTitle, height: 1.2)),
                      Text("홍대 연합 밴드 '사운드'",
                          style: tx(12, FontWeight.w500, T.textMuted, height: 1)),
                    ],
                  ),
                ]),
              ),

              // 태그 선택
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('태그',
                    style: TextStyle(
                        fontFamily: kFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.48,
                        color: T.textMuted,
                        height: 1)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in _tags)
                      MTag(
                        t,
                        tone: _tag == t ? 'purple' : 'neutral',
                        selectable: true,
                        selected: _tag == t,
                        leadingHash: true,
                        onTap: () => setState(() => _tag = t),
                      ),
                  ],
                ),
              ),

              // 본문 입력
              TextField(
                controller: _textCtrl,
                onChanged: (_) => setState(() {}),
                maxLines: null,
                minLines: 5,
                style: tx(15, FontWeight.w500, T.textBody, height: 1.6),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: '지금 무슨 일이 있나요? 동아리 소식을 공유해요!',
                  hintStyle: tx(15, FontWeight.w500, T.textDisabled, height: 1.6),
                ),
              ),

              // 사진 첨부
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: GestureDetector(
                  onTap: () => setState(() => _hasPhoto = !_hasPhoto),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(T.rLg),
                      color: _hasPhoto ? null : T.gray25,
                      gradient: _hasPhoto
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [T.purple50, T.blue50],
                            )
                          : null,
                      border: _hasPhoto
                          ? null
                          : Border.all(
                              color: T.borderDefault,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_hasPhoto ? LucideIcons.image : LucideIcons.camera,
                            size: 28,
                            color: _hasPhoto ? T.purple400 : T.textDisabled),
                        const SizedBox(height: 8),
                        Text(
                          _hasPhoto ? '사진 첨부됨 (탭하여 변경)' : '사진 추가하기',
                          style: tx(13, FontWeight.w600,
                              _hasPhoto ? T.purple400 : T.textDisabled,
                              height: 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        StickyBar(
          child: MButton('쇼에 게시하기',
              variant: 'accent', size: 'lg', block: true,
              disabled: !_canPost, onTap: _submit),
        ),
      ]),
    );
  }
}
