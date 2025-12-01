using System;
using Application.DTOs;

namespace Application.Interfaces;

public interface IAnalyticsService
{
    Task<DashboardStatsDto> GetGlobalStatsAsync();
}
