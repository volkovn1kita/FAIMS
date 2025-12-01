import 'package:json_annotation/json_annotation.dart';

part 'room_create_dto.g.dart';

@JsonSerializable()
class RoomCreateDto {
  final String departmentId;
  final String name;

  RoomCreateDto({
    required this.departmentId,
    required this.name,
  });

  factory RoomCreateDto.fromJson(Map<String, dynamic> json) => _$RoomCreateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RoomCreateDtoToJson(this);
}