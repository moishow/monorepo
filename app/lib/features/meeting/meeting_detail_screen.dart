// 모임 상세 — prototype MeetingDetailScreen (87338638:809).
// 커버·내 상태·동아리 바로가기·핵심정보·주최자·소개·차수별 참여·비용내역·규칙·하단 CTA.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import '../club/club_detail_screen.dart';
import '../social/public_profile_screen.dart';
import 'meeting_apply_screen.dart';

class _P {
  final String name, photo;
  const _P(this.name, this.photo);
}

class _Round {
  final int id;
  final String label, title, time, place;
  final int cost, max;
  final List<_P> participants;
  const _Round(this.id, this.label, this.title, this.time, this.place, this.cost, this.max, this.participants);
}

class MeetingDetailScreen extends StatefulWidget {
  /// 카드에서 넘어올 때 헤더 정보 일부를 덮어쓸 수 있음(프로토타입 navData).
  final String? title;
  final String? club;
  final String status; // none | applied | deposited | locked
  const MeetingDetailScreen({super.key, this.title, this.club, this.status = 'none'});

  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen> {
  bool _liked = false;
  late String _status = widget.status;
  int _activeRound = 1;
  static const int _myDeposit = 40000;

  // 시간별 취소 위약금 티어(결정1) — deposit_confirm의 카드와 byte-identical 유지.
  static const _penaltyTiers = [
    (label: '신청 마감 ~ 24시간 전', fromHrs: 24, rate: 0),
    (label: '24시간 ~ 6시간 전', fromHrs: 6, rate: 50),
    (label: '6시간 전 ~ 만남 시각', fromHrs: 0, rate: 100),
  ];
  static const int _hrsToMeeting = 72; // _dday 'D-3'과 연동(72h) — 마감 24h 이전 구간

  int get _tierIdx {
    for (var i = 0; i < _penaltyTiers.length; i++) {
      if (_hrsToMeeting >= _penaltyTiers[i].fromHrs) return i;
    }
    return _penaltyTiers.length - 1;
  }

  int get _penalty => (_myDeposit * _penaltyTiers[_tierIdx].rate / 100).round(); // 정수 원 보장
  int get _refundAfterPenalty => _myDeposit - _penalty;

  bool get _isIn => _status == 'applied' || _status == 'deposited';
  bool get _applied => _isIn || _status == 'locked';

  // ── 모임 데이터(프로토타입 MEETING 리터럴) ──
  static const _tag = '공연';
  static const _dday = 'D-3';
  static const _date = '2026년 6월 15일 (토) 18:00';
  static const _place = '홍대 사운드스튜디오 B1 합주실';
  static const _cost = 40000;
  static const _max = 12;
  static const _cover = 'https://images.unsplash.com/photo-1501612780327-45045538702b?w=800&h=320&fit=crop&auto=format&q=80';
  static const _hostName = '박회장';
  static const _hostPhoto = 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop&crop=face&auto=format&q=80';
  static const _hostTemp = 38.0;
  static const _description =
      '매달 진행하는 정기 합주 + 뒷풀이입니다!\n\n'
      '이번 달은 6월 공연 준비 마지막 합주로, 세트리스트 전곡 완주가 목표예요. 합주 종료 후 근처 이자카야에서 뒷풀이도 함께 해요 🍻\n\n'
      '• 합주 파트: 보컬·기타·베이스·드럼·키보드\n'
      '• 녹음 후 단톡 공유 예정\n'
      '• 뒷풀이 불참 시 사전 공지 부탁드려요';
  static const _costBreakdown = [
    ('홍대 사운드스튜디오 대관료 (3h)', 270000),
    ('뒷풀이 식비 (이자카야 추산)', 210000),
  ];
  static const _rules = [
    '정시 참석 (5분 전까지 스튜디오 입장)',
    '악기·장비 개인 지참',
    '취소 시 D-2 이전 알림 필수',
    '회비 미예치 시 참석 불가',
  ];
  static const _rounds = [
    _Round(1, '1차', '합주실 정기 합주', '18:00 ~ 21:00', '홍대 사운드스튜디오 B1', 27000, 12, [
      _P('김회장', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&h=80&fit=crop&crop=face&auto=format&q=80'),
      _P('이총무', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&h=80&fit=crop&crop=face&auto=format&q=80'),
      _P('정디자', 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=80&h=80&fit=crop&crop=face&auto=format&q=80'),
      _P('장열심', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=80&h=80&fit=crop&crop=face&auto=format&q=80'),
      _P('최부원', 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=80&h=80&fit=crop&crop=face&auto=format&q=80'),
      _P('오빠름', 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=80&h=80&fit=crop&crop=face&auto=format&q=80'),
      _P('박소심', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=80&h=80&fit=crop&crop=face&auto=format&q=80'),
    ]),
    _Round(2, '2차', '이자카야 뒷풀이', '21:30 ~ ', '근처 이자카야 (추후 확정)', 18000, 10, [
      _P('김회장', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&h=80&fit=crop&crop=face&auto=format&q=80'),
      _P('이총무', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&h=80&fit=crop&crop=face&auto=format&q=80'),
      _P('장열심', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=80&h=80&fit=crop&crop=face&auto=format&q=80'),
      _P('오빠름', 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=80&h=80&fit=crop&crop=face&auto=format&q=80'),
    ]),
  ];

  String get _title => widget.title ?? '6월 정기 합주 & 뒷풀이';
  String get _club => widget.club ?? "홍대 연합 밴드 '사운드'";
  int get _totalParticipants => _rounds.fold(0, (s, r) => s + r.participants.length);
  int get _pct => (_totalParticipants / _max * 100).round();
  int get _total => _costBreakdown.fold(0, (s, c) => s + c.$2);
  int get _perHead => (_total / _max / 100).ceil() * 100;

  Future<void> _cancelDeposit() async {
    // 결정1: '언제든 자유 취소' 제거 — 시간별 위약금 시뮬 → 확인 시트 → 환불(예치−위약금).
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: _buildCancelSheet,
    );
    if (confirmed != true || !mounted) return;
    setState(() => _status = 'none');
    final msg = _penalty > 0
        ? '위약금 ${won(_penalty)}P를 제하고 ${won(_refundAfterPenalty)}P가 환불됐어요. 위약금은 그룹 공동비용에 충당돼요.'
        : '${won(_refundAfterPenalty)}P가 전액 환불됐어요. (마감 24시간 전 · 위약금 0)';
    MoishoToast.show(context, msg, tone: 'success');
  }

  // ── 예치 취소 확인 시트(시간별 위약금 안내) ──
  Widget _buildCancelSheet(BuildContext sheetCtx) {
    final bottom = MediaQuery.of(sheetCtx).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: T.surfacePage,
        borderRadius: BorderRadius.vertical(top: Radius.circular(T.r2xl)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
          child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: T.borderDefault, borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(height: 16),
        Text('예치 취소 — 위약금 안내', style: tx(17, FontWeight.w700, T.textStrong, height: 1.2)),
        const SizedBox(height: 6),
        Text('지금 취소하면 아래 기준으로 환불돼요. (현재 $_dday · 마감 24시간 전)',
            style: tx(13, FontWeight.w500, T.textMuted, height: 1.4)),
        const SizedBox(height: 16),
        for (var i = 0; i < _penaltyTiers.length; i++) _tierRow(i),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: T.surfaceSunken, borderRadius: BorderRadius.circular(T.rLg)),
          child: Column(children: [
            _calcRow('예치금', '${won(_myDeposit)}P', T.textTitle),
            const SizedBox(height: 8),
            _calcRow('위약금 (현재 ${_penaltyTiers[_tierIdx].rate}%)', '−${won(_penalty)}P',
                _penalty == 0 ? T.textMuted : T.danger),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('환불 예상액', style: tx(14, FontWeight.w700, T.textTitle, height: 1)),
              Text('${won(_refundAfterPenalty)}P', style: tx(18, FontWeight.w700, T.primary, height: 1, tab: true)),
            ]),
          ]),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: T.surfaceSunken, borderRadius: BorderRadius.circular(T.rMd)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(LucideIcons.users, size: 14, color: T.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text('위약금은 남은 부원들의 그룹 공동비용에 충당돼요. 플랫폼·총무에 귀속되지 않아요(0원).',
                  style: tx(12, FontWeight.w500, T.textBody, height: 1.45)),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: MButton('닫기', variant: 'secondary', size: 'lg', block: true,
                onTap: () => Navigator.of(sheetCtx).pop(false)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: MButton('취소하고 환불받기', variant: 'danger', size: 'lg', block: true,
                onTap: () => Navigator.of(sheetCtx).pop(true)),
          ),
        ]),
      ]),
    );
  }

  Widget _tierRow(int i) {
    final t = _penaltyTiers[i];
    final isCurrent = i == _tierIdx;
    final rateColor = t.rate == 0
        ? T.successStrong
        : t.rate == 100
            ? T.danger
            : T.amber600;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrent ? T.primarySoft : T.surfaceSunken,
        borderRadius: BorderRadius.circular(T.rMd),
        border: isCurrent ? Border.all(color: T.primary, width: 1.5) : null,
      ),
      child: Row(children: [
        if (isCurrent) ...[
          const Icon(LucideIcons.arrowRight, size: 13, color: T.primary),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(t.label,
              style: tx(13, isCurrent ? FontWeight.w700 : FontWeight.w500, isCurrent ? T.textStrong : T.textBody, height: 1.2)),
        ),
        Text('위약금 ${t.rate}%', style: tx(13, FontWeight.w700, rateColor, height: 1, tab: true)),
      ]),
    );
  }

  Widget _calcRow(String label, String value, Color valueColor) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: tx(13, FontWeight.w500, T.textMuted, height: 1)),
          Text(value, style: tx(14, FontWeight.w600, valueColor, height: 1, tab: true)),
        ],
      );

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
          title: '모임 상세',
          onBack: () => Navigator.of(context).maybePop(),
          actions: [
            MinTapTarget(
              Icon(LucideIcons.heart, size: 22, color: _liked ? T.danger : T.textMuted),
              onTap: () => setState(() => _liked = !_liked),
              min: 38,
            ),
            MinTapTarget(
              const Icon(LucideIcons.share2, size: 20, color: T.textMuted),
              onTap: () => MoishoToast.show(context, '링크가 복사됐어요!', tone: 'info'),
              min: 38,
            ),
          ],
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildCover(),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (_status != 'none') ...[_statusBanner(), const SizedBox(height: 14)],
                  _clubShortcut(),
                  const SizedBox(height: 14),
                  _coreInfo(),
                  const SizedBox(height: 18),
                  _section(LucideIcons.user, '주최자', _hostCard()),
                  const SizedBox(height: 18),
                  _section(LucideIcons.fileText, '모임 소개', _descCard()),
                  const SizedBox(height: 18),
                  _participants(),
                  const SizedBox(height: 18),
                  _section(LucideIcons.receipt, '비용 내역', _costCard()),
                  const SizedBox(height: 18),
                  _rulesSection(),
                  const SizedBox(height: 24),
                ]),
              ),
            ],
          ),
        ),
        _cta(),
      ]),
    );
  }

  // ── 커버 이미지 ──
  Widget _buildCover() => SizedBox(
        height: 180,
        child: Stack(fit: StackFit.expand, children: [
          NetImage(url: _cover, fit: BoxFit.cover, fallback: Container(color: T.gray100)),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter, end: Alignment.topCenter,
                colors: [Color(0x99000000), Color(0x00000000)], stops: [0, 0.6],
              ),
            ),
          ),
          Positioned(
            left: 18, right: 18, bottom: 14,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _coverChip('🏠 동아리 모임'),
                const SizedBox(width: 6),
                _coverChip('#$_tag'),
              ]),
              const SizedBox(height: 8),
              Text(_title, style: tx(20, FontWeight.w700, T.white, ls: -0.02, height: 1.2)),
            ]),
          ),
          Positioned(
            top: 12, right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: T.danger, borderRadius: BorderRadius.circular(T.rMd)),
              child: Text(_dday, style: tx(13, FontWeight.w700, T.white, height: 1)),
            ),
          ),
        ]),
      );

  Widget _coverChip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(T.rPill)),
        child: Text(text, style: tx(10, FontWeight.w700, T.white, height: 1)),
      );

  // ── 내 참여 상태 ──
  Widget _statusBanner() {
    final cfg = {
      'applied': (bg: T.warningSoft, color: T.amber600, icon: LucideIcons.clock, label: '신청 중', desc: '예치 처리 중이에요. 잠시만 기다려주세요.'),
      'deposited': (bg: T.primarySoft, color: T.primary, icon: LucideIcons.shieldCheck, label: '예치 중', desc: '신청 마감 24시간 전까진 전액 환불, 이후엔 시간별 위약금이 차감돼요.'),
      'locked': (bg: T.gray100, color: T.textMuted, icon: LucideIcons.lock, label: '예치 잠김', desc: '만남 시각이 지나 취소할 수 없어요.'),
    }[_status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(color: cfg.bg, borderRadius: BorderRadius.circular(T.rXl)),
      child: Row(children: [
        Icon(cfg.icon, size: 19, color: cfg.color),
        const SizedBox(width: 11),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('내 상태 · ${cfg.label}', style: tx(13, FontWeight.w700, cfg.color, height: 1.2)),
            const SizedBox(height: 3),
            Text(cfg.desc, style: tx(11.5, FontWeight.w500, T.textMuted, height: 1.4)),
          ]),
        ),
        const SizedBox(width: 8),
        Text('${won(_myDeposit)}P', style: tx(14, FontWeight.w700, cfg.color, height: 1, tab: true)),
      ]),
    );
  }

  // ── 동아리 바로가기 ──
  Widget _clubShortcut() => GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ClubDetailScreen())),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: T.primarySoft,
            borderRadius: BorderRadius.circular(T.rXl),
            border: Border.all(color: T.primary, width: 1.5),
          ),
          child: Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: T.primary, borderRadius: BorderRadius.circular(T.rMd)),
              child: const Icon(LucideIcons.users, size: 15, color: T.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_club, style: tx(13, FontWeight.w700, T.primary, height: 1.2)),
                const SizedBox(height: 2),
                Text('동아리 상세 페이지 보기', style: tx(11, FontWeight.w500, T.textMuted, height: 1)),
              ]),
            ),
            const Icon(LucideIcons.chevronRight, size: 16, color: T.primary),
          ]),
        ),
      );

  // ── 핵심 정보 ──
  Widget _coreInfo() {
    final dense = _pct >= 80;
    final rows = [
      (LucideIcons.calendar, _date, T.primary),
      (LucideIcons.mapPin, _place, T.primary),
      (LucideIcons.coins, '인당 ${won(_cost)}원 (최종 정산 후 확정)', T.primary),
      (LucideIcons.users, '$_totalParticipants/$_max명 참여 중', dense ? T.danger : T.primary),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: T.white,
        borderRadius: BorderRadius.circular(T.rXl),
        border: Border.all(color: T.borderSubtle),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final (icon, val, col) in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(color: T.primarySoft, borderRadius: BorderRadius.circular(T.rMd)),
                child: Icon(icon, size: 14, color: col),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(val, style: tx(13, FontWeight.w600, T.textBody, height: 1.3))),
            ]),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: _pct / 100, minHeight: 6,
            backgroundColor: T.gray100,
            valueColor: AlwaysStoppedAnimation(dense ? T.danger : T.primary),
          ),
        ),
        const SizedBox(height: 5),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('잔여 ${_max - _totalParticipants}자리', style: tx(10, FontWeight.w500, T.textDisabled, height: 1)),
          if (dense) Text('⚠ 마감 임박!', style: tx(10, FontWeight.w700, T.danger, height: 1)),
        ]),
      ]),
    );
  }

  // ── 섹션 래퍼(라벨 + 본문) ──
  Widget _section(IconData icon, String label, Widget body) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            Icon(icon, size: 14, color: T.textMuted),
            const SizedBox(width: 6),
            Text(label, style: tx(13, FontWeight.w700, T.textTitle, height: 1)),
          ]),
        ),
        body,
      ]);

  // ── 주최자 ──
  Widget _hostCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: T.white, borderRadius: BorderRadius.circular(T.rXl), border: Border.all(color: T.borderSubtle)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () => _openProfile(_hostName),
            child: SizedBox(
              width: 48, height: 48,
              child: Stack(clipBehavior: Clip.none, children: [
                MAvatar(name: _hostName, src: _hostPhoto, size: 48),
                Positioned(
                  right: -1, bottom: -1,
                  child: Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(color: T.primary, shape: BoxShape.circle, border: Border.all(color: T.white, width: 2)),
                    child: const Icon(LucideIcons.check, size: 8, color: T.white),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(_hostName, style: tx(14, FontWeight.w700, T.textStrong, height: 1)),
                const SizedBox(width: 8),
                Text('🌡️ $_hostTemp℃', style: tx(11, FontWeight.w500, T.textDisabled, height: 1)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: T.warningSoft, borderRadius: BorderRadius.circular(T.rPill)),
                  child: Text('⭐ 우수', style: tx(11, FontWeight.w700, T.amber600, height: 1)),
                ),
              ]),
              const SizedBox(height: 8),
              Wrap(spacing: 12, runSpacing: 4, children: [
                _hostStat('번개 주최 ', '4회', T.textTitle),
                _hostStat('정산 준수율 ', '97%', T.success),
                _hostStat('지연 ', '0회', T.textTitle),
              ]),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _openProfile(_hostName),
                child: Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(T.rPill),
                    border: Border.all(color: T.primary, width: 1.5),
                  ),
                  child: Text('프로필 보기', style: tx(11, FontWeight.w700, T.primary, height: 1)),
                ),
              ),
            ]),
          ),
        ]),
      );

  Widget _hostStat(String label, String value, Color valueColor) => RichText(
        text: TextSpan(style: tx(11, FontWeight.w500, T.textMuted, height: 1), children: [
          TextSpan(text: label),
          TextSpan(text: value, style: tx(11, FontWeight.w700, valueColor, height: 1)),
        ]),
      );

  // ── 모임 소개 ──
  Widget _descCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: T.white, borderRadius: BorderRadius.circular(T.rXl), border: Border.all(color: T.borderSubtle)),
        child: Text(_description, style: tx(13, FontWeight.w500, T.textBody, height: 1.7)),
      );

  // ── 참여 인원(차수별) ──
  Widget _participants() {
    final r = _rounds.firstWhere((x) => x.id == _activeRound);
    final rPct = (r.participants.length / r.max * 100).round();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          const Icon(LucideIcons.users, size: 14, color: T.textMuted),
          const SizedBox(width: 6),
          Text('참여 인원', style: tx(13, FontWeight.w700, T.textTitle, height: 1)),
        ]),
        Text('총 $_totalParticipants명 신청', style: tx(12, FontWeight.w600, T.textMuted, height: 1)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        for (final rd in _rounds) ...[
          Expanded(child: _roundTab(rd)),
          if (rd.id != _rounds.last.id) const SizedBox(width: 6),
        ],
      ]),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: T.white,
          borderRadius: BorderRadius.circular(T.rXl),
          border: Border.all(color: T.borderSubtle),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 차수 헤더
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: T.borderSubtle))),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.title, style: tx(13, FontWeight.w700, T.textTitle, height: 1.3)),
                  const SizedBox(height: 3),
                  Text('${r.time} · ${r.place}', style: tx(11, FontWeight.w500, T.textMuted, height: 1)),
                ]),
              ),
              Text('${won(r.cost)}원', style: tx(13, FontWeight.w700, T.primary, height: 1, tab: true)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${r.participants.length}명 신청 · ${r.max - r.participants.length}자리 남음', style: tx(11, FontWeight.w500, T.textMuted, height: 1)),
                if (rPct >= 80) Text('⚠ 마감 임박', style: tx(10, FontWeight.w700, T.danger, height: 1)),
              ]),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: rPct / 100, minHeight: 4,
                  backgroundColor: T.gray100,
                  valueColor: AlwaysStoppedAnimation(rPct >= 80 ? T.danger : T.primary),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 10, runSpacing: 10, children: [
                for (final m in r.participants) _participant(m.name, m.photo),
                if (_applied) _meSlot(),
                for (var i = 0; i < r.max - r.participants.length - (_applied ? 1 : 0); i++) _emptySlot(),
              ]),
            ]),
          ),
        ]),
      ),
    ]);
  }

  Widget _roundTab(_Round rd) {
    final on = _activeRound == rd.id;
    return GestureDetector(
      onTap: () => setState(() => _activeRound = rd.id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? T.primary : T.white,
          borderRadius: BorderRadius.circular(T.rMd),
          border: Border.all(color: on ? T.primary : T.borderSubtle, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(rd.label, style: tx(12, FontWeight.w700, on ? T.white : T.textMuted, height: 1)),
          const SizedBox(width: 5),
          Opacity(
            opacity: 0.8,
            child: Text('${rd.participants.length}/${rd.max}', style: tx(10, FontWeight.w500, on ? T.white : T.textMuted, height: 1)),
          ),
        ]),
      ),
    );
  }

  Widget _participant(String name, String photo) => GestureDetector(
        onTap: () => _openProfile(name),
        child: SizedBox(
          width: 42,
          child: Column(children: [
            Container(
              decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 4, offset: Offset(0, 1))]),
              child: ClipOval(child: NetImage(url: photo, width: 42, height: 42, fallback: MAvatar(name: name, size: 42))),
            ),
            const SizedBox(height: 4),
            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(10, FontWeight.w500, T.textMuted, height: 1)),
          ]),
        ),
      );

  Widget _meSlot() => SizedBox(
        width: 42,
        child: Column(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: T.primary, width: 2.5),
              boxShadow: [BoxShadow(color: T.primary.withValues(alpha: 0.35), blurRadius: 0, spreadRadius: 2)],
            ),
            child: ClipOval(child: NetImage(url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop&crop=face&auto=format&q=80', width: 42, height: 42, fallback: const ColoredBox(color: T.primarySoft))),
          ),
          const SizedBox(height: 4),
          Text('나', style: tx(10, FontWeight.w700, T.primary, height: 1)),
        ]),
      );

  Widget _emptySlot() => SizedBox(
        width: 42,
        child: Column(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: T.gray50,
              shape: BoxShape.circle,
              border: Border.all(color: T.borderDefault, width: 2),
            ),
            child: const Icon(LucideIcons.plus, size: 13, color: T.textDisabled),
          ),
          const SizedBox(height: 4),
          Text('모집 중', style: tx(10, FontWeight.w500, T.textDisabled, height: 1)),
        ]),
      );

  // ── 비용 내역 ──
  Widget _costCard() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: T.white, borderRadius: BorderRadius.circular(T.rXl), border: Border.all(color: T.borderSubtle)),
        child: Column(children: [
          for (var i = 0; i < _costBreakdown.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(border: i < _costBreakdown.length - 1 ? const Border(bottom: BorderSide(color: T.borderSubtle)) : null),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(_costBreakdown[i].$1, style: tx(13, FontWeight.w500, T.textBody, height: 1)),
                Text('${won(_costBreakdown[i].$2)}원', style: tx(13, FontWeight.w600, T.textTitle, height: 1, tab: true)),
              ]),
            ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: T.borderDefault, width: 1.5))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('인당 예상 회비', style: tx(13, FontWeight.w700, T.textTitle, height: 1)),
              Text('약 ${won(_perHead)}원', style: tx(16, FontWeight.w700, T.primary, height: 1, tab: true)),
            ]),
          ),
        ]),
      );

  // ── 참여 규칙 ──
  Widget _rulesSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            const Icon(LucideIcons.shieldCheck, size: 14, color: T.textMuted),
            const SizedBox(width: 6),
            Text('참여 규칙', style: tx(13, FontWeight.w700, T.textTitle, height: 1)),
          ]),
        ),
        for (var i = 0; i < _rules.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 20, height: 20,
                margin: const EdgeInsets.only(top: 1),
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: T.primarySoft, shape: BoxShape.circle),
                child: Text('${i + 1}', style: tx(10, FontWeight.w700, T.primary, height: 1)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(_rules[i], style: tx(13, FontWeight.w500, T.textBody, height: 1.5))),
            ]),
          ),
      ]);

  // ── 하단 CTA ──
  Widget _cta() {
    if (_status == 'none') {
      return StickyBar(
        child: MButton('참가 신청하기', variant: 'primary', size: 'lg', block: true,
            leadingIcon: const Icon(LucideIcons.zap, size: 18, color: T.white),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MeetingApplyScreen()))),
      );
    }
    if (_isIn) {
      return StickyBar(
        child: Row(children: [
          Expanded(child: MButton('예치 취소', variant: 'secondary', size: 'lg', block: true,
              leadingIcon: const Icon(LucideIcons.undo2, size: 17, color: T.primary), onTap: _cancelDeposit)),
          const SizedBox(width: 10),
          Expanded(child: MButton('만남 시각 도래(데모)', variant: 'primary', size: 'lg', block: true,
              leadingIcon: const Icon(LucideIcons.lock, size: 16, color: T.white), onTap: () => setState(() => _status = 'locked'))),
        ]),
      );
    }
    return StickyBar(
      child: MButton('예치 잠김 · 취소 불가', variant: 'secondary', size: 'lg', block: true, disabled: true,
          leadingIcon: const Icon(LucideIcons.lock, size: 17, color: T.primary)),
    );
  }
}
