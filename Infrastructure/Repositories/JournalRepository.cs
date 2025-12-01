using Application.Interfaces;
using Domain;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class JournalRepository : IJournalRepository
{
    private readonly ApplicationDbContext _dbContext;

    public JournalRepository(ApplicationDbContext dbContext)
    {
        _dbContext = dbContext;
    }
    public async Task AddEntryAsync(Journal entry)
    {
        await _dbContext.Journals.AddAsync(entry);
    }

    public async Task<IEnumerable<Journal>> GetEntriesByDateRangeAsync(DateTime startDate, DateTime endDate)
    {
        return await _dbContext.Journals
            .Include(j => j.User)
            .Include(j => j.FirstAidKit)
            .Where(j => j.CreatedDate >= startDate && j.CreatedDate <= endDate)
            .OrderBy(j => j.CreatedDate)
            .ToListAsync();
    }

    public async Task<IEnumerable<Journal>> GetEntriesByKitIdAsync(Guid kitId)
    {
        return await _dbContext.Journals
            .Include(j => j.User)
            .Include(j => j.FirstAidKit)
            .Where(j => j.FirstAidKitId == kitId)
            .OrderByDescending(j => j.CreatedDate)
            .ToListAsync(); 
    }

    public async Task SaveChangesAsync()
    {
        await _dbContext.SaveChangesAsync();
    }
}
