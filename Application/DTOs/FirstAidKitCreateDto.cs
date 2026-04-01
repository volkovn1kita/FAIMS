using System.ComponentModel.DataAnnotations;

namespace Application.DTOs;

public record class FirstAidKitCreateDto
(
    [Required]
    [MaxLength(50)]
    string UniqueNumber,

    [Required]
    [MaxLength(200)]
    string Name,

    [Required]
    Guid RoomId,

    [Required]
    Guid ResponsibleUserId
);
