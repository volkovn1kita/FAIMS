using Application.Interfaces;
using Domain;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Application.DTOs;
using System.Linq.Expressions;

namespace Infrastructure.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly ApplicationDbContext _dbContext;

        public UserRepository(ApplicationDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IEnumerable<User>> GetAllFilteredAndSortedAsync(UserFilterAndPaginationDto filterDto)
        {
            IQueryable<User> query = _dbContext.Users.AsNoTracking();

            if (filterDto.Role.HasValue)
            {
                query = query.Where(u => u.Role == filterDto.Role.Value);
            }

            if (!string.IsNullOrWhiteSpace(filterDto.SearchQuery))
            {
                string searchLower = filterDto.SearchQuery.ToLower();
                query = query.Where(u =>
                    u.FirstName.ToLower().Contains(searchLower) ||
                    u.LastName.ToLower().Contains(searchLower) ||
                    u.Email.ToLower().Contains(searchLower));
            }

            Expression<Func<User, object>> orderByExpression = filterDto.SortBy?.ToLower() switch
            {
                "firstname" => u => u.FirstName,
                "lastname" => u => u.LastName,
                "email" => u => u.Email,
                "createddate" => u => u.CreatedDate,
                _ => u => u.CreatedDate
            };

            if (filterDto.SortOrder?.ToLower() == "desc")
            {
                query = query.OrderByDescending(orderByExpression);
            }
            else
            {
                query = query.OrderBy(orderByExpression);
            }

            query = query
                .Skip((filterDto.PageNumber - 1) * filterDto.PageSize)
                .Take(filterDto.PageSize);

            return await query.ToListAsync();
        }
        public async Task<int> CountActiveAdminsAsync(Guid organizationId)
        {
            return await _dbContext.Users
                .IgnoreQueryFilters()
                .CountAsync(u => u.OrganizationId == organizationId
                              && u.Role == UserRole.Administrator
                              && !u.IsDeleted);
        }

        public async Task<IEnumerable<User>> GetAllAsync()
        {
            return await _dbContext.Users
                .AsNoTracking()
                .IgnoreQueryFilters()
                .Where(u => u.OrganizationId == _dbContext.CurrentOrganizationId)
                .ToListAsync();
        }

        public async Task<User?> GetByIdAsync(Guid id)
        {
            return await _dbContext.Users.FindAsync(id);
        }
        public async Task<IEnumerable<User>> GetAllByOrganizationAsync(Guid organizationId)
        {
            return await _dbContext.Users
                .AsNoTracking()
                .IgnoreQueryFilters()
                .Where(u => u.OrganizationId == organizationId)
                .ToListAsync();
        }
        public async Task<User?> GetByEmailAsync(string email)
        {
            return await _dbContext.Users
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(u => u.Email == email);
        }

        public async Task<User?> GetByFirstAndLastNameAsync(string firstName, string lastName)
        {
            return await _dbContext.Users.Where(u => u.FirstName == firstName && u.LastName == lastName).FirstOrDefaultAsync();
        }

        public async Task AddAsync(User user)
        {
            await _dbContext.Users.AddAsync(user);
        }

        public Task UpdateAsync(User user)
        {
            _dbContext.Entry(user).State = EntityState.Modified;
            return Task.CompletedTask;
        }

        public Task RemoveAsync(User user)
        {
            user.IsDeleted = true;
            user.DeletedAt = DateTime.UtcNow;
            _dbContext.Users.Update(user);
            return Task.CompletedTask;
        }

        public async Task SaveChangesAsync()
        {
            await _dbContext.SaveChangesAsync();
        }
    }
}