
import 'package:json_annotation/json_annotation.dart';

part 'update_kit_dto.g.dart';

@JsonSerializable()
class UpdateKitDto {
  @JsonKey(name: 'Id')
  final String id; 

  @JsonKey(name: 'Name')
  final String name;
  
  @JsonKey(name: 'RoomId')
  final String roomId;
  
  @JsonKey(name: 'ResponsibleUserId')
  final String responsibleUserId;

  UpdateKitDto({
    required this.id,
    required this.name,
    required this.roomId,
    required this.responsibleUserId,
  });

  factory UpdateKitDto.fromJson(Map<String, dynamic> json) => _$UpdateKitDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateKitDtoToJson(this);

  // CopyWith все ще може бути корисним
  UpdateKitDto copyWith({
    String? id,
    String? name,
    String? roomId,
    String? responsibleUserId,
  }) {
    return UpdateKitDto(
      id: id ?? this.id,
      name: name ?? this.name,
      roomId: roomId ?? this.roomId,
      responsibleUserId: responsibleUserId ?? this.responsibleUserId,
    );
  }
}