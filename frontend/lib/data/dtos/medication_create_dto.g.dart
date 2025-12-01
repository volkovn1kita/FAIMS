// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_create_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicationCreateDto _$MedicationCreateDtoFromJson(Map<String, dynamic> json) =>
    MedicationCreateDto(
      firstAidKitId: json['firstAidKitId'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      minimumQuantity: (json['minimumQuantity'] as num).toInt(),
      unit: $enumDecode(_$MeasurementUnitEnumMap, json['unit']),
      expirationDate: DateTime.parse(json['expirationDate'] as String),
    );

Map<String, dynamic> _$MedicationCreateDtoToJson(
  MedicationCreateDto instance,
) => <String, dynamic>{
  'firstAidKitId': instance.firstAidKitId,
  'name': instance.name,
  'quantity': instance.quantity,
  'minimumQuantity': instance.minimumQuantity,
  'unit': _$MeasurementUnitEnumMap[instance.unit]!,
  'expirationDate': instance.expirationDate.toIso8601String(),
};

const _$MeasurementUnitEnumMap = {
  MeasurementUnit.pieces: 'Pieces',
  MeasurementUnit.milliliters: 'Milliliters',
  MeasurementUnit.grams: 'Grams',
  MeasurementUnit.tablets: 'Tablets',
  MeasurementUnit.ampoules: 'Ampoules',
  MeasurementUnit.packs: 'Packs',
};
