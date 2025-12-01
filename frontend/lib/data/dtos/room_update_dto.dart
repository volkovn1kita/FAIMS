import 'package:json_annotation/json_annotation.dart';

part 'room_update_dto.g.dart';

@JsonSerializable()
class RoomUpdateDto {
  final String id; // Додаємо ID для оновлення конкретної кімнати
  final String name;
  final String departmentId; // Можна змінити департамент кімнати

  RoomUpdateDto({
    required this.id,
    required this.name,
    required this.departmentId,
  });

  factory RoomUpdateDto.fromJson(Map<String, dynamic> json) => _$RoomUpdateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RoomUpdateDtoToJson(this);
}