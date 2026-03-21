class ReportItemDto {
  final String medicationName;
  final int quantity;
  final String unit;
  final String reason;

  ReportItemDto({
    required this.medicationName,
    required this.quantity,
    required this.unit,
    required this.reason,
  });

  factory ReportItemDto.fromJson(Map<String, dynamic> json) {
    return ReportItemDto(
      medicationName: json['medicationName'] ?? '',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '',
      reason: json['reason'] ?? '',
    );
  }
}