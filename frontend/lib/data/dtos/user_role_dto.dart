// lib/data/dtos/user_role_dto.dart - ОНОВЛЕНА ВЕРСІЯ
import 'package:json_annotation/json_annotation.dart';

part 'user_role_dto.g.dart';

@JsonSerializable()
class UserRoleDto {
  final String name;

  UserRoleDto({required this.name});

  factory UserRoleDto.fromJson(Map<String, dynamic> json) => _$UserRoleDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserRoleDtoToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // Якщо це один і той же об'єкт
    return other is UserRoleDto && // Якщо інший об'єкт того ж типу
           other.name == name;    // І їхні 'name' поля однакові
  }

  @override
  int get hashCode => name.hashCode;
}