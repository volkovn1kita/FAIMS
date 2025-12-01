import 'package:json_annotation/json_annotation.dart';

part 'create_user_request_dto.g.dart';

@JsonSerializable()
class CreateUserRequestDto {
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final String role; 

  CreateUserRequestDto({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.role,
  });

  factory CreateUserRequestDto.fromJson(Map<String, dynamic> json) => _$CreateUserRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CreateUserRequestDtoToJson(this);
}