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
        .Where(m => m.Status == ExpirationStatus.Critical
                    || m.Status == ExpirationStatus.Warning
                    || m.Status == ExpirationStatus.Expired)
        .ToList();
        return criticalMedications;
    }

    public async Task<IEnumerable<Medication>> GetLowQuantityMedicationsAsync()
    {
        var allMedications = await _kitRepository.GetAllMedicationsAsync();
        var lowQuantityMeds = allMedications
            .Where(m => m.Quantity < m.MinimumQuantity)
            .ToList();
        
        return lowQuantityMeds;
    }
}
