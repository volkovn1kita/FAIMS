// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicationDto _$MedicationDtoFromJson(Map<String, dynamic> json) =>
    MedicationDto(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      expirationDate: DateTime.parse(json['expirationDate'] as String),
      minimumQuantity: (json['minimumQuantity'] as num).toInt(),
      unit: $enumDecode(_$MeasurementUnitEnumMap, json['unit']),
      status: $enumDecode(_$ExpirationStatusEnumMap, json['status']),
      firstAidKitId: json['firstAidKitId'] as String,
    );

Map<String, dynamic> _$MedicationDtoToJson(MedicationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'quantity': instance.quantity,
      'expirationDate': instance.expirationDate.toIso8601String(),
      'minimumQuantity': instance.minimumQuantity,
      'unit': _$MeasurementUnitEnumMap[instance.unit]!,
      'status': _$ExpirationStatusEnumMap[instance.status]!,
      'firstAidKitId': instance.firstAidKitId,
    };

const _$MeasurementUnitEnumMap = {
  MeasurementUnit.pieces: 'Pieces',
  MeasurementUnit.milliliters: 'Milliliters',
  MeasurementUnit.grams: 'Grams',
  MeasurementUnit.tablets: 'Tablets',
  MeasurementUnit.ampoules: 'Ampoules',
  MeasurementUnit.packs: 'Packs',
};

const _$ExpirationStatusEnumMap = {
  ExpirationStatus.good: 'Good',
  ExpirationStatus.warning: 'Warning',
  ExpirationStatus.critical: 'Critical',
  ExpirationStatus.expired: 'Expired',
};
