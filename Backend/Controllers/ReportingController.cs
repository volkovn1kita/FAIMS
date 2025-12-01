using Application.Interfaces;
using Domain;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

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
    }
}
