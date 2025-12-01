import 'package:json_annotation/json_annotation.dart';

part 'room_list_all_dto.g.dart';

@JsonSerializable()
class RoomListAllDto {
  final String id;
  final String name;
  final String departmentId;
  final String departmentName;

  RoomListAllDto({
    required this.id,
    required this.name,
    required this.departmentId,
    required this.departmentName,
  });

  factory RoomListAllDto.fromJson(Map<String, dynamic> json) => _$RoomListAllDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RoomListAllDtoToJson(this);
}