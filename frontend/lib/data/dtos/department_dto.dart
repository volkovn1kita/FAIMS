
import 'package:json_annotation/json_annotation.dart';

part 'department_dto.g.dart';

@JsonSerializable()
class DepartmentDto {
  final String id;
  final String name;

  DepartmentDto({
    required this.id,
    required this.name,
  });

  factory DepartmentDto.fromJson(Map<String, dynamic> json) => _$DepartmentDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DepartmentDtoToJson(this);
}