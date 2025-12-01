namespace Application.DTOs;

public record FirstAidKitListDto(
    Guid Id,
    Guid DepartmentId,
    Guid ResponsibleUserId,
    Guid RoomId,
    string UniqueNumber,
    string Name,
    string DepartmentName,
    string RoomName,
    string ResponsibleUserFirstName,
    string ResponsibleUserLastName,

    int CriticalItemsCount,
    int ExpiredItemsCount,
    int LowQuantityItemsCount,

    DateTime CreatedAt,
    DateTime? UpdatedAt,
    string StatusBadge
);
