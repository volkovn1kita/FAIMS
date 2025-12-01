// Backend/Controllers/UserController.cs - ОНОВЛЕНА ВЕРСІЯ
using Application.DTOs;
using Application.Interfaces;
using Domain;
using Domain.Exceptions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Security.Claims;

namespace Backend.Controllers
{
    [Route("api/users")]
    [ApiController]
    [Authorize]
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly ICurrentUserService _currentUserService;

        public UserController(IUserService userService, ICurrentUserService currentUserService)
        {
            _userService = userService;
            _currentUserService = currentUserService;
        }

        // POST: api/users/login - Дозволяє неавторизований доступ
        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] UserLoginDto dto)
        {
            var authResult = await _userService.LoginAsync(dto);
            if (authResult == null)
            {
                return Unauthorized(new { Message = "Incorrect email or password." });
            }
            return Ok(authResult);
        }

        // GET: api/users - Тільки для адміністраторів, тепер з фільтрацією, пошуком та сортуванням
        [HttpGet]
        [Authorize(Roles = nameof(UserRole.Administrator))]
        public async Task<IActionResult> GetAllUsers([FromQuery] UserFilterAndPaginationDto filterDto) // <--- ЗМІНЕНО
        {
            var users = await _userService.GetAllUsersAsync(filterDto);
            return Ok(users);
        }

        // GET: api/users/{id} - Тільки для адміністраторів
        [HttpGet("{id}")]
        [Authorize(Roles = nameof(UserRole.Administrator))]
        public async Task<IActionResult> GetUserById(Guid id)
        {
            try
            {
                var user = await _userService.GetUserByIdAsync(id);
                return Ok(user);
            }
            catch (NotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }

        // GET: api/users/me - Для будь-якого авторизованого користувача
        [HttpGet("me")]
        public async Task<IActionResult> GetCurrentUserProfile()
        {
            try
            {
                var userId = _currentUserService.GetUserId();
                if (userId == Guid.Empty)
                {
                    return Unauthorized(new { Message = "User not authenticated." });
                }
                var userProfile = await _userService.GetCurrentUserProfileAsync(userId);
                return Ok(userProfile);
            }
            catch (NotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }

        // POST: api/users/admin-create - Тільки для адміністраторів
        [HttpPost("admin-create")]
        [Authorize(Roles = nameof(UserRole.Administrator))]
        public async Task<IActionResult> AdminCreateUser ([FromBody] AdminCreateUserDto dto)
        {
            try
            {
                var userId = await _userService.AdminCreateUserAsync(dto);
                return StatusCode(201, new { UserId = userId });
            }
            catch (ValidationException ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        // PUT: api/users/{id} - Оновлення користувача адміністратором
        [HttpPut("{id}")]
        [Authorize(Roles = nameof(UserRole.Administrator))]
        public async Task<IActionResult> UpdateUser(Guid id, [FromBody] UpdateUserDto dto)
        {
            try
            {
                await _userService.UpdateUserAsync(id, dto);
                return NoContent();
            }
            catch (ValidationException ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
            catch (NotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }

        // PUT: api/users/me - Оновлення власного профілю користувачем
        [HttpPut("me")]
        public async Task<IActionResult> UpdateUserProfile([FromBody] UpdateProfileDto dto)
        {
            try
            {
                var userId = _currentUserService.GetUserId();
                if (userId == Guid.Empty)
                {
                    return Unauthorized(new { Message = "User not authenticated." });
                }
                await _userService.UpdateUserProfileAsync(userId, dto);
                return NoContent();
            }
            catch (ValidationException ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
            catch (NotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }

        // DELETE: api/users/{id} - Тільки для адміністраторів
        [HttpDelete("{id}")]
        [Authorize(Roles = nameof(UserRole.Administrator))]
        public async Task<IActionResult> DeleteUser(Guid id)
        {
            try
            {
                await _userService.DeleteUserAsync(id);
                return NoContent();
            }
            catch (ValidationException ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
            catch (NotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }

        [HttpPost("{id}/avatar")]
        [Authorize(Roles = nameof(UserRole.Administrator))]
        public async Task<IActionResult> UploadUserAvatar(Guid id, IFormFile avatarFile)
        {
            try
            {
                var avatarUrl = await _userService.UploadUserAvatarAsync(id, avatarFile);
                return Ok(new { AvatarUrl = avatarUrl });
            }
            catch (ValidationException ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
            catch (NotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }

        // POST: api/users/me/avatar - Завантаження аватара для поточного користувача
        [HttpPost("me/avatar")]
        public async Task<IActionResult> UploadMyAvatar(IFormFile avatarFile)
        {
            try
            {
                var userId = _currentUserService.GetUserId();
                if (userId == Guid.Empty)
                {
                    return Unauthorized(new { Message = "User not authenticated." });
                }
                var avatarUrl = await _userService.UploadUserAvatarAsync(userId, avatarFile);
                return Ok(new { AvatarUrl = avatarUrl });
            }
            catch (ValidationException ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
            catch (NotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }

        // DELETE: api/users/{id}/avatar - Видалення аватара для конкретного користувача (адмін)
        [HttpDelete("{id}/avatar")]
        [Authorize(Roles = nameof(UserRole.Administrator))]
        public async Task<IActionResult> DeleteUserAvatar(Guid id)
        {
            try
            {
                await _userService.DeleteUserAvatarAsync(id);
                return NoContent();
            }
            catch (ValidationException ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
            catch (NotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }

        // DELETE: api/users/me/avatar - Видалення аватара для поточного користувача
        [HttpDelete("me/avatar")]
        public async Task<IActionResult> DeleteMyAvatar()
        {
            try
            {
                var userId = _currentUserService.GetUserId();
                if (userId == Guid.Empty)
                {
                    return Unauthorized(new { Message = "User not authenticated." });
                }
                await _userService.DeleteUserAvatarAsync(userId);
                return NoContent();
            }
            catch (ValidationException ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
            catch (NotFoundException ex)
            {
                return NotFound(new { Message = ex.Message });
            }
        }

    }
}