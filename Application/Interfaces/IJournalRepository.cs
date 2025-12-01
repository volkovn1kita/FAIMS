using System;
using Domain;

namespace Application.Interfaces;

public interface IJournalRepository
{
    Task AddEntryAsync(Journal entry);
    Task<IEnumerable<Journal>> GetEntriesByKitIdAsync(Guid kitId);
    Task<IEnumerable<Journal>> GetEntriesByDateRangeAsync(DateTime startDate, DateTime endDate);
    Task SaveChangesAsync();
}