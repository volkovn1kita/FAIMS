// lib/data/dtos/medication_update_dto.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:frontend/data/dtos/measurement_unit.dart'; // Переконайтеся, що імпортуєте MeasurementUnit

part 'medication_update_dto.g.dart'; 

@JsonSerializable()
class MedicationUpdateDto {
  final String id;
  final String firstAidKitId;
  final String name; // Додано
  final int quantity;
  final int minimumQuantity;
  final MeasurementUnit unit; // Додано
  final DateTime expirationDate;

  MedicationUpdateDto({
    required this.id,
    required this.firstAidKitId,
    required this.name, // Додано
    required this.quantity,
    required this.minimumQuantity,
    required this.unit, // Додано
    required this.expirationDate,
  });

  factory MedicationUpdateDto.fromJson(Map<String, dynamic> json) => _$MedicationUpdateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MedicationUpdateDtoToJson(this);
}