using System;
using Application.DTOs;

namespace Application.Interfaces;

public interface IReportingService
{
    public Task<IEnumerable<ReportCriticalItemDto>> GenerateCriticalItemsReportAsync();
    public Task<IEnumerable<ReportKitStatusDto>> GenerateKitStatusReportAsync();
}
