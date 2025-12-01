// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_user_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateUserRequestDto _$CreateUserRequestDtoFromJson(
  Map<String, dynamic> json,
) => CreateUserRequestDto(
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  password: json['password'] as String,
  role: json['role'] as String,
);

Map<String, dynamic> _$CreateUserRequestDtoToJson(
  CreateUserRequestDto instance,
) => <String, dynamic>{
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'password': instance.password,
  'role': instance.role,
};
