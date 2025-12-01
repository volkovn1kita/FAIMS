
import 'package:json_annotation/json_annotation.dart';

part 'room_dto.g.dart';

@JsonSerializable()
class RoomDto {
  final String id;
  final String departmentId; // Можливо, бекенд повертає departmentId
  final String name;

  RoomDto({
    required this.id,
    required this.departmentId,
    required this.name,
  });

  factory RoomDto.fromJson(Map<String, dynamic> json) => _$RoomDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RoomDtoToJson(this);
}