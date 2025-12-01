// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'first_aid_kit_list_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirstAidKitListDto _$FirstAidKitListDtoFromJson(Map<String, dynamic> json) =>
    FirstAidKitListDto(
      id: json['id'] as String,
      departmentId: json['departmentId'] as String,
      responsibleUserId: json['responsibleUserId'] as String,
      roomId: json['roomId'] as String,
      uniqueNumber: json['uniqueNumber'] as String,
      name: json['name'] as String,
      departmentName: json['departmentName'] as String,
      roomName: json['roomName'] as String,
      responsibleUserFirstName: json['responsibleUserFirstName'] as String,
      responsibleUserLastName: json['responsibleUserLastName'] as String,
      criticalItemsCount: (json['criticalItemsCount'] as num).toInt(),
      expiredItemsCount: (json['expiredItemsCount'] as num).toInt(),
      lowQuantityItemsCount: (json['lowQuantityItemsCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAuditDate: json['lastAuditDate'] == null
          ? null
          : DateTime.parse(json['lastAuditDate'] as String),
      statusBadge: json['statusBadge'] as String,
    );

Map<String, dynamic> _$FirstAidKitListDtoToJson(FirstAidKitListDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'departmentId': instance.departmentId,
      'responsibleUserId': instance.responsibleUserId,
      'roomId': instance.roomId,
      'uniqueNumber': instance.uniqueNumber,
      'name': instance.name,
      'departmentName': instance.departmentName,
      'roomName': instance.roomName,
      'responsibleUserFirstName': instance.responsibleUserFirstName,
      'responsibleUserLastName': instance.responsibleUserLastName,
      'criticalItemsCount': instance.criticalItemsCount,
      'expiredItemsCount': instance.expiredItemsCount,
      'lowQuantityItemsCount': instance.lowQuantityItemsCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastAuditDate': instance.lastAuditDate?.toIso8601String(),
      'statusBadge': instance.statusBadge,
    };
