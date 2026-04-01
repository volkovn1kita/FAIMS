using System.ComponentModel.DataAnnotations;

namespace Application.DTOs;

public record DepartmentCreateDto(
    [Required]
    [MaxLength(200)]
    string Name
);
