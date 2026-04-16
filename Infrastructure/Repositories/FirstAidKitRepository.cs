using System;
using Application.Interfaces;
using Domain;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class FirstAidKitRepository : IFirstAidKitRepository
{
    private readonly ApplicationDbContext _dbContext;
    public FirstAidKitRepository(ApplicationDbContext dbContext)
    {
        _dbContext = dbContext;
    }
    public async Task AddKitAsync(FirstAidKit kit)
    {
        await _dbContext.FirstAidKits.AddAsync(kit);
    }

    public async Task AddMedicationToKitAsync(Medication medication, Guid kitId)
    {
        medication.FirstAidKitId = kitId;
        await _dbContext.Medications.AddAsync(medication);
    }

    public async Task<IEnumerable<FirstAidKit>> GetFilteredKitsAsync(
        string? searchTerm,
        Guid? responsibleUserId,
        Guid? departmentId,
        int? pageNumber = null,
        int? pageSize = null)
    {
        var query = _dbContext.FirstAidKits
            .AsNoTracking()
            .Include(k => k.Room)
                .ThenInclude(r => r.Department)
            .Include(k => k.ResponsibleUser)
            .Include(k => k.Medications)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(searchTerm))
        {
            query = query.Where(k =>
                k.Name.Contains(searchTerm) ||
                k.UniqueNumber.Contains(searchTerm));
        }

        if (responsibleUserId.HasValue)
        {
            query = query.Where(k => k.ResponsibleUserId == responsibleUserId.Value);
        }

        if (departmentId.HasValue)
        {
            query = query.Where(k => k.Room != null && k.Room.DepartmentId == departmentId.Value);
        }

        if (pageNumber.HasValue && pageSize.HasValue)
            query = query.Skip((pageNumber.Value - 1) * pageSize.Value).Take(pageSize.Value);

        return await query.ToListAsync();
    }

    public async Task<FirstAidKit?> GetKitByResponsibleUserIdAsync(Guid userId)
    {
        return await _dbContext.FirstAidKits
            .AsNoTracking()
            .Include(k => k.Room)
                .ThenInclude(r => r.Department)
            .Include(k => k.ResponsibleUser)
            .Include(k => k.Medications)
            .FirstOrDefaultAsync(k => k.ResponsibleUserId == userId);
    }

    public async Task ClearResponsibleUserFromKitsAsync(Guid userId)
    {
        await _dbContext.FirstAidKits
            .Where(k => k.ResponsibleUserId == userId)
            .ExecuteUpdateAsync(s => s.SetProperty(k => k.ResponsibleUserId, (Guid?)null));
    }

    public async Task<FirstAidKit?> GetKitByIdAsync(Guid id)
    {
        return await _dbContext.FirstAidKits
            .Include(k => k.Room)
                .ThenInclude(k => k.Department)
            .Include(k => k.ResponsibleUser)
            .Include(k => k.Medications)
            .FirstOrDefaultAsync(k => k.Id == id);
    }
    public async Task<FirstAidKit?> GetKitByRoomIdAsync (Guid roomId)
    {
        return await _dbContext.FirstAidKits.FirstOrDefaultAsync(k => k.RoomId == roomId);
    }
    public async Task<FirstAidKit?> GetKitByUniqueNumberAsync(string uniqueNumber)
    {
        return await _dbContext.FirstAidKits.FirstOrDefaultAsync(k => k.UniqueNumber == uniqueNumber);
    }

    public Task DeleteKitAsync(FirstAidKit kit)
    {
        kit.IsDeleted = true;
        kit.DeletedAt = DateTime.UtcNow;
        _dbContext.FirstAidKits.Update(kit);
        return Task.CompletedTask;
    }

    public async Task<IEnumerable<Medication>> GetAllMedicationsAsync(
        int? pageNumber = null,
        int? pageSize = null)
    {
        var query = _dbContext.Medications
            .AsNoTracking()
            .OrderBy(m => m.Name)
            .AsQueryable();

        if (pageNumber.HasValue && pageSize.HasValue)
        {
            query = query
                .Skip((pageNumber.Value - 1) * pageSize.Value)
                .Take(pageSize.Value);
        }

        return await query.ToListAsync();
    }

    public async Task<int> GetMedicationsCountAsync()
    {
        return await _dbContext.Medications.CountAsync();
    }

    public async Task<Medication?> GetMedicationByIdAsync(Guid id)
    {
        return await _dbContext.Medications.FirstOrDefaultAsync(m => m.Id == id);
    }
    
    public async Task<Medication?> GetMedicationByBatchAsync(Guid kitId, string medicationName, DateTime expirationDate)
    {
        return await _dbContext.Medications
            .Where(m => m.FirstAidKitId == kitId && m.Name == medicationName && m.ExpirationDate == expirationDate)
            .FirstOrDefaultAsync();
    }

    public async Task<IEnumerable<Medication>> GetMedicationsByKitIdAsync(Guid kitId)
    {
        return await _dbContext.Medications
            .AsNoTracking()
            .Where(m => m.FirstAidKitId == kitId)
            .OrderBy(m => m.ExpirationDate)
            .ToListAsync();
    }

    public async Task<Medication?> GetMedicationByNameInKitAsync(Guid kitId, string medicationName)
    {
        return await _dbContext.Medications.Where(m => m.FirstAidKitId == kitId
                                                  && m.Name == medicationName).FirstOrDefaultAsync();
    }

    public Task RemoveMedicationFromKit(Medication medication, Guid kitId)
    {
        medication.IsDeleted = true;
        medication.DeletedAt = DateTime.UtcNow;
        _dbContext.Medications.Update(medication);
        return Task.CompletedTask;
    }

    public async Task SaveChangesAsync()
    {
        await _dbContext.SaveChangesAsync();
    }

    public Task UpdateKitAsync(FirstAidKit kit)
    {
        _dbContext.FirstAidKits.Update(kit);
        return Task.CompletedTask;
    }

    public Task UpdateMedicationInKit(Medication medication)
    {
        _dbContext.Medications.Update(medication);
        return Task.CompletedTask;
    }

    public async Task<IEnumerable<Medication>> GetMedicationsExpiringOnDateWithUsersAsync(DateTime date)
    {
        var targetUtc = DateTime.SpecifyKind(date.Date, DateTimeKind.Utc);
        
        var startWindow = targetUtc.AddHours(-12);
        var endWindow = targetUtc.AddHours(36);

        return await _dbContext.Medications
            .AsNoTracking()
            .IgnoreQueryFilters()
            .Include(m => m.FirstAidKit)
            .ThenInclude(k => k.ResponsibleUser)
            .Where(m => m.ExpirationDate >= startWindow && m.ExpirationDate <= endWindow)
            .ToListAsync();
    }

    public async Task<IEnumerable<Medication>> GetLowStockMedicationsWithUsersAsync()
    {
        return await _dbContext.Medications
            .AsNoTracking()
            .IgnoreQueryFilters()
            .Include(m => m.FirstAidKit)
            .ThenInclude(k => k.ResponsibleUser)
            .Where(m => m.Quantity < m.MinimumQuantity)
            .ToListAsync();
    }

}
