using System.ComponentModel.DataAnnotations;

namespace Application.DTOs;

public record MedicationWriteOffDto(
    [Range(1, int.MaxValue)] int Quantity,
    [Required] string Reason
);