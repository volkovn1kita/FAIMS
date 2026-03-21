// lib/domain/repositories/first_aid_kit_repository.dart
import 'package:frontend/data/dtos/create_kit_dto.dart';
import 'package:frontend/data/dtos/department_dto.dart';
import 'package:frontend/data/dtos/first_aid_kit_list_dto.dart';
import 'package:frontend/data/dtos/medication_dto.dart';
import 'package:frontend/data/dtos/medication_quantity_update_dto.dart';
import 'package:frontend/data/dtos/medication_refill_dto.dart';
import 'package:frontend/data/dtos/medication_write_off_dto.dart';
import 'package:frontend/data/dtos/room_dto.dart';
import 'package:frontend/data/dtos/update_kit_dto.dart';
import 'package:frontend/data/dtos/user_dto.dart';
import 'package:frontend/data/dtos/medication_create_dto.dart'; // <<<--- НОВИЙ ІМПОРТ
import 'package:frontend/data/dtos/medication_update_dto.dart'; // <<<--- НОВИЙ ІМПОРТ
import 'package:frontend/data/services/first_aid_kit_api_service.dart';

class FirstAidKitRepository {
  final FirstAidKitApiService _apiService = FirstAidKitApiService();

  Future<List<FirstAidKitListDto>> getFirstAidKits({
    String? searchTerm,
    String? statusFilter,
    String? responsibleUserId,
    String? departmentId,
  }) async {
    try {
      return await _apiService.getFirstAidKits(
        searchTerm: searchTerm,
        statusFilter: statusFilter,
        responsibleUserId: responsibleUserId,
        departmentId: departmentId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<FirstAidKitListDto> getMyKit() async {
    try {
      return await _apiService.getMyKit();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserDto>> getResponsibleUsers() async {
    try {
      return await _apiService.getResponsibleUsers();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DepartmentDto>> getDepartments() async {
    try {
      return await _apiService.getDepartments();
    } catch (e) {
      rethrow;
    }
  }

  Future<FirstAidKitListDto> getFirstAidKitById(String id) async {
    try {
      return await _apiService.getFirstAidKitById(id);
    } catch (e) {
      rethrow;
    }
  }

  // ==== МЕТОДИ ДЛЯ МЕДИКАМЕНТІВ ====

  Future<List<MedicationDto>> getMedicationsForKit(String kitId) async {
    try {
      return await _apiService.getMedicationsForKit(kitId);
    } catch (e) {
      rethrow;
    }
  }

  Future<MedicationDto> getMedicationById(String medicationId) async {
    try {
      return await _apiService.getMedicationById(medicationId);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addMedication(MedicationCreateDto medicationDto) async {
    try {
      return await _apiService.addMedication(medicationDto);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMedication(MedicationUpdateDto medicationDto) async {
    try {
      await _apiService.updateMedication(medicationDto);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> useMedication(String medicationId, MedicationQuantityUpdateDto dto) async {
    try {
      await _apiService.useMedication(medicationId, dto);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> writeOffMedication(String medicationId, MedicationWriteOffDto dto) async {
    try {
      await _apiService.writeOffMedication(medicationId, dto);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMedication(String medicationId, String kitId) async {
    try {
      await _apiService.deleteMedication(medicationId, kitId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RoomDto>> getRoomsByDepartmentId(String departmentId) async {
    try {
      return await _apiService.getRoomsByDepartmentId(departmentId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createKit(CreateKitDto kitDto) async {
    try {
      await _apiService.createKit(kitDto);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateKit(String kitId, UpdateKitDto kitDto) async {
    try {
      await _apiService.updateKit(kitId, kitDto);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteKit(String kitId) async {
    try {
      await _apiService.deleteKit(kitId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refillMedication(String medicationId, MedicationRefillDto dto) async {
    await _apiService.refillMedication(medicationId, dto);
  }
  
}