// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_user_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateUserRequestDto _$UpdateUserRequestDtoFromJson(
  Map<String, dynamic> json,
) => UpdateUserRequestDto(
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  password: json['password'] as String?,
);

Map<String, dynamic> _$UpdateUserRequestDtoToJson(
  UpdateUserRequestDto instance,
) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'role': instance.role,
  'password': instance.password,
};
