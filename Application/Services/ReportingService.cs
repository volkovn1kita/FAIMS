using Application.DTOs;
using Application.Interfaces;
using Domain;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Application.Services;

public class ReportingService : IReportingService
{
    private readonly IMonitoringService _monitoringService;
    private readonly IFirstAidKitRepository _kitRepository;
    private readonly IJournalRepository _journalRepository;

    public ReportingService(IMonitoringService monitoringService,
                            IFirstAidKitRepository kitRepository,
                            IJournalRepository journalRepository)
    {
        _monitoringService = monitoringService;
        _kitRepository = kitRepository;
        _journalRepository = journalRepository;
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

    public async Task<IEnumerable<ReportItemDto>> GetPurchasingReportAsync(DateTime startDate, DateTime endDate)
    {
        var reportItems = new List<ReportItemDto>();

        var lowQuantityMeds = await _monitoringService.GetLowQuantityMedicationsAsync();
        var deficitItems = lowQuantityMeds
            .GroupBy(m => new { m.Name, Unit = m.Unit.ToString() })
            .Select(g => new ReportItemDto
            {
                MedicationName = g.Key.Name,
                Quantity = g.Sum(m => m.MinimumQuantity - m.Quantity),
                Unit = g.Key.Unit,
                Reason = "current_deficit"
            });
            
        reportItems.AddRange(deficitItems);

        var journals = await _journalRepository.GetEntriesByDateRangeAsync(startDate, endDate);
        var consumptionItems = journals
            .GroupBy(j => new { j.MedicationName, Unit = j.Unit.ToString() })
            .Select(g => 
            {
                var consumed = g.Where(j => j.ActionType == JournalAction.Used || j.ActionType == JournalAction.WrittenOff)
                                .Sum(j => Math.Abs(j.Quantity));
                var refilled = g.Where(j => j.ActionType == JournalAction.Added || j.ActionType == JournalAction.QuantityChanged)
                                .Sum(j => Math.Abs(j.Quantity));
                var netNeed = consumed - refilled;

                return new ReportItemDto
                {
                    MedicationName = g.Key.MedicationName,
                    Quantity = netNeed,
                    Unit = g.Key.Unit,
                    Reason = "period_expenses"
                };
            })
            .Where(r => r.Quantity > 0);

        reportItems.AddRange(consumptionItems);

        var finalReport = reportItems
            .GroupBy(r => new { r.MedicationName, r.Unit })
            .Select(g => new ReportItemDto
            {
                MedicationName = g.Key.MedicationName,
                Quantity = g.Max(x => x.Quantity),
                Unit = g.Key.Unit,
                Reason = g.OrderBy(x => x.Quantity).Last().Reason
            })
            .Where(r => r.Quantity > 0)
            .OrderByDescending(r => r.Quantity)
            .ToList();

        return finalReport;
    }

    public async Task<IEnumerable<ReportItemDto>> GetDisposalReportAsync(DateTime startDate, DateTime endDate)
    {
        var reportItems = new List<ReportItemDto>();

        var criticalMeds = await _monitoringService.GetCriticalMedicationsAsync();
        var expiredMeds = criticalMeds.Where(m => m.Status.ToString() == "Expired");
        
        foreach (var med in expiredMeds)
        {
            reportItems.Add(new ReportItemDto
            {
                MedicationName = med.Name,
                Quantity = med.Quantity,
                Unit = med.Unit.ToString(),
                Reason = "expired_in_kits"
            });
        }

        var journals = await _journalRepository.GetEntriesByDateRangeAsync(startDate, endDate);
        var writtenOffJournals = journals
            .Where(j => j.ActionType == JournalAction.WrittenOff)
            .GroupBy(j => new { j.MedicationName, Unit = j.Unit.ToString() })
            .Select(g => new ReportItemDto
            {
                MedicationName = g.Key.MedicationName,
                Quantity = g.Sum(j => Math.Abs(j.Quantity)),
                Unit = g.Key.Unit,
                Reason = "written_off_period"
            });

        reportItems.AddRange(writtenOffJournals);

        var groupedReport = reportItems
            .GroupBy(r => new { r.MedicationName, r.Unit })
            .Select(g => new ReportItemDto
            {
                MedicationName = g.Key.MedicationName,
                Quantity = g.Sum(x => x.Quantity),
                Unit = g.Key.Unit,
                Reason = g.First().Reason
            })
            .OrderByDescending(r => r.Quantity)
            .ToList();

        return groupedReport;
    }
}