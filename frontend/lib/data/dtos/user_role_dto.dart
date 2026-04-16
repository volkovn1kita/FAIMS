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
    if (identical(this, other)) return true;
    return other is UserRoleDto &&
           other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}