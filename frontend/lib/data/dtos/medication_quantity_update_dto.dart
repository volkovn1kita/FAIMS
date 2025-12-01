// lib/data/dtos/medication_quantity_update_dto.dart
import 'package:json_annotation/json_annotation.dart';

part 'medication_quantity_update_dto.g.dart';

@JsonSerializable()
class MedicationQuantityUpdateDto {
  final int quantity;

  MedicationQuantityUpdateDto({required this.quantity});

  factory MedicationQuantityUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$MedicationQuantityUpdateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationQuantityUpdateDtoToJson(this);
}