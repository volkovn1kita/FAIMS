// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicationStatDto _$MedicationStatDtoFromJson(Map<String, dynamic> json) =>
    MedicationStatDto(
      medicationName: json['medicationName'] as String,
      totalQuantity: (json['totalQuantity'] as num).toDouble(),
      unit: json['unit'] as String,
    );

Map<String, dynamic> _$MedicationStatDtoToJson(MedicationStatDto instance) =>
    <String, dynamic>{
      'medicationName': instance.medicationName,
      'totalQuantity': instance.totalQuantity,
      'unit': instance.unit,
    };

DashboardStatsDto _$DashboardStatsDtoFromJson(Map<String, dynamic> json) =>
    DashboardStatsDto(
      topUsedMedications: (json['topUsedMedications'] as List<dynamic>)
          .map((e) => MedicationStatDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      topExpiredMedications: (json['topExpiredMedications'] as List<dynamic>)
          .map((e) => MedicationStatDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardStatsDtoToJson(DashboardStatsDto instance) =>
    <String, dynamic>{
      'topUsedMedications': instance.topUsedMedications,
      'topExpiredMedications': instance.topExpiredMedications,
    };
