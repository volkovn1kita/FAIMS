// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_kit_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateKitDto _$CreateKitDtoFromJson(Map<String, dynamic> json) => CreateKitDto(
  uniqueNumber: json['uniqueNumber'] as String,
  name: json['name'] as String,
  roomId: json['roomId'] as String,
  responsibleUserId: json['responsibleUserId'] as String,
);

Map<String, dynamic> _$CreateKitDtoToJson(CreateKitDto instance) =>
    <String, dynamic>{
      'uniqueNumber': instance.uniqueNumber,
      'name': instance.name,
      'roomId': instance.roomId,
      'responsibleUserId': instance.responsibleUserId,
    };
