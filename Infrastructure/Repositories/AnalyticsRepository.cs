using Application.DTOs;
using Application.Interfaces;
using Domain;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class AnalyticsRepository : IAnalyticsRepository
{
    private readonly ApplicationDbContext _context;

    public AnalyticsRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    // Допоміжний метод (без змін)
    private async Task<Dictionary<string, MeasurementUnit>> GetUnitsForMedications(List<string> names)
    {
        var medications = await _context.Medications
            .Where(m => names.Contains(m.Name))
            .Select(m => new { m.Name, m.Unit })
            .Distinct()
            .ToListAsync();

        return medications
            .GroupBy(x => x.Name) 
            .ToDictionary(g => g.Key, g => g.First().Unit);
    }

    public async Task<IEnumerable<MedicationStatDto>> GetGlobalTopUsedMedicationsAsync(int topCount)
    {
        var rawData = await _context.Journals
            .Where(j => j.ActionType == JournalAction.Used)
            .GroupBy(j => new { j.MedicationName, j.Unit })
            .Select(g => new 
            { 
                Name = g.Key.MedicationName, 
                UnitEnum = g.Key.Unit,
                TotalQty = (double)g.Sum(x => x.Quantity) 
            })
            .ToListAsync();

        if (!rawData.Any()) return new List<MedicationStatDto>();

        var names = rawData.Select(x => x.Name ?? "").ToList();
        var unitsMap = await GetUnitsForMedications(names);

        var convertedData = rawData.Select(item => {
            var name = item.Name ?? "Unknown"; // <--- Змінна 'name' (маленька)
            var qty = item.TotalQty;
            var unitLabel = item.UnitEnum.ToString();

            if (item.UnitEnum == MeasurementUnit.Milliliters)
            {
                qty = qty / 1000.0;
                unitLabel = "L";
            }
            
            // === ВИПРАВЛЕННЯ ТУТ ===
            return new { Name = name, Qty = qty, Unit = unitLabel };
        });

        // Цей код тепер спрацює, бо 'convertedData' має властивість 'Name'
        var aggregatedData = convertedData
            .GroupBy(x => x.Name)
            .Select(g => new MedicationStatDto(
                g.Key,
                g.Sum(item => item.Qty),
                g.First().Unit
            ))
            .OrderByDescending(x => x.TotalQuantity)
            .Take(topCount)
            .ToList();

        return aggregatedData;
    }

    public async Task<IEnumerable<MedicationStatDto>> GetGlobalTopExpiredMedicationsAsync(int topCount)
    {
        var rawData = await _context.Journals
            .Where(j => j.ActionType == JournalAction.WrittenOff)
            .GroupBy(j => new { j.MedicationName, j.Unit })
            .Select(g => new 
            { 
                Name = g.Key.MedicationName, 
                UnitEnum = g.Key.Unit,
                TotalQty = (double)g.Sum(x => x.Quantity) 
            })
            .ToListAsync();

        if (!rawData.Any()) return new List<MedicationStatDto>();

        var names = rawData.Select(x => x.Name ?? "").ToList();
        var unitsMap = await GetUnitsForMedications(names);

        var convertedData = rawData.Select(item => {
            var name = item.Name ?? "Unknown"; // <--- Змінна 'name' (маленька)
            var qty = item.TotalQty;
            var unitLabel = item.UnitEnum.ToString();

            if (item.UnitEnum == MeasurementUnit.Milliliters)
            {
                qty = qty / 1000.0;
                unitLabel = "L";
            }
            
            // === ВИПРАВЛЕННЯ ТУТ ===
            return new { Name = name, Qty = qty, Unit = unitLabel };
        });

        var aggregatedData = convertedData
            .GroupBy(x => x.Name)
            .Select(g => new MedicationStatDto(
                g.Key,
                g.Sum(item => item.Qty),
                g.First().Unit
            ))
            .OrderByDescending(x => x.TotalQuantity)
            .Take(topCount)
            .ToList();

        return aggregatedData;
    }
}