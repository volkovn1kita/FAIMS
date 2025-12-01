namespace Application.DTOs;

public record RoomListAllDto(
    Guid Id,
    string Name,
    Guid DepartmentId,
    string DepartmentName
);