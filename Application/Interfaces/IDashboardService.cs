using System;
using Application.DTOs;

namespace Application.Interfaces;

public interface IDashboardService
{
    Task<DashboardOverviewDto> GetDashboardOverviewAsync();
}
