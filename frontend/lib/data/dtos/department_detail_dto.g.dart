// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepartmentDetailDto _$DepartmentDetailDtoFromJson(Map<String, dynamic> json) =>
    DepartmentDetailDto(
      id: json['id'] as String,
      name: json['name'] as String,
      rooms: (json['rooms'] as List<dynamic>)
          .map((e) => RoomListDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DepartmentDetailDtoToJson(
  DepartmentDetailDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'rooms': instance.rooms,
};
