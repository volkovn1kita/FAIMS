// Application/Interfaces/IUserRepository.cs - ОНОВЛЕНА ВЕРСІЯ
using Application.DTOs; // Для UserFilterAndPaginationDto
using Domain;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Application.Interfaces
{
    public interface IUserRepository
    {
        // Змінено: Тепер приймає DTO для фільтрації та сортування
        Task<IEnumerable<User>> GetAllFilteredAndSortedAsync(UserFilterAndPaginationDto filterDto); // <--- НОВИЙ МЕТОД
        
        // Старий GetAllAsync можна залишити або видалити, якщо він більше не потрібен
        Task<IEnumerable<User>> GetAllAsync();

        Task<User?> GetByIdAsync(Guid id);
        Task<User?> GetByEmailAsync(string email);
        Task<User?> GetByFirstAndLastNameAsync(string firstName, string lastName);
        Task AddAsync(User user);
        Task UpdateAsync(User user);
        Task RemoveAsync(User user);
        Task SaveChangesAsync();
    }
}