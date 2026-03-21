import 'dart:io';
import 'package:frontend/data/dtos/user_dto.dart';
import 'package:frontend/data/dtos/create_user_request_dto.dart';
import 'package:frontend/data/dtos/user_role_dto.dart';
import 'package:frontend/data/dtos/update_user_request_dto.dart';
import 'package:frontend/data/services/user_api_service.dart';

class UserRepository {
  final UserApiService _userApiService = UserApiService();

  Future<List<UserDto>> getUsers() async {
    return await _userApiService.getAllUsers();
  }

  Future<UserDto> getUserDetails(String userId) async {
    return await _userApiService.getUserById(userId);
  }

  Future<String> createUser(CreateUserRequestDto newUser) async {
    return await _userApiService.adminCreateUser(newUser);
  }

  Future<void> updateUser(String userId, UpdateUserRequestDto updatedUser) async { 
    return await _userApiService.adminUpdateUser(userId, updatedUser);
  }

  Future<void> deleteUser(String userId) async {
    return await _userApiService.adminDeleteUser(userId);
  }

  Future<List<UserRoleDto>> getAvailableRoles() async {
    return await _userApiService.getAvailableRoles();
  }

  Future<UserDto> getMyProfile() async {
    return await _userApiService.getMyProfile();
  }

  Future<UserDto?> updateMyProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? oldPassword,
    String? newPassword,
  }) async {
    return await _userApiService.updateMyProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  Future<String?> uploadMyAvatar(File avatarFile) async {
    return await _userApiService.uploadMyAvatar(avatarFile);
  }

  Future<void> deleteMyAvatar() async {
    return await _userApiService.deleteMyAvatar();
  }

  Future<String?> uploadUserAvatar(String userId, File avatarFile) async {
    return await _userApiService.uploadUserAvatar(userId, avatarFile);
  }

  Future<void> deleteUserAvatar(String userId) async {
    return await _userApiService.deleteUserAvatar(userId);
  }
}