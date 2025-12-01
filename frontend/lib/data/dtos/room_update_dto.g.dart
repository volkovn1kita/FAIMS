// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_update_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomUpdateDto _$RoomUpdateDtoFromJson(Map<String, dynamic> json) =>
    RoomUpdateDto(
      id: json['id'] as String,
      name: json['name'] as String,
      departmentId: json['departmentId'] as String,
    );

Map<String, dynamic> _$RoomUpdateDtoToJson(RoomUpdateDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'departmentId': instance.departmentId,
    };
