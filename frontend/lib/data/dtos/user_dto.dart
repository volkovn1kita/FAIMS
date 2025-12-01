// lib/data/dtos/user_dto.dart - ОНОВЛЕНА ВЕРСІЯ
import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? avatarUrl; // <--- НОВЕ ПОЛЕ: URL аватара

  UserDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.avatarUrl, // Зробимо його необов'язковим
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  String get fullName => '$firstName $lastName';

  // Метод copyWith для зручного оновлення UserDto
  UserDto copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    String? avatarUrl,
  }) {
    return UserDto(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}