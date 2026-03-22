using Microsoft.AspNetCore.RateLimiting;
using Application.DTOs;
using Application.Interfaces;
using Domain;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers;

[Route("api/analytics")]
[EnableRateLimiting("ApiPolicy")]
[ApiController]
public class AnalyticsController : ControllerBase
{
    private readonly IAnalyticsService _analyticsService;

    public AnalyticsController(IAnalyticsService analyticsService)
    {
        _analyticsService = analyticsService;
    }

    [HttpGet("global")]
    [Authorize(Roles = nameof(UserRole.Administrator))]
    public async Task<ActionResult<DashboardStatsDto>> GetGlobalStats()
    {
        var stats = await _analyticsService.GetGlobalStatsAsync();
        return Ok(stats);
    }
}