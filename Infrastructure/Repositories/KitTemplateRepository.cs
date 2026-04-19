using Application.Interfaces;
using Domain;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class KitTemplateRepository : IKitTemplateRepository
{
    private readonly ApplicationDbContext _dbContext;

    public KitTemplateRepository(ApplicationDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    /// <summary>
    /// Повертає системні шаблони + шаблони поточної організації.
    /// Query filter вже фільтрує за (IsSystem || OrganizationId == current).
    /// </summary>
    public async Task<IEnumerable<KitTemplate>> GetAllAsync()
    {
        return await _dbContext.KitTemplates
            .Include(t => t.Items.Where(i => !i.IsDeleted))
            .OrderBy(t => !t.IsSystem)   // системні — вгорі
            .ThenBy(t => t.Name)
            .ToListAsync();
    }

    public async Task<KitTemplate?> GetByIdAsync(Guid id)
    {
        return await _dbContext.KitTemplates
            .Include(t => t.Items.Where(i => !i.IsDeleted))
            .FirstOrDefaultAsync(t => t.Id == id);
    }

    public async Task AddAsync(KitTemplate template)
    {
        await _dbContext.KitTemplates.AddAsync(template);
    }

    public Task UpdateAsync(KitTemplate template)
    {
        template.UpdatedDate = DateTime.UtcNow;
        _dbContext.KitTemplates.Update(template);
        return Task.CompletedTask;
    }

    public Task DeleteAsync(KitTemplate template)
    {
        template.IsDeleted = true;
        template.DeletedAt = DateTime.UtcNow;
        _dbContext.KitTemplates.Update(template);
        return Task.CompletedTask;
    }

    public async Task SaveChangesAsync()
    {
        await _dbContext.SaveChangesAsync();
    }
}
