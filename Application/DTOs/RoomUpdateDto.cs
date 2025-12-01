using System.ComponentModel.DataAnnotations;

namespace Application.DTOs;

public record RoomUpdateDto(
    [Required] string Name,
    [Required] Guid DepartmentId
);
