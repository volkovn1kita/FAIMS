// Backend/Controllers/AnalyticsController.cs
using Application.DTOs;
using Application.Interfaces;
using Domain; // Переконайся, що тут є твій Enum UserRole
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers;

[Route("api/analytics")] // Роут без ID аптечки
[ApiController]
public class AnalyticsController : ControllerBase
{
    private readonly IAnalyticsService _analyticsService;

    public AnalyticsController(IAnalyticsService analyticsService)
    {
        _analyticsService = analyticsService;
    }

    [HttpGet("global")] // Кінцевий шлях: GET /api/analytics/global
    [Authorize(Roles = nameof(UserRole.Administrator))] // ТІЛЬКИ АДМІН
    public async Task<ActionResult<DashboardStatsDto>> GetGlobalStats()
    {
        var stats = await _analyticsService.GetGlobalStatsAsync();
        return Ok(stats);
    }
}