import 'package:json_annotation/json_annotation.dart';

part 'room_list_dto.g.dart'; // Змінено на room_list_dto.g.dart

@JsonSerializable()
class RoomListDto {
  final String id;
  final String name;

  RoomListDto({
    required this.id,
    required this.name,
  });

  factory RoomListDto.fromJson(Map<String, dynamic> json) => _$RoomListDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RoomListDtoToJson(this);
}