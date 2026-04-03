import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/dtos/medication_dto.dart';
import 'package:frontend/data/dtos/expiration_status.dart';
import 'package:frontend/data/dtos/measurement_unit.dart';

void main() {
  Map<String, dynamic> validJson() => {
        'id': 'med-uuid-001',
        'name': 'Aspirin',
        'quantity': 20,
        'expirationDate': '2027-06-01T00:00:00.000Z',
        'minimumQuantity': 5,
        'unit': 'Tablets',
        'status': 'Good',
        'firstAidKitId': 'kit-uuid-001',
      };

  group('MedicationDto.fromJson', () {
    test('parses all fields', () {
      final dto = MedicationDto.fromJson(validJson());

      expect(dto.id, 'med-uuid-001');
      expect(dto.name, 'Aspirin');
      expect(dto.quantity, 20);
      expect(dto.minimumQuantity, 5);
      expect(dto.unit, MeasurementUnit.tablets);
      expect(dto.status, ExpirationStatus.good);
      expect(dto.firstAidKitId, 'kit-uuid-001');
    });

    test('parses expiration date correctly', () {
      final dto = MedicationDto.fromJson(validJson());
      expect(dto.expirationDate.year, 2027);
      expect(dto.expirationDate.month, 6);
    });

    test('parses critical status', () {
      final json = validJson();
      json['status'] = 'Critical';
      final dto = MedicationDto.fromJson(json);
      expect(dto.status, ExpirationStatus.critical);
    });

    test('parses expired status', () {
      final json = validJson();
      json['status'] = 'Expired';
      final dto = MedicationDto.fromJson(json);
      expect(dto.status, ExpirationStatus.expired);
    });

    test('parses milliliters unit', () {
      final json = validJson();
      json['unit'] = 'Milliliters';
      final dto = MedicationDto.fromJson(json);
      expect(dto.unit, MeasurementUnit.milliliters);
    });

    test('toJson round-trips correctly', () {
      final dto = MedicationDto.fromJson(validJson());
      final json = dto.toJson();
      final dto2 = MedicationDto.fromJson(json);

      expect(dto2.id, dto.id);
      expect(dto2.name, dto.name);
      expect(dto2.quantity, dto.quantity);
      expect(dto2.unit, dto.unit);
      expect(dto2.status, dto.status);
    });
  });
}
