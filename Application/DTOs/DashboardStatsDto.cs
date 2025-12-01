namespace Application.DTOs;

public record DashboardStatsDto(
    IEnumerable<MedicationStatDto> TopUsedMedications,
    IEnumerable<MedicationStatDto> TopExpiredMedications
);