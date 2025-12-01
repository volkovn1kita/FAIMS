using System.ComponentModel.DataAnnotations;

namespace Application.DTOs;

public record MedicationQuantityUpdateDto(
    [Range(1, int.MaxValue)] int Quantity
);