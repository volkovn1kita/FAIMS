
import 'package:json_annotation/json_annotation.dart';
import 'package:frontend/data/dtos/measurement_unit.dart';

part 'medication_create_dto.g.dart';

@JsonSerializable()
class MedicationCreateDto {
  final String firstAidKitId;
  final String name;
  final int quantity;
  final int minimumQuantity;
  final MeasurementUnit unit;
  final DateTime expirationDate;

  MedicationCreateDto({
    required this.firstAidKitId,
    required this.name,
    required this.quantity,
    required this.minimumQuantity,
    required this.unit,
    required this.expirationDate,
  });

  factory MedicationCreateDto.fromJson(Map<String, dynamic> json) => _$MedicationCreateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MedicationCreateDtoToJson(this);
}