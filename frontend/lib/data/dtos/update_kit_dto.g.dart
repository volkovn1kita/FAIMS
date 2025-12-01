// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_kit_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateKitDto _$UpdateKitDtoFromJson(Map<String, dynamic> json) => UpdateKitDto(
  id: json['Id'] as String,
  name: json['Name'] as String,
  roomId: json['RoomId'] as String,
  responsibleUserId: json['ResponsibleUserId'] as String,
);

Map<String, dynamic> _$UpdateKitDtoToJson(UpdateKitDto instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'RoomId': instance.roomId,
      'ResponsibleUserId': instance.responsibleUserId,
    };
