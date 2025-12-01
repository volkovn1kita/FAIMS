// lib/data/dtos/medication_write_off_dto.dart
import 'package:json_annotation/json_annotation.dart';

part 'medication_write_off_dto.g.dart';

@JsonSerializable()
class MedicationWriteOffDto {
  final int quantity;
  final String reason;

  MedicationWriteOffDto({required this.quantity, required this.reason});

  factory MedicationWriteOffDto.fromJson(Map<String, dynamic> json) =>
      _$MedicationWriteOffDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationWriteOffDtoToJson(this);
}