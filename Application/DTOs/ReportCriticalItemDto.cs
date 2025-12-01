using Domain;

namespace Application.DTOs;

public record ReportCriticalItemDto(
    Guid MedicationId,
    string KitName,
    string MedicationName,
    int Quantity,
    ExpirationStatus Status,
    string Reason

);
