class MedicationRefillDto {
  final int addedQuantity;
  final DateTime newExpirationDate;

  MedicationRefillDto({
    required this.addedQuantity,
    required this.newExpirationDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'addedQuantity': addedQuantity,
      'newExpirationDate': newExpirationDate.toUtc().toIso8601String(),
    };
  }
}