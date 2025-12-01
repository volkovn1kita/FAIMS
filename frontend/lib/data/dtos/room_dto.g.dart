// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomDto _$RoomDtoFromJson(Map<String, dynamic> json) => RoomDto(
  id: json['id'] as String,
  departmentId: json['departmentId'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$RoomDtoToJson(RoomDto instance) => <String, dynamic>{
  'id': instance.id,
  'departmentId': instance.departmentId,
  'name': instance.name,
};
