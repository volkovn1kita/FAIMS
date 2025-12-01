
using Domain; 

namespace Application.DTOs;

public record MedicationResponseDto(
    Guid Id,
    string Name,
    int Quantity,
    DateTime ExpirationDate,
    int MinimumQuantity,
    MeasurementUnit Unit,
    ExpirationStatus Status,
    Guid FirstAidKitId
);