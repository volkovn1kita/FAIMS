using System;
using Application.Interfaces;
using Domain;

namespace Application.Services;

public class MonitoringService : IMonitoringService
{
    private readonly IFirstAidKitRepository _kitRepository;
    public MonitoringService(IFirstAidKitRepository kitRepository)
    {
        _kitRepository = kitRepository;
    }
    public async Task<Dictionary<ExpirationStatus, int>> CheckAllExpirationsAsync()
    {
        var allMedications = await _kitRepository.GetAllMedicationsAsync();

        var statusCounts = new Dictionary<ExpirationStatus, int>();
        foreach (var status in Enum.GetValues<ExpirationStatus>())
        {
            statusCounts[status] = 0;
        }
        foreach (var med in allMedications)
        {
            var status = med.Status;
            statusCounts[status]++;
        }
        return statusCounts;
    }

    public async Task<IEnumerable<Medication>> GetCriticalMedicationsAsync()
    {
        var allMedications = await _kitRepository.GetAllMedicationsAsync();
        var criticalMedications = allMedications
        .Where(m => m.Quantity > 0  // empty batches shouldn't trigger expiration alarms
                    && (m.Status == ExpirationStatus.Critical
                        || m.Status == ExpirationStatus.Warning
                        || m.Status == ExpirationStatus.Expired))
        .ToList();
        return criticalMedications;
    }

    public async Task<IEnumerable<Medication>> GetLowQuantityMedicationsAsync()
    {
        var allMedications = await _kitRepository.GetAllMedicationsAsync();

        // A medication is low only when the SUM across its batches (same kit + name + unit)
        // is below the group's minimum. Return all batches belonging to genuinely-low groups
        // so downstream callers can still see per-batch detail.
        var lowGroupKeys = allMedications
            .GroupBy(m => (m.FirstAidKitId, m.Name, m.Unit))
            .Where(g => g.Sum(m => m.Quantity) < g.Max(m => m.MinimumQuantity))
            .Select(g => g.Key)
            .ToHashSet();

        return allMedications
            .Where(m => lowGroupKeys.Contains((m.FirstAidKitId, m.Name, m.Unit)))
            .ToList();
    }
}
