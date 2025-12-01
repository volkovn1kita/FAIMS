namespace Application.DTOs;

public record ReportKitStatusDto(
    Guid KitId,
    string UniqueNumber,
    string RoomName,
    string ResponsibleUser,
    int TotalMedications,
    int CriticalCount,
    int LowQuantityCount,
    string OverallStatus
);
