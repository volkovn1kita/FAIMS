using Application.DTOs;
using Domain;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Application.Interfaces
{
    public interface IUserRepository
    {
        Task<IEnumerable<User>> GetAllFilteredAndSortedAsync(UserFilterAndPaginationDto filterDto);
        Task<int> CountActiveAdminsAsync(Guid organizationId);

        Task<IEnumerable<User>> GetAllAsync();
        Task<IEnumerable<User>> GetAllByOrganizationAsync(Guid organizationId);
        Task<User?> GetByIdAsync(Guid id);
        Task<User?> GetByEmailAsync(string email);
        Task<User?> GetByFirstAndLastNameAsync(string firstName, string lastName);
        Task AddAsync(User user);
        Task UpdateAsync(User user);
        Task RemoveAsync(User user);
        Task SaveChangesAsync();
    }
}