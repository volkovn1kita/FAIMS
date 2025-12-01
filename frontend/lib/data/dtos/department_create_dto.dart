import 'package:json_annotation/json_annotation.dart';

part 'department_create_dto.g.dart';

@JsonSerializable()
class DepartmentCreateDto {
  final String name;

  DepartmentCreateDto({
    required this.name,
  });

  factory DepartmentCreateDto.fromJson(Map<String, dynamic> json) => _$DepartmentCreateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DepartmentCreateDtoToJson(this);
}