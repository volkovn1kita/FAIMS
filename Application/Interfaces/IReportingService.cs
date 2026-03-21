using System;
using Application.DTOs;

namespace Application.Interfaces;

public interface IReportingService
{
    public Task<IEnumerable<ReportCriticalItemDto>> GenerateCriticalItemsReportAsync();
    public Task<IEnumerable<ReportKitStatusDto>> GenerateKitStatusReportAsync();
    Task<IEnumerable<ReportItemDto>> GetPurchasingReportAsync(DateTime startDate, DateTime endDate);
    Task<IEnumerable<ReportItemDto>> GetDisposalReportAsync(DateTime startDate, DateTime endDate);
}
