// 총무 모임별 정산 — prototype TreasurerMeetingsScreen (6c5465b6:191).
// 내가 총무로 모집한 모임 목록 → 정산할 모임 선택.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import 'treasurer_screen.dart';

class _Meeting {
  final String id, name, club, date, state, note;
  final int paid, total, amount;
  const _Meeting(this.id, this.name, this.club, this.date, this.state, this.paid, this.total, this.amount, this.note);
}

class _StateCfg {
  final String tone, label;
  final Color color;
  const _StateCfg(this.tone, this.label, this.color);
}

class TreasurerMeetingsScreen extends StatelessWidget {
  const TreasurerMeetingsScreen({super.key});

  // ── 내가 총무인 모임(프로토타입 meetings 리터럴) ──
  static const _meetings = [
    _Meeting('m1', '정기 합주 & 뒷풀이', '사운드 동아리', '06.22', 'consent', 6, 8, 320000, '출금 동의 6/8'),
    _Meeting('m2', '6월 정기 대관 연습', '사운드 동아리', '06.18', 'locked', 7, 7, 280000, '출금 가능'),
    _Meeting('m3', '신입 환영 MT', '사운드 동아리', '06.30', 'open', 12, 20, 480000, '모집 중 · D-7'),
    _Meeting('m4', '봄 시즌 마감 번개', '번개', '06.10', 'settling', 9, 9, 180000, '정산 진행 중'),
  ];

  static const _stateCfg = <String, _StateCfg>{
    'open': _StateCfg('neutral', '모집 중', T.textMuted),
    'locked': _StateCfg('blue', '출금 가능', T.primary), // proto tone "primary"
    'consent': _StateCfg('warning', '동의 수집', T.amber600), // proto #B45309
    'settling': _StateCfg('success', '정산 중', T.successStrong),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '총무 정산 관리', onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 16, T.padScreen, 24),
            children: [
              // 안내 배너
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(T.rMd)),
                child: Row(children: [
                  const Icon(LucideIcons.shieldCheck, size: 16, color: T.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('내가 총무로 모집한 모임이에요. 정산할 모임을 선택하세요.',
                        style: tx(12, FontWeight.w500, T.primary, height: 1.5)),
                  ),
                ]),
              ),
              const SectionLabel('내가 총무인 모임 4'),
              for (var i = 0; i < _meetings.length; i++) ...[
                _meetingCard(context, _meetings[i]),
                if (i < _meetings.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ]),
    );
  }

  Widget _meetingCard(BuildContext context, _Meeting m) {
    final cfg = _stateCfg[m.state]!;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TreasurerScreen()),
      ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: T.white,
          borderRadius: BorderRadius.circular(T.rXl),
          border: Border.all(color: T.borderDefault, width: 1.5),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                MBadge(cfg.label, tone: cfg.tone, variant: 'soft'),
                const SizedBox(width: 6),
                Flexible(
                  child: Text('${m.club} · ${m.date}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tx(11, FontWeight.w500, T.textDisabled, height: 1)),
                ),
              ]),
              const SizedBox(height: 5),
              Text(m.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tx(15, FontWeight.w700, T.textStrong, height: 1.3)),
              const SizedBox(height: 4),
              Row(children: [
                Text('${won(m.amount)}원', style: tx(12, FontWeight.w600, cfg.color, height: 1, tab: true)),
                const SizedBox(width: 10),
                Flexible(
                  child: Text('예치 ${m.paid}/${m.total}명 · ${m.note}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tx(11.5, FontWeight.w500, T.textMuted, height: 1)),
                ),
              ]),
            ]),
          ),
          const SizedBox(width: 12),
          const Icon(LucideIcons.chevronRight, size: 18, color: T.textMuted),
        ]),
      ),
    );
  }
}
