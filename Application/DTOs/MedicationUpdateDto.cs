using System.ComponentModel.DataAnnotations;
using Domain;

namespace Application.DTOs;

public record MedicationUpdateDto(
    [Required] Guid Id,
    [Required] Guid FirstAidKitId,
    [Required][StringLength(100, MinimumLength = 2)] string Name,
    [Required] MeasurementUnit Unit,
    [Range(0, int.MaxValue)] int Quantity,
    [Range(1, int.MaxValue)] int MinimumQuantity,
    DateTime ExpirationDate
);