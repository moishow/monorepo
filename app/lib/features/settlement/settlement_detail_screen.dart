// 정산 상세 — prototype SettlementDetailScreen (87338638:419).
// 결정1(전액출금 모델) 투명장부: 취합 → 전액출금 → 실지출 → 반납 → 1인당 균등 환급.
// F3-1(07 C-k): 프로토타입의 광고 레이아웃·"출금 직후 광고대기" 단계는 의도적으로 없음 — 재도입 금지.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';

class _Item {
  final String label;
  final int amount;
  const _Item(this.label, this.amount);
}

class SettlementDetailScreen extends StatelessWidget {
  const SettlementDetailScreen({super.key});

  // ── 데이터(프로토타입 리터럴) ──
  static const _items = [
    _Item('합주실 대관료', 150000),
    _Item('뒷풀이 식비 (인원 정산)', 210000),
  ];
  static const _members = [
    '김회장', '이총무', '박소심', '최부원', '정디자',
    '장열심', '오빠름', '정건망', '한노쇼', '이땡땡',
  ];
  // 투명장부 5행 [라벨, 값, accent] — 취합·전액출금·실지출·반납·1인당(결정1 순서)
  static const _summary = [
    ('취합 총액', '400,000원', false),
    ('전액 출금', '400,000원', false),
    ('실지출', '360,000원', false),
    ('반납 잔액', '40,000원', true),
    ('1인당 환급', '+4,000원', true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(
          title: '정산 상세',
          onBack: () => Navigator.of(context).maybePop(),
          actions: [
            MinTapTarget(
              const Icon(LucideIcons.download, size: 20, color: T.textMuted),
              onTap: () => MoishoToast.show(context, '준비 중', tone: 'info'),
              min: 38,
            ),
          ],
        ),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 16, T.padScreen, 24),
            children: [
              _summaryCard(),
              const SizedBox(height: 14),
              const SectionLabel('영수증 증빙'),
              _receiptThumb(context),
              const SizedBox(height: 14),
              const SectionLabel('지출 항목'),
              _itemsCard(),
              const SizedBox(height: 14),
              SectionLabel('부원별 정산 (${_members.length}명)'),
              _membersCard(),
            ],
          ),
        ),
      ]),
    );
  }

  // ── 요약(투명장부) ──
  Widget _summaryCard() => MCard(
        elevation: 'raised',
        radius: T.rXl,
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('정기 대관 연습 및 뒷풀이', style: tx(17, FontWeight.w700, T.textStrong, height: 1.2)),
          const SizedBox(height: 4),
          Text('2026. 06. 15 · 홍대 사운드스튜디오', style: tx(13, FontWeight.w500, T.textMuted, height: 1)),
          // 장부 흐름 캡션(전액출금 모델 가독성)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(T.rMd)),
            child: Row(children: [
              const Icon(LucideIcons.listChecks, size: 13, color: T.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text('취합 → 전액 출금 → 실지출 → 반납 → 1인당 균등 환급',
                    style: tx(12, FontWeight.w600, T.primary, height: 1.3)),
              ),
            ]),
          ),
          const SizedBox(height: 4),
          for (final (label, value, accent) in _summary)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: T.borderSubtle))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(label, style: tx(13, FontWeight.w500, T.textBody, height: 1)),
                Text(value, style: tx(14, FontWeight.w700, accent ? T.primary : T.textStrong, height: 1, tab: true)),
              ]),
            ),
        ]),
      );

  // ── 영수증 썸네일(증빙 진입) ──
  Widget _receiptThumb(BuildContext context) => GestureDetector(
        onTap: () => MoishoToast.show(context, '원본 영수증을 봤어요. 금액·가게·일시를 확인하세요.', tone: 'neutral'),
        behavior: HitTestBehavior.opaque,
        child: MCard(
          elevation: 'outline',
          radius: T.rXl,
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 44, height: 56,
              decoration: BoxDecoration(
                color: T.surfaceSunken,
                borderRadius: BorderRadius.circular(T.rMd),
                border: Border.all(color: T.borderDefault),
              ),
              alignment: Alignment.center,
              child: const Icon(LucideIcons.receipt, size: 22, color: T.textFaint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('영수증 증빙 1장', style: tx(14, FontWeight.w700, T.textStrong, height: 1.1)),
                const SizedBox(height: 3),
                Text('실지출 360,000원 · OCR 검증 완료', style: tx(12, FontWeight.w500, T.textMuted, height: 1)),
              ]),
            ),
            Row(children: [
              Text('원본 보기', style: tx(12, FontWeight.w600, T.primary, height: 1)),
              const Icon(LucideIcons.chevronRight, size: 16, color: T.primary),
            ]),
          ]),
        ),
      );

  // ── 지출 항목 ──
  Widget _itemsCard() => MCard(
        elevation: 'outline',
        radius: T.rXl,
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          for (var i = 0; i < _items.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(border: i > 0 ? const Border(top: BorderSide(color: T.borderSubtle)) : null),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  const Icon(LucideIcons.receipt, size: 14, color: T.primary),
                  const SizedBox(width: 6),
                  Text(_items[i].label, style: tx(13, FontWeight.w500, T.textBody, height: 1)),
                ]),
                Text('${won(_items[i].amount)}원', style: tx(14, FontWeight.w700, T.textStrong, height: 1, tab: true)),
              ]),
            ),
        ]),
      );

  // ── 부원별 정산 ──
  Widget _membersCard() => MCard(
        elevation: 'outline',
        radius: T.rXl,
        padding: EdgeInsets.zero,
        child: Column(children: [
          for (var i = 0; i < _members.length; i++)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                border: i < _members.length - 1 ? const Border(bottom: BorderSide(color: T.borderSubtle)) : null,
              ),
              child: Row(children: [
                MAvatar(name: _members[i], size: 34),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_members[i], style: tx(14, FontWeight.w600, T.textTitle, height: 1)),
                    const SizedBox(height: 2),
                    Text('납부 40,000원', style: tx(12, FontWeight.w500, T.textMuted, height: 1)),
                  ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('+4,000원', style: tx(13, FontWeight.w700, T.primary, height: 1, tab: true)),
                  const SizedBox(height: 3),
                  const MBadge('완료', tone: 'success', variant: 'soft'),
                ]),
              ]),
            ),
        ]),
      );
}
