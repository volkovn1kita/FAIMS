using System;
using Application.DTOs;

namespace Application.Interfaces;

public interface IAnalyticsRepository
{
    Task<IEnumerable<MedicationStatDto>> GetGlobalTopUsedMedicationsAsync(int topCount);
    Task<IEnumerable<MedicationStatDto>> GetGlobalTopExpiredMedicationsAsync(int topCount);
}
