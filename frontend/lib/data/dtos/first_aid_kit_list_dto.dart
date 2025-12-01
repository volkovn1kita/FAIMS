
import 'package:json_annotation/json_annotation.dart';


part 'first_aid_kit_list_dto.g.dart'; 

@JsonSerializable()
class FirstAidKitListDto {
  final String id;
  final String departmentId;
  final String responsibleUserId;
  final String roomId;
  final String uniqueNumber;
  final String name;
  final String departmentName;
  final String roomName;
  final String responsibleUserFirstName;
  final String responsibleUserLastName;
  final int criticalItemsCount;
  final int expiredItemsCount;
  final int lowQuantityItemsCount;
  final DateTime createdAt;
  final DateTime? lastAuditDate;
  final String statusBadge;

  FirstAidKitListDto({
    required this.id,
    required this.departmentId,
    required this.responsibleUserId,
    required this.roomId,
    required this.uniqueNumber,
    required this.name,
    required this.departmentName,
    required this.roomName,
    required this.responsibleUserFirstName,
    required this.responsibleUserLastName,
    required this.criticalItemsCount,
    required this.expiredItemsCount,
    required this.lowQuantityItemsCount,
    required this.createdAt,
    this.lastAuditDate,
    required this.statusBadge,
  });

  factory FirstAidKitListDto.fromJson(Map<String, dynamic> json) =>
      _$FirstAidKitListDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FirstAidKitListDtoToJson(this);
}