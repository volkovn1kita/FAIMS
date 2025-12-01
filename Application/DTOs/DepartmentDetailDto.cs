namespace Application.DTOs;

public record DepartmentDetailDto(
    Guid Id,
    string Name,
    IEnumerable<RoomListDto> Rooms 
);
