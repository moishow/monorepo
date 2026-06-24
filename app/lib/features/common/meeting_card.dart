// 공용 모임 카드 — prototype MeetingCard (f566565a). 탐색·홈 피드 공용.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/primitives.dart';

/// 동아리 출처 색 (clubTone → 색).
const clubColors = {
  'blue': T.blue500, 'mint': T.success, 'purple': T.purple500, 'orange': T.warning,
};

class Round {
  final String label, place;
  final int cur, max, cost;
  const Round(this.label, this.place, this.cur, this.max, this.cost);
}

class MeetingItem {
  final String title, author, tone, source, time, date, tag;
  final Object dday; // int 또는 "D-8"
  final String? club, clubTone, photo;
  final List<Round> rounds;
  // 탐색 필터용
  final double dist;
  final String cat, status;
  const MeetingItem({
    required this.title, required this.author, required this.tone, required this.source,
    required this.time, required this.date, required this.tag, required this.dday,
    this.club, this.clubTone, this.photo, required this.rounds,
    this.dist = 0, this.cat = '', this.status = 'recruiting',
  });

  bool get isFollow => source == 'follow';
}

class MeetingCard extends StatelessWidget {
  final MeetingItem item;
  final String? distLabel;
  final bool applied;
  final VoidCallback? onTap;
  const MeetingCard({super.key, required this.item, this.distLabel, this.applied = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isFollow = item.isFollow;
    final accentCol = isFollow ? T.warning : T.primary;
    final accentSoft = isFollow ? T.warningSoft : T.primarySoft;
    final dotColor = item.club != null ? (clubColors[item.clubTone] ?? accentCol) : accentCol;
    final d = ddayInfo(item.dday);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: MCard(
        padding: EdgeInsets.zero,
        borderColor: applied ? T.success : T.borderSubtle,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 출처 헤더
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: T.borderSubtle))),
              child: Row(children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Expanded(child: Text(item.club ?? '${item.author}님 팔로우', style: tx(11, FontWeight.w600, T.textMuted, height: 1))),
                if (distLabel != null) ...[
                  _pill('📍 $distLabel', T.primary, T.primarySoft),
                  const SizedBox(width: 6),
                ],
                _pill(isFollow ? '⚡ 번개' : '🏠 동아리', isFollow ? T.amber600 : T.primary, accentSoft),
                const SizedBox(width: 4),
                Text(item.time, style: tx(11, FontWeight.w500, T.textDisabled, height: 1)),
              ]),
            ),
            // 본문
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // 작성자 + 모임명 + dday
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  MAvatar(name: item.author, src: item.photo, tone: item.tone, size: 34),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.title, style: tx(15, FontWeight.w700, T.textStrong, height: 1.3)),
                      const SizedBox(height: 3),
                      Row(children: [
                        Flexible(child: Text(item.author, overflow: TextOverflow.ellipsis, style: tx(12, FontWeight.w600, T.textMuted, height: 1))),
                        const SizedBox(width: 4),
                        Text('주최', style: tx(11, FontWeight.w500, T.textDisabled, height: 1)),
                        const SizedBox(width: 6),
                        MTag(item.tag, tone: 'purple', leadingHash: true),
                      ]),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: d.bg, borderRadius: BorderRadius.circular(T.rMd)),
                    child: Text(d.label, style: tx(12, FontWeight.w700, d.color, height: 1)),
                  ),
                ]),
                const SizedBox(height: 10),
                // 날짜
                Row(children: [
                  Icon(LucideIcons.calendar, size: 13, color: accentCol),
                  const SizedBox(width: 6),
                  Text(item.date, style: tx(13, FontWeight.w600, T.textBody, height: 1)),
                ]),
                const SizedBox(height: 10),
                // 차수별 인원
                ...item.rounds.map((r) {
                  final rPct = (r.cur / r.max * 100).round();
                  final hot = rPct >= 80;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(color: T.gray50, borderRadius: BorderRadius.circular(T.rMd)),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: accentSoft, borderRadius: BorderRadius.circular(T.rPill)),
                          child: Text(r.label, style: tx(11, FontWeight.w700, accentCol, height: 1)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(r.place, maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(12, FontWeight.w600, T.textBody, height: 1.2)),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: (rPct / 100).clamp(0, 1),
                                minHeight: 3,
                                backgroundColor: T.gray200,
                                valueColor: AlwaysStoppedAnimation(hot ? T.danger : accentCol),
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(width: 8),
                        Text('${r.cur}/${r.max}', style: tx(11, FontWeight.w700, hot ? T.danger : T.textMuted, height: 1, tab: true)),
                      ]),
                    ),
                  );
                }),
                // 상세 보기
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('상세 보기', style: tx(12, FontWeight.w700, accentCol, height: 1)),
                  const SizedBox(width: 3),
                  Icon(LucideIcons.chevronRight, size: 13, color: accentCol),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color fg, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(T.rPill)),
        child: Text(text, style: tx(10, FontWeight.w700, fg, height: 1)),
      );
}
