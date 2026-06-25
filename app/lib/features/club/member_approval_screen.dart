// 신입 부원 가입 관리 — prototype MemberApprovalScreen (850b0de8:714).
// 대기 신청자 목록(승인·거절·상세검토) + 가입 완료 부원 + 신청자 검토 서브뷰(답변·하단 액션).
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';
import '../social/public_profile_screen.dart';
import 'club_form_builder_screen.dart';

class _Applicant {
  final String name;
  final int age;
  final List<String> tags;
  final String note, applied;
  final double temp;
  final List<(String, String)> answers;
  String status = 'pending'; // pending | approved | rejected
  _Applicant({
    required this.name,
    required this.age,
    required this.tags,
    required this.note,
    required this.applied,
    required this.temp,
    required this.answers,
  });
}

class _Member {
  final String name, role;
  const _Member(this.name, this.role);
}

class MemberApprovalScreen extends StatefulWidget {
  const MemberApprovalScreen({super.key});

  @override
  State<MemberApprovalScreen> createState() => _MemberApprovalScreenState();
}

class _MemberApprovalScreenState extends State<MemberApprovalScreen> {
  int? _selIdx;

  final List<_Applicant> _items = [
    _Applicant(
      name: '홍길동',
      age: 24,
      tags: const ['밴드', '친목'],
      note: '보컬 / 통기타 3년 차입니다.',
      applied: '2일 전',
      temp: 37.2,
      answers: const [
        ('지원 동기', '고등학교 때 밴드를 했는데 대학와서 제대로 합주할 곳을 찾고 있었어요. 사운드 공연 영상을 보고 난 뒤 꾸준함에 반했습니다.'),
        ('다룰 수 있는 악기', '통기타 3년, 보컬 가능. 간단한 건반도 칠 수 있어요.'),
        ('활동 가능 요일', '평일 저녁 / 주말 전일'),
      ],
    ),
    _Applicant(
      name: '이땡땡',
      age: 22,
      tags: const ['밴드', '독서'],
      note: '드럼 2년 차, 합주 경험 있어요.',
      applied: '4일 전',
      temp: 36.9,
      answers: const [
        ('지원 동기', '드럼 칠 곳이 마땅하지 않아서 합주 가능한 동아리를 찾고 있었습니다.'),
        ('다룰 수 있는 악기', '드럼 2년 차, 심플·메트로놈 구별 가능'),
        ('활동 가능 요일', '주말 전일'),
      ],
    ),
  ];

  static const List<_Member> _members = [
    _Member('김회장', '회장'),
    _Member('이총무', '총무'),
    _Member('최부원', '부원'),
    _Member('박소심', '부원'),
  ];

  void _act(int i, String status) => setState(() => _items[i].status = status);

