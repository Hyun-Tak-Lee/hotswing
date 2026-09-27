/// 대기 패널의 탭(전체, 그룹, 개인) 항목 데이터 모델.
class WaitingTabItem {
  /// UI에 노출될 탭 라벨 (예: "전체", "그룹 A", "개인").
  final String label;

  /// 탭 유형 ('all', 'group', 'individual').
  final String type;

  /// 그룹 유형일 때 필터링에 매핑할 실제 그룹 라벨 (예: "A").
  final String? groupLabel;

  /// [WaitingTabItem] 생성자.
  WaitingTabItem({required this.label, required this.type, this.groupLabel});
}

