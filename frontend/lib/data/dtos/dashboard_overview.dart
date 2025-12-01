class DashboardOverview {
  final int totalKits;
  final int kitsNeedingAttention;
  final int totalUsers;
  final int totalDepartments;

  DashboardOverview({
    required this.totalKits,
    required this.kitsNeedingAttention,
    required this.totalUsers,
    required this.totalDepartments,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      totalKits: json['totalKits'] as int,
      kitsNeedingAttention: json['kitsNeedingAttention'] as int,
      totalUsers: json['totalUsers'] as int,
      totalDepartments: json['totalDepartments'] as int,
    );
  }
}