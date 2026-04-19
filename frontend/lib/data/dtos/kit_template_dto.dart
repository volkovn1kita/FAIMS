import 'package:faims/data/dtos/measurement_unit.dart';

class KitTemplateItemDto {
  final String id;
  final String name;
  final int minimumQuantity;
  final MeasurementUnit unit;

  const KitTemplateItemDto({
    required this.id,
    required this.name,
    required this.minimumQuantity,
    required this.unit,
  });

  factory KitTemplateItemDto.fromJson(Map<String, dynamic> json) {
    return KitTemplateItemDto(
      id: json['id'] as String,
      name: json['name'] as String,
      minimumQuantity: json['minimumQuantity'] as int,
      unit: parseMeasurementUnit(json['unit'] as String?) ?? MeasurementUnit.pieces,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'minimumQuantity': minimumQuantity,
        'unit': unit.name[0].toUpperCase() + unit.name.substring(1),
      };
}

class KitTemplateDto {
  final String id;
  final String name;
  final String? description;
  final bool isSystem;
  final String? regulatoryReference;
  final List<KitTemplateItemDto> items;

  const KitTemplateDto({
    required this.id,
    required this.name,
    this.description,
    required this.isSystem,
    this.regulatoryReference,
    required this.items,
  });

  factory KitTemplateDto.fromJson(Map<String, dynamic> json) {
    return KitTemplateDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isSystem: json['isSystem'] as bool,
      regulatoryReference: json['regulatoryReference'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => KitTemplateItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
