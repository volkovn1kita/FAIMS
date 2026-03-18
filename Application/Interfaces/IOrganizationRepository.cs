using Domain;

namespace Application.Interfaces
{
    public interface IOrganizationRepository
    {
        Task AddAsync(Organization organization);
        Task SaveChangesAsync();
    }
}