using System;
using Application.DTOs;
using Application.Interfaces;

namespace Application.Services;

public class DashboardService : IDashboardService
{
    private readonly IDepartmentRepository _departmentRepository;
    private readonly IUserRepository _userRepository;
    private readonly IFirstAidKitRepository _firstAidKitRepository;
    private readonly IReportingService _reportingService;

    public DashboardService(
        IDepartmentRepository departmentRepository,
        IFirstAidKitRepository firstAidKitRepository,
        IUserRepository userRepository,
        IReportingService reportingService
    )
    {
        _departmentRepository = departmentRepository;
        _userRepository = userRepository;
        _firstAidKitRepository = firstAidKitRepository;
        _reportingService = reportingService;

    }
    public async Task<DashboardOverviewDto> GetDashboardOverviewAsync()
    {
        var allDepartments = await _departmentRepository.GetAllDepartmentsAsync();
        var totalDepartments = allDepartments.Count();

        var allUsers = await _userRepository.GetAllAsync();
        var totalUsers = allUsers.Count();

        var allKits = await _firstAidKitRepository.GetFilteredKitsAsync(null,null,null);
        var totalKits = allKits.Count();

        var kitStatusReports = await _reportingService.GenerateKitStatusReportAsync();
        var kitsNeedingAttention = kitStatusReports.Count(
            report => report.CriticalCount > 0 || report.LowQuantityCount > 0
        );


        return new DashboardOverviewDto
        (
            totalKits,
            kitsNeedingAttention,
            totalUsers,
            totalDepartments
        );
    }
}
