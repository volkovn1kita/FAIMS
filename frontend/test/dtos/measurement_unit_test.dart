import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/dtos/measurement_unit.dart';

void main() {
  group('MeasurementUnit', () {
    test('has exactly 6 units', () {
      expect(MeasurementUnit.values.length, 6);
    });

    test('contains all expected units', () {
      expect(MeasurementUnit.values, contains(MeasurementUnit.pieces));
      expect(MeasurementUnit.values, contains(MeasurementUnit.milliliters));
      expect(MeasurementUnit.values, contains(MeasurementUnit.grams));
      expect(MeasurementUnit.values, contains(MeasurementUnit.tablets));
      expect(MeasurementUnit.values, contains(MeasurementUnit.ampoules));
      expect(MeasurementUnit.values, contains(MeasurementUnit.packs));
    });

    test('units are distinct', () {
      final set = MeasurementUnit.values.toSet();
      expect(set.length, MeasurementUnit.values.length);
    });
  });
}
