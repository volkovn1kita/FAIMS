using Application.Interfaces;
using Domain;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using System.Text;

namespace Backend.Controllers;

[Route("api/export")]
[ApiController]
[EnableRateLimiting("ApiPolicy")]
[Authorize(Roles = nameof(UserRole.Administrator))]
public class ExportController : ControllerBase
{
    private readonly IFirstAidKitRepository _kitRepository;
    private readonly IJournalRepository _journalRepository;

    public ExportController(IFirstAidKitRepository kitRepository, IJournalRepository journalRepository)
    {
        _kitRepository = kitRepository;
        _journalRepository = journalRepository;
    }

    [HttpGet("inventory")]
    public async Task<IActionResult> ExportInventory()
    {
        var kits = await _kitRepository.GetFilteredKitsAsync(null, null, null);

        var sb = new StringBuilder();
        sb.AppendLine("Kit Number,Kit Name,Department,Room,Responsible Person,Medication,Quantity,Min Quantity,Unit,Expiration Date,Status");

        foreach (var kit in kits)
        {
            var dept = kit.Room?.Department?.Name ?? string.Empty;
            var room = kit.Room?.Name ?? string.Empty;
            var responsible = kit.ResponsibleUser != null
                ? $"{kit.ResponsibleUser.FirstName} {kit.ResponsibleUser.LastName}".Trim()
                : string.Empty;

            if (!kit.Medications.Any())
            {
                sb.AppendLine($"{Csv(kit.UniqueNumber)},{Csv(kit.Name)},{Csv(dept)},{Csv(room)},{Csv(responsible)},,,,,");
                continue;
            }

            foreach (var med in kit.Medications)
            {
                sb.AppendLine($"{Csv(kit.UniqueNumber)},{Csv(kit.Name)},{Csv(dept)},{Csv(room)},{Csv(responsible)},{Csv(med.Name)},{med.Quantity},{med.MinimumQuantity},{med.Unit},{med.ExpirationDate:yyyy-MM-dd},{med.Status}");
            }
        }

        var bytes = Encoding.UTF8.GetPreamble().Concat(Encoding.UTF8.GetBytes(sb.ToString())).ToArray();
        return File(bytes, "text/csv; charset=utf-8", $"inventory_{DateTime.UtcNow:yyyyMMdd}.csv");
    }

    [HttpGet("journal")]
    public async Task<IActionResult> ExportJournal(
        [FromQuery] DateTime? startDate,
        [FromQuery] DateTime? endDate)
    {
        var start = startDate?.ToUniversalTime() ?? DateTime.UtcNow.AddDays(-30);
        var end = endDate?.ToUniversalTime() ?? DateTime.UtcNow;

        var entries = await _journalRepository.GetEntriesByDateRangeAsync(start, end);

        var sb = new StringBuilder();
        sb.AppendLine("Date,Action,Medication,Quantity,Unit,Kit,Responsible Person,Reason");

        foreach (var entry in entries)
        {
            var responsible = entry.User != null
                ? $"{entry.User.FirstName} {entry.User.LastName}".Trim()
                : string.Empty;
            var kitName = entry.FirstAidKit?.Name ?? string.Empty;

            sb.AppendLine($"{entry.CreatedDate:yyyy-MM-dd HH:mm},{entry.ActionType},{Csv(entry.MedicationName)},{entry.Quantity},{entry.Unit},{Csv(kitName)},{Csv(responsible)},{Csv(entry.Reason ?? string.Empty)}");
        }

        var bytes = Encoding.UTF8.GetPreamble().Concat(Encoding.UTF8.GetBytes(sb.ToString())).ToArray();
        return File(bytes, "text/csv; charset=utf-8", $"journal_{start:yyyyMMdd}_{end:yyyyMMdd}.csv");
    }

    private static string Csv(string value)
    {
        if (value.Contains(',') || value.Contains('"') || value.Contains('\n'))
            return $"\"{value.Replace("\"", "\"\"")}\"";
        return value;
    }
}
