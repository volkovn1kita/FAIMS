using System.ComponentModel.DataAnnotations;

namespace Application.DTOs;

public record class FirstAidKitUpdateDto
(
    [Required]
    Guid Id,

    [Required]
    [MaxLength(200)]
    string Name,

    [Required]
    Guid RoomId,

    [Required]
    Guid ResponsibleUserId
);
