using Application.DTOs;
using Application.Interfaces;
using Domain;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Backend.Controllers
{
    [Route("api/reports")]
    [ApiController]
    [Authorize(Roles = nameof(UserRole.Administrator))]
    public class ReportingController : ControllerBase
    {
        private readonly IReportingService _reportingService;

        public ReportingController(IReportingService reportingService)
        {
            _reportingService = reportingService;
        }

        [HttpGet("critical-items")]
        public async Task<IActionResult> GetCriticalItemsReport()
        {
            var CriticalItems = await _reportingService.GenerateCriticalItemsReportAsync();
            return Ok(CriticalItems);
        }

        [HttpGet("status-kits")]
        public async Task<IActionResult> GetKitStatusReport()
        {
            var kitStatuses = await _reportingService.GenerateKitStatusReportAsync();
            return Ok(kitStatuses);
        }

        [HttpGet("purchasing")]
        public async Task<IActionResult> GetPurchasingReport([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
        {
            var start = startDate?.ToUniversalTime() ?? DateTime.UtcNow.AddDays(-30);
            var end = endDate?.ToUniversalTime() ?? DateTime.UtcNow;

            var report = await _reportingService.GetPurchasingReportAsync(start, end);
            return Ok(report);
        }

        [HttpGet("disposal")]
        public async Task<IActionResult> GetDisposalReport([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
        {
            var start = startDate?.ToUniversalTime() ?? DateTime.UtcNow.AddDays(-30);
            var end = endDate?.ToUniversalTime() ?? DateTime.UtcNow;

            var report = await _reportingService.GetDisposalReportAsync(start, end);
            return Ok(report);
        }
    }
}