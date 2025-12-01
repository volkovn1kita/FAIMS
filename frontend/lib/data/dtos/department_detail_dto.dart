import 'package:json_annotation/json_annotation.dart';
import 'package:frontend/data/dtos/room_list_dto.dart'; // Важливо імпортувати

part 'department_detail_dto.g.dart';

@JsonSerializable()
class DepartmentDetailDto {
  final String id;
  final String name;
  final List<RoomListDto> rooms; // Використовуємо RoomListDto

  DepartmentDetailDto({
    required this.id,
    required this.name,
    required this.rooms,
  });

  factory DepartmentDetailDto.fromJson(Map<String, dynamic> json) => _$DepartmentDetailDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DepartmentDetailDtoToJson(this);
}