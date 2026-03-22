using Application.DTOs;
using Application.Interfaces;
using Domain;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/departments")]
    [EnableRateLimiting("ApiPolicy")]
    [Authorize(Roles = nameof(UserRole.Administrator))]
    public class DepartmentController : ControllerBase
    {
        private readonly IDepartmentService _departmentService;

        public DepartmentController(IDepartmentService departmentService)
        {
            _departmentService = departmentService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAllDepartments()
        {
            var departments = await _departmentService.GetAllDepartmentsAsync();
            return Ok(departments);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetDepartmentById(Guid id)
        {
            var department = await _departmentService.GetDepartmentByIdAsync(id); 
            return Ok(department);
        }

        [HttpPost]
        public async Task<IActionResult> AddDepartment([FromBody] DepartmentCreateDto dto)
        {
            var departmentId = await _departmentService.AddDepartmentAsync(dto);
            return CreatedAtAction(nameof(GetDepartmentById), new { id = departmentId }, departmentId);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateDepartment(Guid id, [FromBody] DepartmentCreateDto dto)
        {
            await _departmentService.UpdateDepartmentAsync(id, dto.Name);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteDepartment(Guid id)
        {
            await _departmentService.DeleteDepartmentAsync(id);
            return NoContent();
        }

        [HttpGet("rooms/all")]
        public async Task<IActionResult> GetAllRooms()
        {
            var rooms = await _departmentService.GetAllRoomsAsync();
            return Ok(rooms);
        }

        [HttpGet("{departmentId}/rooms")]
        public async Task<IActionResult> GetRoomsByDepartment(Guid departmentId)
        {
            var rooms = await _departmentService.GetRoomsByDepartmentIdAsync(departmentId);
            return Ok(rooms);
        }

        [HttpPost("rooms")]
        public async Task<IActionResult> AddRoom([FromBody] RoomCreateDto dto)
        {
            var roomId = await _departmentService.AddRoomAsync(dto);
            return StatusCode(201, roomId); 
        }

        [HttpPut("rooms/{id}")]
        public async Task<IActionResult> UpdateRoom(Guid id, [FromBody] RoomUpdateDto dto)
        {
            await _departmentService.UpdateRoomAsync(id, dto.Name, dto.DepartmentId);
            return NoContent();
        }

        [HttpDelete("rooms/{id}")]
        public async Task<IActionResult> DeleteRoom(Guid id)
        {
            await _departmentService.DeleteRoomAsync(id);
            return NoContent();
        }
    }
}