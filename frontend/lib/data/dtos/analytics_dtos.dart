import 'package:json_annotation/json_annotation.dart';

part 'analytics_dtos.g.dart';

@JsonSerializable()
class MedicationStatDto {
  final String medicationName;
  final double totalQuantity;
  final String unit;

  MedicationStatDto({
    required this.medicationName,
    required this.totalQuantity,
    required this.unit,
  });

  factory MedicationStatDto.fromJson(Map<String, dynamic> json) => _$MedicationStatDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MedicationStatDtoToJson(this);
}

@JsonSerializable()
class DashboardStatsDto {
  final List<MedicationStatDto> topUsedMedications;
  final List<MedicationStatDto> topExpiredMedications;

  DashboardStatsDto({
    required this.topUsedMedications,
    required this.topExpiredMedications,
  });

  factory DashboardStatsDto.fromJson(Map<String, dynamic> json) => _$DashboardStatsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardStatsDtoToJson(this);
}