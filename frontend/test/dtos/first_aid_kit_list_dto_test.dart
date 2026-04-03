import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/dtos/first_aid_kit_list_dto.dart';

void main() {
  Map<String, dynamic> validJson() => {
        'id': 'kit-uuid-001',
        'departmentId': 'dept-uuid-001',
        'responsibleUserId': 'user-uuid-001',
        'roomId': 'room-uuid-001',
        'uniqueNumber': 'KIT-001',
        'name': 'Main Kit',
        'departmentName': 'Surgery',
        'roomName': 'Room 1',
        'responsibleUserFirstName': 'John',
        'responsibleUserLastName': 'Doe',
        'criticalItemsCount': 2,
        'expiredItemsCount': 1,
        'lowQuantityItemsCount': 3,
        'createdAt': '2026-01-15T10:00:00.000Z',
        'lastAuditDate': null,
        'statusBadge': 'Needs Attention',
      };

  group('FirstAidKitListDto.fromJson', () {
    test('parses all required fields', () {
      final dto = FirstAidKitListDto.fromJson(validJson());

      expect(dto.id, 'kit-uuid-001');
      expect(dto.uniqueNumber, 'KIT-001');
      expect(dto.name, 'Main Kit');
      expect(dto.departmentName, 'Surgery');
      expect(dto.criticalItemsCount, 2);
      expect(dto.expiredItemsCount, 1);
      expect(dto.lowQuantityItemsCount, 3);
      expect(dto.statusBadge, 'Needs Attention');
    });

    test('lastAuditDate is null when not provided', () {
      final dto = FirstAidKitListDto.fromJson(validJson());
      expect(dto.lastAuditDate, isNull);
    });

    test('lastAuditDate parses when provided', () {
      final json = validJson();
      json['lastAuditDate'] = '2026-03-01T08:00:00.000Z';
      final dto = FirstAidKitListDto.fromJson(json);
      expect(dto.lastAuditDate, isNotNull);
      expect(dto.lastAuditDate!.year, 2026);
    });

    test('toJson round-trips correctly', () {
      final dto = FirstAidKitListDto.fromJson(validJson());
      final json = dto.toJson();
      final dto2 = FirstAidKitListDto.fromJson(json);

      expect(dto2.id, dto.id);
      expect(dto2.name, dto.name);
      expect(dto2.criticalItemsCount, dto.criticalItemsCount);
    });

    test('counts are non-negative', () {
      final dto = FirstAidKitListDto.fromJson(validJson());
      expect(dto.criticalItemsCount, greaterThanOrEqualTo(0));
      expect(dto.expiredItemsCount, greaterThanOrEqualTo(0));
      expect(dto.lowQuantityItemsCount, greaterThanOrEqualTo(0));
    });
  });
}
