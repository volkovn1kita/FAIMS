namespace Application.DTOs;

public record class FirstAidKitCreateDto
(
    string UniqueNumber,
    string Name,
    Guid RoomId,
    Guid ResponsibleUserId
);