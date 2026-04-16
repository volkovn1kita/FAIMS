using System;
using Application.Interfaces;
using Domain;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class DepartmentRepository : IDepartmentRepository
{
    private readonly ApplicationDbContext _dbContext;
    public DepartmentRepository(ApplicationDbContext dbContext)
    {
        _dbContext = dbContext;
    }
    public async Task AddDepartmentAsync(Department department)
    {
        await _dbContext.Departments.AddAsync(department);
    }

    public async Task AddRoomToDepartmentAsync(Room room)
    {
        await _dbContext.Rooms.AddAsync(room);
    }

    public Task DeleteDepartment(Department department)
    {
        department.IsDeleted = true;
        department.DeletedAt = DateTime.UtcNow;
        _dbContext.Departments.Update(department);
        return Task.CompletedTask;
    }

    public Task DeleteRoom(Room room)
    {
        room.IsDeleted = true;
        room.DeletedAt = DateTime.UtcNow;
        _dbContext.Rooms.Update(room);
        return Task.CompletedTask;
    }

    public async Task<IEnumerable<Department>> GetAllDepartmentsAsync(
        int? pageNumber = null,
        int? pageSize = null)
    {
        var query = _dbContext.Departments
            .AsNoTracking()
            .OrderBy(d => d.Name)
            .AsQueryable();

        if (pageNumber.HasValue && pageSize.HasValue)
        {
            query = query
                .Skip((pageNumber.Value - 1) * pageSize.Value)
                .Take(pageSize.Value);
        }

        return await query.ToListAsync();
    }

    public async Task<int> GetDepartmentsCountAsync()
    {
        return await _dbContext.Departments.CountAsync();
    }

    public async Task<Department?> GetDepartmentByIdAsync(Guid id)
    {
        return await _dbContext.Departments
            .Include(d => d.Rooms)
            .FirstOrDefaultAsync(d=> d.Id == id);
    }

    public async Task<Department?> GetDepartmentByNameAsync(string name)
    {
        return await _dbContext.Departments.FirstOrDefaultAsync(d => d.Name == name);
    }

    public async Task<IEnumerable<Room>> GetRoomsAsync()
    {
        return await _dbContext.Rooms
            .AsNoTracking()
            .Include(r => r.Department)
            .ToListAsync();
    }

    public async Task<Room?> GetRoomByIdAsync(Guid id)
    {
        return await _dbContext.Rooms
            .Include(r => r.Department)
            .FirstOrDefaultAsync(r => r.Id == id);
    }

    public async Task<IEnumerable<Room>> GetRoomsByDepartmentIdAsync(Guid departmentId)
    {
        return await _dbContext.Rooms
            .AsNoTracking()
            .Where(r => r.DepartmentId == departmentId)
            .ToListAsync();
    }

    public async Task SaveChangesAsync()
    {
        await _dbContext.SaveChangesAsync();
    }

    public Task UpdateDepartment(Department department)
    {
        _dbContext.Departments.Update(department);
        return Task.CompletedTask;
    }

    public Task UpdateRoom(Room room)
    {
        _dbContext.Rooms.Update(room);
        return Task.CompletedTask;
    }
}