  void _openProfile(String name) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PublicProfileScreen(name: name)),
      );

  @override
  Widget build(BuildContext context) {
    if (_selIdx != null) return _reviewSubview(_items[_selIdx!]);
    return _listView();
  }

  // ── 신청자 상세 검토 서브뷰 ──
  Widget _reviewSubview(_Applicant it) {
    // 프로토타입의 (역전된) 온도 색 규칙을 그대로 재현.
    final Color tempCol = it.temp >= 37.5
        ? T.success // proto #16A34A
        : it.temp >= 36.5
            ? T.warning // proto #F59E0B
            : T.danger; // proto #DC2626
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '신청자 검토', onBack: () => setState(() => _selIdx = null)),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 18, T.padScreen, 24),
            children: [
              MCard(
                elevation: 'raised',
                radius: T.rXl,
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    MAvatar(name: it.name, size: 56),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(it.name, style: tx(18, FontWeight.w700, T.textStrong, height: 1.1)),
                          const SizedBox(width: 6),
                          Text('${it.age}세', style: tx(13, FontWeight.w500, T.textMuted, height: 1)),
                        ]),
                        const SizedBox(height: 5),
                        Row(children: [
                          Icon(LucideIcons.thermometer, size: 13, color: tempCol),
                          const SizedBox(width: 5),
                          Text('매너온도 ${it.temp}℃', style: tx(12, FontWeight.w700, tempCol, height: 1)),
                          const SizedBox(width: 5),
                          Text('· ${it.applied} 신청', style: tx(11, FontWeight.w500, T.textDisabled, height: 1)),
                        ]),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    for (final t in it.tags) MTag(t, tone: 'blue', leadingHash: true),
                  ]),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => _openProfile(it.name),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: T.white,
                        borderRadius: BorderRadius.circular(T.rMd),
                        border: Border.all(color: T.borderDefault, width: 1.5),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(LucideIcons.user, size: 15, color: T.textMuted),
                        const SizedBox(width: 6),
                        Text('전체 프로필 보기', style: tx(13, FontWeight.w600, T.textBody, height: 1)),
                      ]),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              const SectionLabel('신청서 답변'),
              MCard(
                elevation: 'flat',
                radius: T.rXl,
                padding: const EdgeInsets.all(4),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  for (var i = 0; i < it.answers.length; i++)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: BoxDecoration(
                        border: i > 0 ? const Border(top: BorderSide(color: T.borderSubtle)) : null,
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(
                            width: 18,
                            height: 18,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: T.primarySoft,
                              borderRadius: BorderRadius.circular(T.rMini),
                            ),
                            child: Text('${i + 1}', style: tx(10, FontWeight.w700, T.primary, height: 1)),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(it.answers[i].$1, style: tx(12, FontWeight.w700, T.textTitle, height: 1.3)),
                          ),
                        ]),
                        const SizedBox(height: 7),
                        Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: Text(it.answers[i].$2, style: tx(13, FontWeight.w500, T.textBody, height: 1.6)),
                        ),
                      ]),
                    ),
                ]),
              ),
            ],
          ),
        ),
        _reviewActions(it),
      ]),
    );
  }

  Widget _reviewActions(_Applicant it) {
    if (it.status == 'pending') {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: T.white,
          border: Border(top: BorderSide(color: T.borderSubtle)),
        ),
        child: SafeArea(
          top: false,
          child: Row(children: [
            MButton('질문', variant: 'secondary', size: 'lg',
                leadingIcon: const Icon(LucideIcons.messageCircle, size: 18, color: T.primary),
                onTap: () => MoishoToast.show(context, '준비 중', tone: 'info')),
            const SizedBox(width: 8),
            Expanded(
              child: MButton('거절', variant: 'danger', size: 'lg', block: true,
                  leadingIcon: const Icon(LucideIcons.x, size: 18, color: T.white),
                  onTap: () {
                    _act(_selIdx!, 'rejected');
                    setState(() => _selIdx = null);
                  }),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MButton('승인', variant: 'success', size: 'lg', block: true,
                  leadingIcon: const Icon(LucideIcons.check, size: 18, color: T.white),
                  onTap: () {
                    _act(_selIdx!, 'approved');
                    setState(() => _selIdx = null);
                  }),
            ),
          ]),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        color: T.white,
        border: Border(top: BorderSide(color: T.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: MBadge(it.status == 'approved' ? '승인 완료' : '거절됨',
              tone: it.status == 'approved' ? 'success' : 'danger', variant: 'soft'),
        ),
      ),
    );
  }

  // ── 목록 뷰 ──
  Widget _listView() {
    final pendingCount = _items.where((i) => i.status == 'pending').length;
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(
          title: '신입 부원 가입 관리',
          onBack: () => Navigator.of(context).maybePop(),
          actions: [
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ClubFormBuilderScreen()),
              ),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(children: [
                  const Icon(LucideIcons.settings2, size: 15, color: T.primary),
                  const SizedBox(width: 4),
                  Text('신청서 편집', style: tx(13, FontWeight.w600, T.primary, height: 1)),
                ]),
              ),
            ),
          ],
        ),
        Expanded(
          child: ScrollBody(
            padding: const EdgeInsets.fromLTRB(T.padScreen, 20, T.padScreen, 24),
            children: [
              MCard(
                elevation: 'flat',
                radius: T.rXl,
                padding: EdgeInsets.zero,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                    child: MBadge('대기 중 $pendingCount건', tone: 'danger', variant: 'soft'),
                  ),
                  for (var i = 0; i < _items.length; i++) _applicantRow(i, _items[i]),
                ]),
              ),
              const SizedBox(height: 8),
              SectionLabel('가입 완료 부원 (${_members.length}명)'),
              for (var i = 0; i < _members.length; i++) _memberRow(_members[i], i < _members.length - 1),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _applicantRow(int i, _Applicant item) => Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: T.borderSubtle))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () => setState(() => _selIdx = i),
            behavior: HitTestBehavior.opaque,
            child: Row(children: [
              MAvatar(name: item.name, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${item.name} (${item.age}세)', style: tx(14, FontWeight.w700, T.textTitle, height: 1.2)),
                  const SizedBox(height: 4),
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    for (final t in item.tags) MTag(t, tone: 'blue', leadingHash: true),
                  ]),
                ]),
              ),
              const SizedBox(width: 8),
              if (item.status != 'pending')
                MBadge(item.status == 'approved' ? '승인' : '거절',
                    tone: item.status == 'approved' ? 'success' : 'danger', variant: 'soft')
              else
                const Icon(LucideIcons.chevronRight, size: 18, color: T.textDisabled),
            ]),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _selIdx = i),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: T.gray50, borderRadius: BorderRadius.circular(T.rMd)),
              child: Text.rich(
                TextSpan(
                  style: tx(13, FontWeight.w500, T.textBody, height: 1.4),
                  children: [
                    TextSpan(text: '"${item.note}" '),
                    TextSpan(text: '· 신청서 전체 보기', style: tx(12, FontWeight.w600, T.primary, height: 1)),
                  ],
                ),
              ),
            ),
          ),
          if (item.status == 'pending') ...[
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: MButton('승인', variant: 'success', size: 'sm', block: true,
                    leadingIcon: const Icon(LucideIcons.check, size: 16, color: T.white),
                    onTap: () => _act(i, 'approved')),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MButton('거절', variant: 'danger', size: 'sm', block: true,
                    leadingIcon: const Icon(LucideIcons.x, size: 16, color: T.white),
                    onTap: () => _act(i, 'rejected')),
              ),
            ]),
          ],
        ]),
      );

  Widget _memberRow(_Member m, bool divider) => Container(
        height: 60,
        decoration: BoxDecoration(
          border: divider ? const Border(bottom: BorderSide(color: T.borderSubtle)) : null,
        ),
        child: Row(children: [
          MAvatar(name: m.name, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Text(m.name, style: tx(14, FontWeight.w600, T.textTitle, height: 1.2)),
          ),
          MBadge(m.role,
              tone: m.role == '회장'
                  ? 'purple'
                  : m.role == '총무'
                      ? 'blue'
                      : 'neutral',
              variant: 'soft'),
        ]),
      );
}
