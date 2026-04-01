using System.ComponentModel.DataAnnotations;

namespace Application.DTOs;

public record RoomCreateDto(
    [Required]
    Guid DepartmentId,

    [Required]
    [MaxLength(200)]
    string Name
);
