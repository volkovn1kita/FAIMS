namespace Application.DTOs;

public record class FirstAidKitUpdateDto
(
    Guid Id,
    string Name,
    Guid RoomId,
    Guid ResponsibleUserId
);
