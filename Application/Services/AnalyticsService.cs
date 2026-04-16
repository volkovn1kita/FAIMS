using Application.DTOs;
using Application.Interfaces;

namespace Application.Services;

public class AnalyticsService : IAnalyticsService
{
    private readonly IAnalyticsRepository _analyticsRepository;

    public AnalyticsService(IAnalyticsRepository analyticsRepository)
    {
        _analyticsRepository = analyticsRepository;
    }

    public async Task<DashboardStatsDto> GetGlobalStatsAsync()
    {
        var topUsed = await _analyticsRepository.GetGlobalTopUsedMedicationsAsync(5);
        var topExpired = await _analyticsRepository.GetGlobalTopExpiredMedicationsAsync(5);

        return new DashboardStatsDto(
            TopUsedMedications: topUsed,
            TopExpiredMedications: topExpired
        );
    }
}