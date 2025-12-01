
import 'package:json_annotation/json_annotation.dart';
import 'package:frontend/data/dtos/expiration_status.dart'; 
import 'package:frontend/data/dtos/measurement_unit.dart'; 

part 'medication_dto.g.dart'; 

@JsonSerializable()
class MedicationDto {
  final String id;
  final String name;
  final int quantity;
  final DateTime expirationDate;
  final int minimumQuantity;
  final MeasurementUnit unit;
  final ExpirationStatus status;
  final String firstAidKitId;

  MedicationDto({
    required this.id,
    required this.name,
    required this.quantity,
    required this.expirationDate,
    required this.minimumQuantity,
    required this.unit,
    required this.status,
    required this.firstAidKitId,
  });

  factory MedicationDto.fromJson(Map<String, dynamic> json) => _$MedicationDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MedicationDtoToJson(this);
}