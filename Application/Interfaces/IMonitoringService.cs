using System;
using Domain;

namespace Application.Interfaces;

public interface IMonitoringService
{
    Task<Dictionary<ExpirationStatus, int>> CheckAllExpirationsAsync();
    Task<IEnumerable<Medication>> GetCriticalMedicationsAsync();
    Task<IEnumerable<Medication>> GetLowQuantityMedicationsAsync();
 
}
