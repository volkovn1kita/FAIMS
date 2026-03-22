using Application.DTOs;
using Application.Interfaces;
using Domain;
using Domain.Exceptions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Security.Claims;

namespace Backend.Controllers
{
    [Route("api/users")]
    [ApiController]
    [EnableRateLimiting("ApiPolicy")]
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

        [HttpPost("login")]
        [EnableRateLimiting("AuthPolicy")]
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

        [HttpPost("register-organization")]
        [EnableRateLimiting("AuthPolicy")]
        [AllowAnonymous]
        public async Task<IActionResult> RegisterOrganization([FromBody] RegisterOrganizationDto dto)
        {
            try
            {
                var result = await _userService.RegisterOrganizationAsync(dto);
                return Ok(result);
            }
            catch (ValidationException ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        [HttpGet]
        [Authorize(Roles = nameof(UserRole.Administrator))]
        public async Task<IActionResult> GetAllUsers([FromQuery] UserFilterAndPaginationDto filterDto)
        {
            var users = await _userService.GetAllUsersAsync(filterDto);
            return Ok(users);
        }

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

        [HttpPost("admin-create")]
        [Authorize(Roles = nameof(UserRole.Administrator))]
        public async Task<IActionResult> AdminCreateUser([FromBody] AdminCreateUserDto dto)
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

        [HttpPost("update-fcm-token")]
        public async Task<IActionResult> UpdateFcmToken([FromBody] UpdateFcmTokenRequest request)
        {
            var userId = _currentUserService.GetUserId();
            if (userId == Guid.Empty)
            {
                return Unauthorized(new { Message = "User not authenticated." });
            }

            await _userService.UpdateFcmTokenAsync(userId, request.Token);
            
            return Ok(new { Message = "FCM token updated successfully." });
        }
    }
}