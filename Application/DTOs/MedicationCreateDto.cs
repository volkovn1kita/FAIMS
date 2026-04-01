using System.ComponentModel.DataAnnotations;
using Domain;

namespace Application.DTOs;

public record class MedicationCreateDto
(
    [Required]
    Guid FirstAidKitId,

    [Required]
    [MaxLength(200)]
    string Name,

    [Range(1, int.MaxValue)]
    int Quantity,

    [Range(1, int.MaxValue)]
    int MinimumQuantity,

    MeasurementUnit Unit,

    [Required]
    DateTime ExpirationDate
);
