using Domain;

namespace Application.Interfaces;

public interface IKitTemplateRepository
{
    Task<IEnumerable<KitTemplate>> GetAllAsync();
    Task<KitTemplate?> GetByIdAsync(Guid id);
    Task AddAsync(KitTemplate template);
    Task UpdateAsync(KitTemplate template);
    Task DeleteAsync(KitTemplate template);
    Task SaveChangesAsync();
}
