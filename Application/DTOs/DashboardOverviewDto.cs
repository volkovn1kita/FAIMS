namespace Application.DTOs;

public record class DashboardOverviewDto
(
    int TotalKits,
    int KitsNeedingAttention,
    int TotalUsers,
    int TotalDepartments
);
