using Domain;

namespace Application.DTOs;

public record class MedicationCreateDto
(
    Guid FirstAidKitId,
    string Name,
    int Quantity,
    int MinimumQuantity,
    MeasurementUnit Unit,
    DateTime ExpirationDate
);
