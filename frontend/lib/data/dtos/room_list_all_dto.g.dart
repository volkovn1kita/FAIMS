// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_list_all_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomListAllDto _$RoomListAllDtoFromJson(Map<String, dynamic> json) =>
    RoomListAllDto(
      id: json['id'] as String,
      name: json['name'] as String,
      departmentId: json['departmentId'] as String,
      departmentName: json['departmentName'] as String,
    );

Map<String, dynamic> _$RoomListAllDtoToJson(RoomListAllDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'departmentId': instance.departmentId,
      'departmentName': instance.departmentName,
    };
