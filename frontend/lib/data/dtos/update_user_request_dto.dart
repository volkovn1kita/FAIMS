import 'package:json_annotation/json_annotation.dart';

part 'update_user_request_dto.g.dart';

@JsonSerializable()
class UpdateUserRequestDto {
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? password;

  UpdateUserRequestDto({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.password,
  });

  factory UpdateUserRequestDto.fromJson(Map<String, dynamic> json) => _$UpdateUserRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateUserRequestDtoToJson(this);
}