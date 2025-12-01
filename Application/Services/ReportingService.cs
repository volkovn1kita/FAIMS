
using Application.DTOs;
using Application.Interfaces;

namespace Application.Services;

public class ReportingService : IReportingService
{
    private readonly IMonitoringService _monitoringService;
    private readonly IFirstAidKitRepository _kitRepository;

    public ReportingService(IMonitoringService monitoringService,
                            IFirstAidKitRepository kitRepository)
    {
        _monitoringService = monitoringService;
        _kitRepository = kitRepository;
    }

    public async Task<IEnumerable<ReportCriticalItemDto>> GenerateCriticalItemsReportAsync()
    {
        var criticalItems = new List<ReportCriticalItemDto>();
        var expirationCritical = await _monitoringService.GetCriticalMedicationsAsync();
        var lowQuantityItems = await _monitoringService.GetLowQuantityMedicationsAsync();

        var allFirstAidKits = await _kitRepository.GetFilteredKitsAsync(null, null, null);
        var kitsDictionary = allFirstAidKits.ToDictionary(k => k.Id);

        foreach (var med in expirationCritical)
        {
            kitsDictionary.TryGetValue(med.FirstAidKitId, out var kit);

            criticalItems.Add(new ReportCriticalItemDto(
                MedicationId: med.Id,
                KitName: kit?.Name ?? "Unknown first aid kit",
                MedicationName: med.Name,
                Quantity: med.Quantity,
                Status: med.Status,
                Reason: $"Expiration date: {med.Status}"
            ));
        }

        var lowQuantityOnly = lowQuantityItems
            .Where(med => !expirationCritical.Any(c => c.Id == med.Id))
            .ToList();

        foreach (var med in lowQuantityOnly)
        {
            kitsDictionary.TryGetValue(med.FirstAidKitId, out var kit);

            criticalItems.Add(new ReportCriticalItemDto(
                MedicationId: med.Id,
                KitName: kit?.Name ?? "Unknown first aid kit",
                MedicationName: med.Name,
                Quantity: med.Quantity,
                Status: med.Status, 
                Reason: $"Low number ({med.Quantity} < {med.MinimumQuantity})"
            ));
        }

        return criticalItems.OrderBy(i => i.KitName).ToList();
    }

    public async Task<IEnumerable<ReportKitStatusDto>> GenerateKitStatusReportAsync()
    {
        var allKits = await _kitRepository.GetFilteredKitsAsync(null, null, null);

        var reports = new List<ReportKitStatusDto>();
        
        foreach (var kit in allKits)
        {
            var medications = kit.Medications;

            var criticalCount = 0;
            var lowQuantityCount = 0;
            var expiredCount = 0; 

            foreach (var med in medications)
            {
                if (med.ExpirationDate <= DateTime.UtcNow)
                {
                    expiredCount++;
                    criticalCount++;
                }
                else if (med.ExpirationDate <= DateTime.UtcNow.AddDays(30))
                {
                    criticalCount++;
                }

                if (med.Quantity < med.MinimumQuantity)
                {
                    lowQuantityCount++;
                }
            }
            
            string overallStatus = "OK";
            if (expiredCount > 0 || criticalCount > 0)
            {
                overallStatus = "Needs Attention";
            }
            else if (lowQuantityCount > 0)
            {
                overallStatus = "Low Stock";
            }

            reports.Add(new ReportKitStatusDto(
                KitId: kit.Id,
                UniqueNumber: kit.UniqueNumber,
                RoomName: kit.Room?.Name ?? "N/A",
                ResponsibleUser: $"{kit.ResponsibleUser?.FirstName ?? "N/A"} {kit.ResponsibleUser?.LastName ?? ""}",
                TotalMedications: medications.Count(),
                CriticalCount: criticalCount,
                LowQuantityCount: lowQuantityCount,
                OverallStatus: overallStatus
            ));
        }

        return reports.OrderByDescending(r => r.CriticalCount).ToList();
    }
}