import 'package:json_annotation/json_annotation.dart';
import 'package:faims/data/dtos/measurement_unit.dart';

part 'medication_update_dto.g.dart'; 

@JsonSerializable()
class MedicationUpdateDto {
  final String id;
  final String firstAidKitId;
  final String name;
  final int quantity;
  final int minimumQuantity;
  final MeasurementUnit unit;
  final DateTime expirationDate;

  MedicationUpdateDto({
    required this.id,
    required this.firstAidKitId,
    required this.name,
    required this.quantity,
    required this.minimumQuantity,
    required this.unit,
    required this.expirationDate,
  });

  factory MedicationUpdateDto.fromJson(Map<String, dynamic> json) => _$MedicationUpdateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MedicationUpdateDtoToJson(this);
}