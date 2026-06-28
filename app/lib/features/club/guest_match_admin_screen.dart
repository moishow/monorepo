// 게스트 매칭 관리자 뷰 — F2-2 (신규, /spec 08 §3).
// 관리자가 게스트 신청자를 보고 체험 날짜를 투표로 정한다: 신청자 리스트 · 날짜 투표(ProgressBar) · 종료상태(동점/정족수미달) · 번개 개최.
// 머니수학 없음. 신뢰배지는 서버 제공값을 그대로 표시(클라 계산 금지, 07 §2-4). 번개 개최는 시뮬레이션.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import '../meeting/meeting_detail_screen.dart';

class _Applicant {
  final String name, intro, photo, trust;
  const _Applicant(this.name, this.intro, this.photo, this.trust);
}

class _DateOption {
  final String label, sub;
  final int votes;
  const _DateOption(this.label, this.sub, this.votes);
}

const _applicants = [
  _Applicant('김지망', '보컬 지망, 합주 경험 있어요',
      'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=100&h=100&fit=crop&crop=face&auto=format&q=80', '매너온도 36.5℃'),
  _Applicant('이체험', '베이스 쳐요. 분위기 보러 왔어요!',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop&crop=face&auto=format&q=80', '첫 활동'),
  _Applicant('박관심', '기타 5년차, 정기 합주 함께하고 싶어요',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop&crop=face&auto=format&q=80', '매너온도 37.2℃'),
];

// 날짜 투표 후보 — 7/5·7/6 동점(각 4표), 7/12 1표. (spec §5 f2_datePoll)
const _fullOptions = [
  _DateOption('7월 5일 (토)', '오후 2시 · 홍대 사운드스튜디오', 4),
  _DateOption('7월 6일 (일)', '오후 2시 · 홍대 사운드스튜디오', 4),
  _DateOption('7월 12일 (토)', '오후 2시 · 합정 합주실', 1),
];
// 정족수 미달 데모 데이터 — 최다 1표 < 정족수 3표.
const _lowOptions = [
  _DateOption('7월 5일 (토)', '오후 2시 · 홍대 사운드스튜디오', 1),
  _DateOption('7월 6일 (일)', '오후 2시 · 홍대 사운드스튜디오', 1),
  _DateOption('7월 12일 (토)', '오후 2시 · 합정 합주실', 0),
];
const int _quorum = 3;

class GuestMatchAdminScreen extends StatefulWidget {
  const GuestMatchAdminScreen({super.key});

  @override
  State<GuestMatchAdminScreen> createState() => _GuestMatchAdminScreenState();
}

class _GuestMatchAdminScreenState extends State<GuestMatchAdminScreen> {
  int? _winner; // 관리자 수동 확정 인덱스(동점 해소·오버라이드)
  bool _lowTurnout = false; // 데모: 정족수 미달 상태 미리보기
  bool _opened = false; // 투표 마감 & 번개 개최됨(FLASH_CREATED)

  List<_DateOption> get _opts => _lowTurnout ? _lowOptions : _fullOptions;
  int get _maxVotes => _opts.map((o) => o.votes).fold(0, (a, b) => a > b ? a : b);
  List<int> get _leaders => [for (var i = 0; i < _opts.length; i++) if (_opts[i].votes == _maxVotes) i];
  bool get _quorumMet => _maxVotes >= _quorum;
  bool get _isTie => _quorumMet && _winner == null && _leaders.length > 1;
  int? get _effWinner => _winner ?? (_quorumMet && _leaders.length == 1 ? _leaders.first : null);
  bool get _canOpen => !_opened && _effWinner != null;

  // 현재 상태 라벨(POLL 상태머신 표시)
  ({String label, String tone}) get _state {
    if (_opened) return (label: 'FLASH_CREATED', tone: 'success');
    if (!_quorumMet) return (label: 'POLL_OPEN', tone: 'neutral');
    if (_isTie) return (label: 'POLL_TIE', tone: 'warning');
    return (label: 'POLL_OPEN', tone: 'blue');
  }

  void _pick(int i) {
    if (!_quorumMet || _opened) return;
    setState(() => _winner = i);
  }

  void _toggleLowTurnout() => setState(() {
        _lowTurnout = !_lowTurnout;
        _winner = null;
      });

  void _revote() => MoishoToast.show(context, '부원들에게 재투표 알림을 보냈어요.', tone: 'info');

  void _openFlash() {
    if (!_canOpen) return;
    final win = _opts[_effWinner!];
    setState(() => _opened = true);
    MoishoToast.show(context, '${win.label} 단발성 번개를 개최했어요. 신청 게스트에게 5,000원 예약금 안내가 발송돼요.',
        tone: 'success', title: '번개 개최 완료 🎉');
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => MeetingDetailScreen(title: '게스트 환영 번개 · ${win.label}', club: "홍대 연합 밴드 '사운드'"),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '게스트 매칭', onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 18, T.padScreen, 24),
            children: [
              _applicantsHeader(),
              const SizedBox(height: 10),
              for (var i = 0; i < _applicants.length; i++) ...[
                _applicantCard(_applicants[i]),
                if (i < _applicants.length - 1) const SizedBox(height: 8),
              ],
              const SizedBox(height: 24),
              _pollHeader(),
              const SizedBox(height: 12),
              _stateBanner(),
              const SizedBox(height: 12),
              for (var i = 0; i < _opts.length; i++) ...[
                _dateRow(i),
                if (i < _opts.length - 1) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        StickyBar(
          child: MButton(
            _opened ? '번개가 개최됐어요' : '투표 마감 & 번개 개최',
            variant: 'primary',
            size: 'lg',
            block: true,
            disabled: !_canOpen,
            leadingIcon: Icon(LucideIcons.zap, size: 17, color: _canOpen ? T.white : T.textDisabled),
            onTap: _openFlash,
          ),
        ),
      ]),
    );
  }

  // ── 신청자 헤더 ──
  Widget _applicantsHeader() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          const Icon(LucideIcons.userPlus, size: 16, color: T.primary),
          const SizedBox(width: 6),
          Text('체험 신청자', style: tx(14, FontWeight.w700, T.textTitle, height: 1)),
          const SizedBox(width: 6),
          MBadge('${_applicants.length}명', tone: 'blue', variant: 'soft'),
        ]),
        Text('신뢰 정보는 서버 제공값', style: tx(10.5, FontWeight.w500, T.textDisabled, height: 1)),
      ]);

  Widget _applicantCard(_Applicant a) => MCard(
        elevation: 'raised',
        radius: T.rXl,
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          MAvatar(name: a.name, src: a.photo, size: 42, tone: 'blue'),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Text(a.name, style: tx(14, FontWeight.w700, T.textStrong, height: 1)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: T.gray50, borderRadius: BorderRadius.circular(T.rPill)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(LucideIcons.thermometer, size: 10, color: T.textMuted),
                    const SizedBox(width: 3),
                    Text(a.trust, style: tx(10.5, FontWeight.w600, T.textMuted, height: 1)),
                  ]),
                ),
              ]),
              const SizedBox(height: 5),
              Text(a.intro, style: tx(12.5, FontWeight.w500, T.textBody, height: 1.4)),
            ]),
          ),
        ]),
      );

  // ── 날짜 투표 헤더 + 상태칩 + 데모 토글 ──
  Widget _pollHeader() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          const Icon(LucideIcons.calendarCheck, size: 16, color: T.primary),
          const SizedBox(width: 6),
          Text('체험 날짜 투표', style: tx(14, FontWeight.w700, T.textTitle, height: 1)),
          const SizedBox(width: 6),
          MBadge(_state.label, tone: _state.tone, variant: 'soft'),
        ]),
        GestureDetector(
          onTap: _toggleLowTurnout,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: _lowTurnout ? T.warningSoft : T.gray50,
              borderRadius: BorderRadius.circular(T.rPill),
              border: Border.all(color: _lowTurnout ? T.amber100 : T.borderSubtle),
            ),
            child: Text(_lowTurnout ? '정족수 미달 보기 ✓' : '정족수 미달 보기',
                style: tx(10.5, FontWeight.w600, _lowTurnout ? T.amber600 : T.textMuted, height: 1)),
          ),
        ),
      ]);

  // ── 종료상태 배너(정족수 미달 / 동점 / 선정 완료) ──
  Widget _stateBanner() {
    final IconData icon;
    final Color bg, border, fg;
    final String msg;
    Widget? trailing;
    if (!_quorumMet) {
      icon = LucideIcons.hourglass;
      bg = T.warningSoft;
      border = T.amber100;
      fg = T.amber600;
      msg = '아직 정족수 미달이에요. 최다 $maxVotesLabel / 정족수 $_quorum표 — 투표를 더 모아 주세요.';
    } else if (_isTie) {
      icon = LucideIcons.scale;
      bg = T.warningSoft;
      border = T.amber100;
      fg = T.amber600;
      msg = '동점이에요. 날짜를 직접 골라 확정하거나, 재투표를 요청하세요.';
      trailing = GestureDetector(
        onTap: _revote,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: T.white, borderRadius: BorderRadius.circular(T.rPill), border: Border.all(color: T.amber100)),
          child: Text('재투표', style: tx(11, FontWeight.w700, T.amber600, height: 1)),
        ),
      );
    } else {
      icon = LucideIcons.circleCheck;
      bg = T.successSoft;
      border = T.mint100;
      fg = T.success;
      msg = "‘${_opts[_effWinner!].label}’ 날짜로 번개를 개최할 수 있어요.";
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(T.rLg), border: Border.all(color: border, width: 1.5)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Icon(icon, size: 16, color: fg),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: tx(11.5, FontWeight.w600, fg, height: 1.5))),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ]),
    );
  }

  String get maxVotesLabel => '$_maxVotes표';

  // ── 날짜 후보 행(득표 ProgressBar + 선택) ──
  Widget _dateRow(int i) {
    final o = _opts[i];
    final isWinner = _effWinner == i;
    final share = _maxVotes == 0 ? 0.0 : o.votes / _maxVotes * 100;
    return GestureDetector(
      onTap: () => _pick(i),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: isWinner ? T.primarySoft : T.white,
          borderRadius: BorderRadius.circular(T.rXl),
          border: Border.all(color: isWinner ? T.primary : T.borderDefault, width: isWinner ? 2 : 1.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isWinner ? T.primary : T.white,
                shape: BoxShape.circle,
                border: Border.all(color: isWinner ? T.primary : T.borderDefault, width: 2),
              ),
              child: isWinner ? const Icon(LucideIcons.check, size: 12, color: T.white) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o.label, style: tx(14, FontWeight.w700, T.textStrong, height: 1.2)),
                const SizedBox(height: 2),
                Text(o.sub, style: tx(11, FontWeight.w500, T.textMuted, height: 1.2)),
              ]),
            ),
            const SizedBox(width: 8),
            Text('${o.votes}표',
                style: tx(14, FontWeight.w700, isWinner ? T.primary : T.textBody, height: 1, tab: true)),
          ]),
          const SizedBox(height: 10),
          ProgressBar(value: share, height: 8, tone: isWinner ? 'primary' : 'accent'),
        ]),
      ),
    );
  }
}
