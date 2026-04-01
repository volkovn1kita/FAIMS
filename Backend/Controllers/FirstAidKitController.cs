using System.ComponentModel;
using Application.DTOs;
using Application.Interfaces;
using Domain;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace Backend.Controllers
{
    [Route("api/kits")]
    [ApiController]
    [EnableRateLimiting("ApiPolicy")]
    [Authorize]
    public class FirstAidKitController : ControllerBase
    {
        private readonly IFirstAidKitService _kitService;
        private readonly ICurrentUserService _currentUserService;

        public FirstAidKitController(
            IFirstAidKitService kitService,
            ICurrentUserService currentUserService)
        {
            _kitService = kitService;
            _currentUserService = currentUserService;
        }

        [HttpGet]
        [Authorize(Roles = nameof(UserRole.Administrator) + "," + nameof(UserRole.User))]
        public async Task<IActionResult> GetFirstAidKits(
            [FromQuery] string? searchTerm,
            [FromQuery] string? statusFilter,
            [FromQuery] Guid? responsibleUserId,
            [FromQuery] Guid? departmentId,
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 20)
        {
            var currentUserId = _currentUserService.GetUserId();
            var currentUserRole = _currentUserService.GetUserRole();

            if (currentUserRole != nameof(UserRole.Administrator) && responsibleUserId == null)
            {
                responsibleUserId = currentUserId;
            }
            else if (currentUserRole != nameof(UserRole.Administrator) && responsibleUserId != currentUserId)
            {
                return Forbid("You are not authorized to view kits not assigned to you.");
            }

            var kits = await _kitService.GetFilteredFirstAidKitsAsync(searchTerm, statusFilter, responsibleUserId, departmentId, pageNumber, pageSize);
            return Ok(kits);
        }

        [HttpGet("my")]
        [Authorize(Roles = nameof(UserRole.Administrator) + "," + nameof(UserRole.User))]
        public async Task<IActionResult> GetMyKit()
        {
            var currentUserId = _currentUserService.GetUserId();

            var kit = await _kitService.GetKitByResponsibleUserIdAsync(currentUserId);
            if (kit == null)
                return NotFound("You are not assigned to any first aid kit.");

            return Ok(kit);
        }

        [HttpGet("{id}")]
        [Authorize(Roles = nameof(UserRole.Administrator) + "," + nameof(UserRole.User))]
        public async Task<IActionResult> GetKitById(Guid id)
        {
            var kit = await _kitService.GetKitByIdAsync(id);
            return Ok(kit);
        }

        [HttpPost]
        [Authorize(Roles = nameof(UserRole.Administrator))]
        public async Task<IActionResult> CreateKit([FromBody] FirstAidKitCreateDto dto)
        {
            var kitId = await _kitService.AddKitAsync(dto);
            return CreatedAtAction(nameof(GetKitById), new { id = kitId }, kitId);
        }

        [HttpPut]
        [Authorize(Roles = nameof(UserRole.Administrator))]
        public async Task<IActionResult> UpdateKit([FromBody] FirstAidKitUpdateDto dto)
        {
            await _kitService.UpdateKitAsync(dto);
            return NoContent();
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = nameof(UserRole.Administrator))]
        public async Task<IActionResult> DeleteKit(Guid id)
        {
            await _kitService.DeleteKitAsync(id);
            return NoContent();
        }

        [HttpGet("{kitId}/medications")]
        [Authorize(Roles = nameof(UserRole.Administrator) + "," + nameof(UserRole.User))]
        public async Task<IActionResult> GetMedicationsByKit(Guid kitId)
        {
            var medications = await _kitService.GetMedicationsByKitIdAsync(kitId);
            return Ok(medications);
        }

        [HttpGet("medications/{id}")]
        [Authorize(Roles = nameof(UserRole.Administrator) + "," + nameof(UserRole.User))]
        public async Task<IActionResult> GetMedicationById(Guid id)
        {
            var medication = await _kitService.GetMedicationByIdAsync(id);
            return Ok(medication);
        }

        [HttpPost("medications")]
        [Authorize(Roles = nameof(UserRole.Administrator) + "," + nameof(UserRole.User))]
        public async Task<IActionResult> AddMedication([FromBody] MedicationCreateDto dto)
        {
            var medicationId = await _kitService.AddMedicationAsync(dto);
            return CreatedAtAction(nameof(GetMedicationById), new { id = medicationId }, medicationId);
        }

        [HttpPut("medications")]
        [Authorize(Roles = nameof(UserRole.Administrator))]
        public async Task<IActionResult> UpdateMedication([FromBody] MedicationUpdateDto dto)
        {
            await _kitService.UpdateMedicationAsync(dto);
            return NoContent();
        }

        [HttpDelete("medications/{medicationId}")]
        [Authorize(Roles = nameof(UserRole.Administrator))]
        public async Task<IActionResult> RemoveMedication(Guid medicationId, [FromQuery] Guid kitId)
        {
            await _kitService.RemoveMedicationAsync(medicationId, kitId);
            return NoContent();
        }

        [HttpPost("medications/{medicationId}/use")]
        [Authorize(Roles = nameof(UserRole.Administrator) + "," + nameof(UserRole.User))]
        public async Task<IActionResult> UseMedication(Guid medicationId, [FromBody] MedicationQuantityUpdateDto dto) 
        {
            await _kitService.UseMedicationAsync(medicationId, dto.Quantity);
            return NoContent();
        }

        [HttpPost("medications/{medicationId}/write-off")]
        [Authorize(Roles = nameof(UserRole.Administrator) + "," + nameof(UserRole.User))]
        public async Task<IActionResult> WriteOffMedication(Guid medicationId, [FromBody] MedicationWriteOffDto dto) 
        {
            await _kitService.WriteOffMedicationAsync(medicationId, dto.Quantity, dto.Reason);
            return NoContent();
        }

        [HttpPost("medications/{medicationId}/refill")]
        [Authorize(Roles = nameof(UserRole.Administrator) + "," + nameof(UserRole.User))]
        public async Task<IActionResult> RefillMedication(Guid medicationId, [FromBody] MedicationRefillDto dto)
        {
            await _kitService.RefillMedicationAsync(medicationId, dto);
            return NoContent();
        }

        [HttpGet("test-alerts")]
        [AllowAnonymous]
        public async Task<IActionResult> TriggerAlertsNow([FromServices] IExpirationAlertService alertService)
        {
            try 
            {
                await alertService.CheckAndNotifyExpiringMedicationsAsync();
                return Ok("✅ Пуші успішно відправлені! Перевір телефон.");
            }
            catch (Exception ex)
            {
                return BadRequest($"❌ ПОМИЛКА: {ex.Message} \n\n Стек: {ex.StackTrace}");
            }
        }
    }
}