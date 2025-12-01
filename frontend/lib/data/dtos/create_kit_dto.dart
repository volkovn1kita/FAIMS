
import 'package:json_annotation/json_annotation.dart';

part 'create_kit_dto.g.dart'; 

@JsonSerializable()
class CreateKitDto {
  @JsonKey(name: 'uniqueNumber')
  final String uniqueNumber;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'roomId')
  final String roomId;
  
  @JsonKey(name: 'responsibleUserId')
  final String responsibleUserId;

  CreateKitDto({
    required this.uniqueNumber,
    required this.name,
    required this.roomId,
    required this.responsibleUserId,
  });

  factory CreateKitDto.fromJson(Map<String, dynamic> json) => _$CreateKitDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CreateKitDtoToJson(this);
}