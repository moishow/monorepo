// 설정 — prototype SettingsScreen (87338638:252).
// 계좌 연동 관리 · 알림 설정 · 이용약관(목록 + 약관 전문) · 메인 설정 + 로그아웃.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/chrome.dart';
import '../../core/widgets/primitives.dart';
import '../../core/widgets/toast.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _section = 'main'; // main | account | notif | terms
  String? _docKey;
  final Map<String, bool> _notifs = {'funding': true, 'show': true, 'member': false};

  void _toggle(String k) => setState(() => _notifs[k] = !(_notifs[k] ?? false));

  // ── 약관 전문(프로토타입 DOCS 리터럴) ──
  static const _docs = <String, List<(String, String)>>{
    '서비스 이용약관': [
      ('제1조 (목적)', "이 약관은 모이쇼(이하 '회사')가 제공하는 동아리·모임 중개 및 공동 경비 관리 서비스의 이용 조건과 절차, 이용자와 회사의 권리·의무를 규정함을 목적으로 합니다."),
      ('제2조 (회원가입)', '이용자는 회사가 정한 절차에 따라 회원가입을 신청하며, 학교 인증 또는 본인 인증을 완료한 경우에 모임 개설·참여 등의 기능을 이용할 수 있습니다.'),
      ('제3조 (서비스의 제공)', '회사는 동아리/모임 개설, 참여 신청, 공동 경비 정산, 장부 기록 등의 서비스를 제공합니다. 서비스의 구체적인 내용은 회사 정책에 따라 변경될 수 있습니다.'),
      ('제4조 (이용자의 의무)', '이용자는 타인의 권리를 침해하거나 모임의 건전한 운영을 방해하는 행위를 해서는 안 되며, 공동 경비 정산 시 성실히 참여해야 합니다.'),
    ],
    '개인정보처리방침': [
      ('수집하는 개인정보 항목', '회사는 회원가입 및 서비스 이용 과정에서 이름, 휴대전화번호, 이메일, 프로필 사진, 학교/소속 정보를 수집합니다.'),
      ('개인정보의 이용 목적', '수집한 정보는 본인 확인, 모임 매칭, 공동 경비 정산 처리, 고객 문의 대응을 위해서만 이용됩니다.'),
      ('보유 및 이용 기간', '회원 탈퇴 시 지체 없이 파기함을 원칙으로 하되, 관련 법령에 따라 일정 기간 보관이 필요한 정보는 해당 기간 동안 보관합니다.'),
    ],
    '금융 거래 이용약관': [
      ('공동 경비의 성격', '모임·동아리의 공동 경비는 참가자가 자발적으로 모아 집행하는 금전으로, 회사는 송금·정산 내역을 기록·중개할 뿐 직접적인 금융 당사자가 아닙니다.'),
      ('장부의 투명성', '모든 공동 경비는 입금/지출 내역과 영수증이 구성원에게 공개되며, 총무는 정산 완료 시 증빙 자료를 업로드할 의무가 있습니다.'),
      ('노쇼 및 환불', '개인 번개의 노쇼 예약금은 먹튀 방지를 위한 장치이며, 정당한 사유의 불참 시 환불 정책에 따라 처리됩니다.'),
    ],
    '위치 정보 이용약관': [
      ('위치정보의 이용', '회사는 주변 모임 추천 및 거리 표시를 위해 이용자의 위치정보를 이용할 수 있으며, 이는 이용자의 동의 하에만 수집됩니다.'),
      ('동의 철회', '이용자는 언제든지 위치정보 수집 동의를 철회할 수 있으며, 철회 시 거리 기반 추천 기능이 제한될 수 있습니다.'),
    ],
  };

  // ── 확인 시트(프로토타입 confirmSheet → showModalBottomSheet) ──
  void _showConfirm({
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: T.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: T.borderDefault, borderRadius: BorderRadius.circular(999)))),
            const SizedBox(height: 18),
            Text(title, style: tx(17, FontWeight.w700, T.textStrong, height: 1.3)),
            const SizedBox(height: 10),
            Text(message, style: tx(14, FontWeight.w500, T.textMuted, height: 1.6)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: MButton('취소', variant: 'secondary', size: 'lg', block: true, onTap: () => Navigator.pop(sheetCtx))),
              const SizedBox(width: 10),
              Expanded(child: MButton(confirmLabel, variant: 'danger', size: 'lg', block: true, onTap: () {
                Navigator.pop(sheetCtx);
                onConfirm();
              })),
            ]),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 약관 전문(목록 → 전문)은 terms 섹션보다 먼저 평가.
    if (_section == 'account') return _accountView();
    if (_section == 'notif') return _notifView();
    if (_docKey != null) return _docView(_docKey!);
    if (_section == 'terms') return _termsView();
    return _mainView();
  }

  // ── 계좌 연동 관리 ──
  Widget _accountView() => Scaffold(
        backgroundColor: T.surfacePage,
        body: Column(children: [
          const MoishoStatusBar(),
          MoishoAppHeader(title: '계좌 연동 관리', onBack: () => setState(() => _section = 'main')),
          Expanded(
            child: ScrollBody(padding: const EdgeInsets.fromLTRB(T.padScreen, 20, T.padScreen, 24), children: [
              MCard(
                radius: T.rXl,
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: T.successSoft, borderRadius: BorderRadius.circular(T.rMd)),
                      child: const Icon(LucideIcons.link, size: 20, color: T.success),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('오픈뱅킹 연동 계좌', style: tx(12, FontWeight.w600, T.textMuted, height: 1)),
                        const SizedBox(height: 2),
                        Text('신한은행 110-xxx-xxxxxx', style: tx(15, FontWeight.w700, T.textStrong, height: 1.3)),
                      ]),
                    ),
                    const SizedBox(width: 8),
                    const MBadge('연결됨', tone: 'success', variant: 'dot'),
                  ]),
                  const SizedBox(height: 16),
                  MButton(
                    '연동 해제', variant: 'danger', size: 'sm', block: true,
                    leadingIcon: const Icon(LucideIcons.unlink, size: 15, color: T.white),
                    onTap: () => _showConfirm(
                      title: '계좌 연동을 해제할까요?',
                      message: '연동을 해제하면 자동 이체·정산이 중단돼요. 언제든 다시 연결할 수 있어요.',
                      confirmLabel: '연동 해제',
                      onConfirm: () => MoishoToast.show(context, '계좌 연동이 해제됐어요.', tone: 'info'),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => MoishoToast.show(context, '오픈뱅킹 연동 페이지로 이동해요.', tone: 'info'),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: T.white,
                    borderRadius: BorderRadius.circular(T.rLg),
                    border: Border.all(color: T.borderDefault, width: 1.5), // proto dashed
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(LucideIcons.plus, size: 16, color: T.textMuted),
                    const SizedBox(width: 8),
                    Text('새 계좌 추가하기', style: tx(14, FontWeight.w600, T.textMuted, height: 1)),
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      );

  // ── 알림 설정 ──
  Widget _notifView() {
    const rows = [
      ('펀딩 마감 · 입금 알림', 'funding'),
      ('쇼 새 게시글 알림', 'show'),
      ('신입 가입 신청 알림', 'member'),
    ];
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '알림 설정', onBack: () => setState(() => _section = 'main')),
        Expanded(
          child: ScrollBody(padding: const EdgeInsets.fromLTRB(T.padScreen, 20, T.padScreen, 24), children: [
            const SectionLabel('푸시 알림'),
            MCard(
              radius: T.rXl,
              padding: EdgeInsets.zero,
              child: Column(children: [
                for (var i = 0; i < rows.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      border: i < rows.length - 1 ? const Border(bottom: BorderSide(color: T.borderSubtle)) : null,
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(rows[i].$1, style: tx(14, FontWeight.w600, T.textTitle, height: 1)),
                      _ToggleSwitch(value: _notifs[rows[i].$2] ?? false, onChanged: (_) => _toggle(rows[i].$2)),
                    ]),
                  ),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── 약관 전문 ──
  Widget _docView(String key) {
    final doc = _docs[key] ?? const [];
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: key, onBack: () => setState(() => _docKey = null)),
        Expanded(
          child: ScrollBody(padding: const EdgeInsets.fromLTRB(T.padScreen, 18, T.padScreen, 24), children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text('시행일 2026.01.01 · 버전 2.4', style: tx(11, FontWeight.w500, T.textDisabled, height: 1.5)),
            ),
            for (final (h, b) in doc)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(h, style: tx(14, FontWeight.w700, T.textTitle, height: 1.4)),
                  const SizedBox(height: 7),
                  Text(b, style: tx(13, FontWeight.w500, T.textBody, height: 1.7)),
                ]),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
              child: Text('본 약관은 데모용 예시이며 실제 법적 효력을 갖지 않습니다.', style: tx(12, FontWeight.w500, T.textDisabled, height: 1.6)),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── 이용약관 목록 ──
  Widget _termsView() {
    const titles = ['서비스 이용약관', '개인정보처리방침', '금융 거래 이용약관', '위치 정보 이용약관'];
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '이용약관', onBack: () => setState(() => _section = 'main')),
        Expanded(
          child: ScrollBody(padding: const EdgeInsets.fromLTRB(T.padScreen, 16, T.padScreen, 24), children: [
            MCard(
              radius: T.rXl,
              padding: EdgeInsets.zero,
              child: Column(children: [
                for (var i = 0; i < titles.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _docKey = titles[i]),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: T.white,
                        border: i < titles.length - 1 ? const Border(bottom: BorderSide(color: T.borderSubtle)) : null,
                      ),
                      child: Row(children: [
                        Expanded(child: Text(titles[i], style: tx(14, FontWeight.w600, T.textTitle, height: 1))),
                        const Icon(LucideIcons.chevronRight, size: 18, color: T.textDisabled),
                      ]),
                    ),
                  ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 4),
              child: Text('모이쇼 v2.4.1 · ©2026 모이쇼 Inc.', style: tx(12, FontWeight.w500, T.textDisabled, height: 1.6)),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── 메인 설정 ──
  Widget _mainView() {
    final rows = <(String, IconData, VoidCallback)>[
      ('계좌 연동 관리', LucideIcons.link, () => setState(() => _section = 'account')),
      ('알림 설정', LucideIcons.bell, () => setState(() => _section = 'notif')),
      ('이용약관', LucideIcons.fileText, () => setState(() => _section = 'terms')),
    ];
    return Scaffold(
      backgroundColor: T.surfacePage,
      body: Column(children: [
        const MoishoStatusBar(),
        MoishoAppHeader(title: '설정', onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: ScrollBody(padding: const EdgeInsets.fromLTRB(T.padScreen, 20, T.padScreen, 24), children: [
            const SectionLabel('앱 설정'),
            MCard(
              radius: T.rXl,
              padding: EdgeInsets.zero,
              child: Column(children: [
                for (var i = 0; i < rows.length; i++)
                  GestureDetector(
                    onTap: rows[i].$3,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: T.white,
                        border: i < rows.length - 1 ? const Border(bottom: BorderSide(color: T.borderSubtle)) : null,
                      ),
                      child: Row(children: [
                        Icon(rows[i].$2, size: 20, color: T.textMuted),
                        const SizedBox(width: 12),
                        Expanded(child: Text(rows[i].$1, style: tx(14, FontWeight.w600, T.textTitle, height: 1))),
                        const Icon(LucideIcons.chevronRight, size: 18, color: T.textDisabled),
                      ]),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _showConfirm(
                title: '로그아웃 할까요?',
                message: '다시 로그인하면 모든 정보가 그대로 유지돼요.',
                confirmLabel: '로그아웃',
                onConfirm: () => MoishoToast.show(context, '로그아웃 됐어요. 다음에 봐요!', tone: 'info'),
              ),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: T.white,
                  borderRadius: BorderRadius.circular(T.rLg),
                  border: Border.all(color: T.danger, width: 1.5),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(LucideIcons.logOut, size: 18, color: T.danger),
                  const SizedBox(width: 8),
                  Text('로그아웃', style: tx(15, FontWeight.w700, T.danger, height: 1)),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── 토글 스위치(prototype Switch) ──
class _ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 46,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? T.primary : T.gray200,
          borderRadius: BorderRadius.circular(T.rPill),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(color: T.white, shape: BoxShape.circle, boxShadow: T.shadowXs),
        ),
      ),
    );
  }
}
