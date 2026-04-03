import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/dtos/dashboard_overview.dart';

void main() {
  group('DashboardOverview.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'totalKits': 10,
        'kitsNeedingAttention': 3,
        'totalUsers': 5,
        'totalDepartments': 2,
      };

      final overview = DashboardOverview.fromJson(json);

      expect(overview.totalKits, 10);
      expect(overview.kitsNeedingAttention, 3);
      expect(overview.totalUsers, 5);
      expect(overview.totalDepartments, 2);
    });

    test('parses zero values', () {
      final json = {
        'totalKits': 0,
        'kitsNeedingAttention': 0,
        'totalUsers': 0,
        'totalDepartments': 0,
      };

      final overview = DashboardOverview.fromJson(json);

      expect(overview.totalKits, 0);
      expect(overview.kitsNeedingAttention, 0);
    });

    test('kitsNeedingAttention does not exceed totalKits', () {
      final json = {
        'totalKits': 5,
        'kitsNeedingAttention': 2,
        'totalUsers': 4,
        'totalDepartments': 1,
      };

      final overview = DashboardOverview.fromJson(json);

      expect(overview.kitsNeedingAttention <= overview.totalKits, isTrue);
    });
  });
}
