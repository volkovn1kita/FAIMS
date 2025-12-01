// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_write_off_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicationWriteOffDto _$MedicationWriteOffDtoFromJson(
  Map<String, dynamic> json,
) => MedicationWriteOffDto(
  quantity: (json['quantity'] as num).toInt(),
  reason: json['reason'] as String,
);

Map<String, dynamic> _$MedicationWriteOffDtoToJson(
  MedicationWriteOffDto instance,
) => <String, dynamic>{
  'quantity': instance.quantity,
  'reason': instance.reason,
};
