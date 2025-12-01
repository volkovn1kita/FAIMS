// lib/domain/repositories/department_repository.dart
import 'package:frontend/data/dtos/department_create_dto.dart';
import 'package:frontend/data/dtos/department_dto.dart'; // Звичайний список департаментів
import 'package:frontend/data/dtos/department_detail_dto.dart'; // Деталі департаменту з кімнатами
import 'package:frontend/data/dtos/room_create_dto.dart';
import 'package:frontend/data/dtos/room_list_dto.dart'; // Список кімнат для деталей
import 'package:frontend/data/dtos/room_update_dto.dart';
import 'package:frontend/data/dtos/room_list_all_dto.dart'; // Можливо, для глобального списку кімнат
import 'package:frontend/data/services/department_api_service.dart';

class DepartmentRepository {
  final DepartmentApiService _apiService = DepartmentApiService();

  // ============== DEPARTMENT OPERATIONS ================

  Future<List<DepartmentDto>> getAllDepartments() async {
    try {
      return await _apiService.getAllDepartments();
    } catch (e) {
      rethrow;
    }
  }

  Future<DepartmentDetailDto> getDepartmentById(String id) async {
    try {
      return await _apiService.getDepartmentById(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addDepartment(DepartmentCreateDto dto) async {
    try {
      return await _apiService.addDepartment(dto);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDepartment(String id, String name) async {
    try {
      await _apiService.updateDepartment(id, name);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDepartment(String id) async {
    try {
      await _apiService.deleteDepartment(id);
    } catch (e) {
      rethrow;
    }
  }

  // ============== ROOM OPERATIONS ================

  Future<List<RoomListAllDto>> getAllRooms() async {
    try {
      return await _apiService.getAllRooms();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RoomListDto>> getRoomsByDepartmentId(String departmentId) async {
    try {
      return await _apiService.getRoomsByDepartmentId(departmentId);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addRoom(RoomCreateDto dto) async {
    try {
      return await _apiService.addRoom(dto);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRoom(String id, RoomUpdateDto dto) async {
    try {
      await _apiService.updateRoom(id, dto);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRoom(String id) async {
    try {
      await _apiService.deleteRoom(id);
    } catch (e) {
      rethrow;
    }
  }
}